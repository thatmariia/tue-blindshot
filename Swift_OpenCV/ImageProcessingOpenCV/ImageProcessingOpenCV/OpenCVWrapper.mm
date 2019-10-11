//
//  OpenCVWrapper.m
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 25/09/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import "UIImage+OpenCV.h"
#import "OpenCVCam.h"

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

- (void)setDelegate: (id<OpenCVCamDelegate>) delegate
{
    OpenCVCam* cvCam = [OpenCVCam sharedInstance];
    cvCam.delegate = delegate;
}

- (void) start
{
    OpenCVCam* cvCam = [OpenCVCam sharedInstance];
    [cvCam start];
}

- (void) stop
{
    OpenCVCam* cvCam = [OpenCVCam sharedInstance];
    [cvCam stop];
}

+ (void)passImage:(UIImage *)image
{
    // WTF DO I WRITE HERRERERERERERRE BLAAAAAH
}



@end
