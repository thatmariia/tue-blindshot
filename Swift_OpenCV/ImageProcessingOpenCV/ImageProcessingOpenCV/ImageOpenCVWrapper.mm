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

@implementation ImageOpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

- (void)setDelegate: (id<OpenCVCamDelegate>) delegate
{
    OpenCVCam* cvCam = [OpenCVCam sharedInstance];
    cvCam.delegate = delegate;
}

+ (void)passImage:(UIImage *)image
{
    // WTF DO I WRITE HERRERERERERERRE BLAAAAAH
}



@end

