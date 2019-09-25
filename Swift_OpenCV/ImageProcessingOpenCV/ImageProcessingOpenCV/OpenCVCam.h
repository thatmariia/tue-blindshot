//
//  OpenCVCam.h
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 23/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//


#ifndef OpenCVCam_h
#define OpenCVCam_h

#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import "OpenCVCamDelegate.h"
#import "Bot.h"

@interface OpenCVCam : NSObject<CvVideoCameraDelegate>

@property CvVideoCamera* cam;
@property id<OpenCVCamDelegate> delegate;

+ (id) sharedInstance;

- (void) start;
- (void) stop;
- (void) initCam;

@end

#endif /* OpenCVCam_h */
