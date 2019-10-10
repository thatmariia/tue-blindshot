
#import "OpenCVCam.h"
#import "UIImage+OpenCV.h"
#import "color.h"
#import <iostream>
#import <math.h>

#define ADVICE_NOT_DETECTED 0
#define ADVICE_DETECTED     1
#define ADVICE_SHOOT 2
#define ADVICE_LEFT  3
#define ADVICE_RIGHT 4
#define ADVICE_UP    5
#define ADVICE_DOWN  6

#define _USE_MATH_DEFINES

#define SENSITIVITY 70

using namespace cv;
using namespace std;

@implementation OpenCVCam

cv::Point intersection = cv::Point(0, 0);

Color targetcolor_l("targetcolor_l",
           //Scalar(0, 0, 170),
           //Scalar(140, 60, 255));
            Scalar(0, 0, 255-SENSITIVITY),
            Scalar(0, 0, 255));

Color targetcolor_h("targetcolor_h",
           //Scalar(200, 200, 200),
           //Scalar(255, 255, 255));
            Scalar(0, 0, 255-(SENSITIVITY/1.5)),
            Scalar(255, 255, 255));

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
          polylines(image, &p, &n, 1, true, Scalar(0,255,0), 1, LINE_AA);
    }
    return image;
}

bool compareContourAreas (vector<cv::Point> contour1, vector<cv::Point> contour2 ) {
    double i = fabs( contourArea(cv::Mat(contour1)) );
    double j = fabs( contourArea(cv::Mat(contour2)) );
    return ( i > j );
}

int getAdvice (float allowed_dist, cv::Point target, cv::Point frame, cv::Mat image) {
    
    float so = abs( target.y - frame.y );
    float fo = abs( target.x - frame.x );
    float sf = sqrt( pow(so,2) + pow(fo,2) );
    
    if (sf <= allowed_dist){
        return ADVICE_SHOOT;
    }
    
    float gamma = asinf(so / sf);
    float psi = (M_PI/2) - gamma;
    
    float zeta;
    string str_zeta;
    cv::Point zeta_display = cv::Point(50,50);
    // [0, 90]
    if ((target.x > frame.x) && (target.y < frame.y)){
        zeta = (M_PI/2) - psi;
        str_zeta = "1zeta = " + to_string(zeta*57.2958);
        putText(image, str_zeta, zeta_display, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        if (abs( sin(zeta) ) <= abs( cos(zeta) )){
            return ADVICE_RIGHT;
        } else {
            return ADVICE_UP;
        }
    }
    // [90, 180]
    if ((target.x < frame.x) && (target.y < frame.y)){
        zeta = (M_PI/2) + psi;
        str_zeta = "2zeta = " + to_string(zeta*57.2958);
        putText(image, str_zeta, zeta_display, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        if (abs( sin(zeta) ) <= abs (cos(zeta) )){
            return ADVICE_LEFT;
        } else {
            return ADVICE_UP;
        }
    }
    // [180, 270]
    if ((target.x < frame.x) && (target.y > frame.y)){
        zeta = M_PI+(M_PI/2) - psi;
        str_zeta = "3zeta = " + to_string(zeta*57.2958);
        putText(image, str_zeta, zeta_display, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        if (abs( sin(zeta) ) <= abs( cos(zeta) )){
            return ADVICE_LEFT;
        } else {
            return ADVICE_DOWN;
        }
    }
    // [280, 360]
    if ((target.x > frame.x) && (target.y > frame.y)){
        zeta = M_PI+(M_PI/2) + psi;
        str_zeta = "4zeta = " + to_string(zeta*57.2958);
        putText(image, str_zeta, zeta_display, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        if (abs( sin(zeta) ) <= abs( cos(zeta) )){
            return ADVICE_RIGHT;
        } else {
            return ADVICE_DOWN;
        }
    }
    return 0;
}



- (void) processImage : (cv::Mat &) image
{
    
    // mask to only have white colors
    Mat hsv;
    Mat targetmask, targetmasklow, targetmaskhigh;
    
    cvtColor(image, hsv, COLOR_BGR2HSV);
    
    // Detect white area in frame
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
    
    int advice;
    
    if (rects.size() > 0){
        std::sort(rects.begin(), rects.end(), compareContourAreas);
        auto cnt = rects.at(0);
        // pick the 1 detected square
        auto targetRect = minAreaRect(cnt);
        
        // drawing a line from target to image center
        cv::Point image_center = cv::Point( image.cols/2, image.rows/2 );
        line(image, targetRect.center, image_center, Scalar(255,255,0), 4);
        
        // displaying coordinates
        string str_image_center = to_string(image_center.x) + ", " + to_string(image_center.y);
        putText(image, str_image_center, image_center, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        string str_targetRect_center = to_string(targetRect.center.x) + ", " + to_string(targetRect.center.y);
        putText(image, str_targetRect_center, targetRect.center, FONT_HERSHEY_PLAIN, 2, Scalar(255,255,255), 2);
        
        float allowed_dist = ((targetRect.size.height + targetRect.size.width)/2) * 0.2;
        
        advice = getAdvice(allowed_dist, targetRect.center, image_center, image);
        string str_advice;
        switch (advice) {
            case ADVICE_SHOOT : str_advice = "SHOOT";
                                break;
            case ADVICE_LEFT  : str_advice = "LEFT";
                                break;
            case ADVICE_RIGHT : str_advice = "RIGHT";
                                break;
            case ADVICE_UP    : str_advice = "UP";
                                break;
            case ADVICE_DOWN  : str_advice = "DOWN";
                                break;
        }
        cv::Point advice_display = cv::Point(image.cols/2, 50);
        putText(image, str_advice, advice_display, FONT_HERSHEY_PLAIN, 4, Scalar(255,0,0), 3);
    } else {
        //cout << "no rects detected" << endl;
        advice = ADVICE_NOT_DETECTED;
    }
    
    std::string cppString = to_string(advice);
    NSString *objcMessage = [NSString stringWithCString:cppString.c_str()
                            encoding:[NSString defaultCStringEncoding]];;
    

    if (self.delegate != nil) {
        [self.delegate adviceUpdate:objcMessage];
        cvtColor(image,image, COLOR_BGR2RGB);
        [self.delegate imageProcessed:[UIImage imageWithCVMat: image]];
    }
}

@end
