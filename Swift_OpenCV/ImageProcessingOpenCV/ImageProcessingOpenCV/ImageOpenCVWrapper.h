//
//  ImageOpenCVWrapper.h
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 11/10/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenCVCamDelegate.h"
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageOpenCVWrapper : NSObject<CvVideoCameraDelegate>

@property CvVideoCamera* cam;
@property id<OpenCVCamDelegate> delegate;

+ (NSString *)openCVVersionString;

+ (id) sharedInstance;

//- (void)setDelegate: (id<OpenCVCamDelegate>) delegate;

+ (void)processingImage:(cv::Mat &)image;

@end

NS_ASSUME_NONNULL_END
