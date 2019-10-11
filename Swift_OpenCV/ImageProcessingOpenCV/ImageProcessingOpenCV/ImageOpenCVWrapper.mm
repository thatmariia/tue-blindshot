//
//  ImageOpenCVWrapper.m
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 11/10/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import "ImageOpenCVWrapper.h"
#import "UIImage+OpenCV.h"
#import "OpenCVCam.h"
#import "color.h"
#import <iostream>
#import <math.h>

#define SENSITIVITY 70

using namespace cv;
using namespace std;

Color targetcol_l("targetcolor_l",
            Scalar(0, 0, 255-SENSITIVITY),
            Scalar(0, 0, 255));

Color targetcol_h("targetcolor_h",
            Scalar(0, 0, 255-(SENSITIVITY/1.5)),
            Scalar(255, 255, 255));

@implementation ImageOpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

/*- (void)setDelegate: (id<OpenCVCamDelegate>) delegate
{
    OpenCVCam* cvCam = [OpenCVCam sharedInstance];
    cvCam.delegate = delegate;
}*/

+ (id)sharedInstance {
    static OpenCVCam *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initCam];
    });
    return instance;
}


+ (void)processingImage:(cv::Mat &)image {
    // mask to only have white colors
    Mat hsv;
    Mat targetmask, targetmasklow, targetmaskhigh;
    
    cvtColor(image, hsv, COLOR_BGR2HSV);
    
    // Detect white area in frame
    inRange(hsv, targetcol_l.low, targetcol_l.high,  targetmasklow);
    inRange(hsv, targetcol_h.low, targetcol_h.high, targetmaskhigh);
    
    addWeighted(targetmasklow, 1.0, targetmaskhigh, 1.0, 0.0, targetmask);
    
    
    // Blur for accuracy
    GaussianBlur(targetmask, targetmask, cv::Size(9, 9), 2, 2);
    threshold(targetmask, targetmask, 127, 225, THRESH_BINARY);
    
    // Apply new mask to image
    cv::Mat targetframe;
    bitwise_or(image, image, targetframe, targetmask);
    
    image = targetframe;
}



- (void)processImage:(cv::Mat &)image { 
    
}

@end

