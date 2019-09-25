
#import "OpenCVCam.h"
#import "UIImage+OpenCV.h"
#import "color.h"
#include "Bot.h"

#define PI 3.1415926535

using namespace cv;
using namespace std;

@implementation OpenCVCam

cv::Point intersection = cv::Point(0, 0);

cv::Point quadrants[4] = {cv::Point(0, 0), cv::Point(0, 0), cv::Point(0, 0), cv::Point(0, 0)};


Color targetcolor_l("targetcolor_l",
           Scalar(0, 100, 100),
           Scalar(3, 255, 255));

Color targetcolor_h("targetcolor_h",
           Scalar(160, 100, 100),
           Scalar(179, 255, 255));

vector<Color> colors;

+ (id)sharedInstance {
    static OpenCVCam *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initCam];
    });
    return instance;
}


- (void) start
{
    [self.cam start];
}

- (void) stop
{
    [self.cam stop];
}

- (void) initCam
{
    self.cam = [[CvVideoCamera alloc] init];
    
    self.cam.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    self.cam.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    self.cam.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.cam.defaultFPS = 30;
    self.cam.grayscaleMode = NO;
    self.cam.delegate = self;
}


int N = 5;
int thresh = 50;

double angle( cv::Point pt1, cv::Point pt2, cv::Point pt0 ) {
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return (dx1*dx2 + dy1*dy2)/sqrt((dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10);
}

Mat findRects( const Mat& image, vector<vector<cv::Point> >& rects ) {
   
    rects.clear();

//s    Mat pyr, timg, gray0(image.size(), CV_8U), gray;

    // down-scale and upscale the image to filter out the noise
    //pyrDown(image, pyr, Size(image.cols/2, image.rows/2));
    //pyrUp(pyr, timg, image.size());


    // blur will enhance edge detection
    Mat timg(image);
    medianBlur(image, timg, 9);
    Mat gray0(timg.size(), CV_8U), gray;

    vector<vector<cv::Point> > contours;

    // find rects in every color plane of the image
    for( int c = 0; c < 3; c++ )
    {
        int ch[] = {c, 0};
        mixChannels(&timg, 1, &gray0, 1, ch, 1);

        // try several threshold levels
        for( int l = 0; l < N; l++ )
        {
            // hack: use Canny instead of zero threshold level.
            // Canny helps to catch rects with gradient shading
            if( l == 0 )
            {
                // apply Canny. Take the upper threshold from slider
                // and set the lower to 0 (which forces edges merging)
                Canny(gray0, gray, 5, thresh, 5);
                // dilate canny output to remove potential
                // holes between edge segments
                dilate(gray, gray, Mat(), cv::Point(-1,-1));
            }
            else
            {
                // apply threshold if l!=0:
                //     tgray(x,y) = gray(x,y) < (l+1)*255/N ? 255 : 0
                gray = gray0 >= (l+1)*255/N;
            }

            // find contours and store them all as a list
            findContours(gray, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

            vector<cv::Point> approx;

            // test each contour
            for( size_t i = 0; i < contours.size(); i++ )
            {
                // approximate contour with accuracy proportional
                // to the contour perimeter
                approxPolyDP(Mat(contours[i]), approx, arcLength(Mat(contours[i]), true)*0.02, true);

                // square contours should have 4 vertices after approximation
                // relatively large area (to filter out noisy contours)
                // and be convex.
                // Note: absolute value of an area is used because
                // area may be positive or negative - in accordance with the
                // contour orientation
                if( approx.size() == 4 &&
                    fabs(contourArea(Mat(approx))) > 1000 &&
                    isContourConvex(Mat(approx)) )
                {
                    double maxCosine = 0;

                    for( int j = 2; j < 5; j++ )
                    {
                        // find the maximum cosine of the angle between joint edges
                        double cosine = fabs(angle(approx[j%4], approx[j-2], approx[j-1]));
                        maxCosine = MAX(maxCosine, cosine);
                    }

                    // if cosines of all angles are small
                    // (all angles are ~90 degree) then write quandrange
                    // vertices to resultant sequence
                    if( maxCosine < 0.3 )
                        rects.push_back(approx);
                }
            }
        }
    }
    return image;
}

Mat drawRects( Mat& image, const vector<vector<cv::Point> >& rects ) {
    for( size_t i = 0; i < rects.size(); i++ )
    {
        const cv::Point* p = &rects[i][0];

        int n = (int)rects[i].size();
        //dont detect the border
        if (p-> x > 3 && p->y > 3)
          polylines(image, &p, &n, 1, true, Scalar(0,255,0), 3, LINE_AA);
    }
    return image;
}

bool compareContourAreas ( std::vector<cv::Point> contour1, std::vector<cv::Point> contour2 ) {
    double i = fabs( contourArea(cv::Mat(contour1)) );
    double j = fabs( contourArea(cv::Mat(contour2)) );
    return ( i > j );
}


- (void) processImage : (cv::Mat &) image
{
    
    // mask to only have white colors
    
    Mat hsv;
    Mat targetmask, targetmasklow, targetmaskhigh;
    
    cvtColor(image, hsv, COLOR_BGR2HSV);
    
    // Detect red area in frame
    inRange(hsv, targetcolor_l.low, targetcolor_l.high,  targetmasklow);
    inRange(hsv, targetcolor_h.low, targetcolor_h.high, targetmaskhigh);
    
    addWeighted(targetmasklow, 1.0, targetmaskhigh, 1.0, 0.0, targetmask);
    
    // Blur for accuracy
    GaussianBlur(targetmask, targetmask, cv::Size(9, 9), 2, 2);
    threshold(targetmask, targetmask, 127, 225, THRESH_BINARY);
    
    // Apply new mask to image
    cv::Mat targetframe;
    bitwise_or(image, image, targetframe, targetmask);
    
    image = targetframe;
    
    // detect rects
    vector<vector<cv::Point> > rects;
    image = findRects(image, rects);
    image = drawRects(image, rects);
    
    // pick the 1 detected square
    if (rects.size() > 0){
        std::sort(rects.begin(), rects.end(), compareContourAreas);
        auto cnt = rects.at(0);
        auto targetRect = minAreaRect(cnt);
        //targetRect.center;
        cv::Point imageCenter = cv::Point( image.cols/2, image.rows/2 );
        line(image, targetRect.center, imageCenter, Scalar(255,255,0), 4);
    } else {
        cout << "no rects detected" << endl;
    }
    

    if (self.delegate != nil) {
        cvtColor(image,image, COLOR_BGR2RGB);
        [self.delegate imageProcessed:[UIImage imageWithCVMat: image]];
    }
}

@end