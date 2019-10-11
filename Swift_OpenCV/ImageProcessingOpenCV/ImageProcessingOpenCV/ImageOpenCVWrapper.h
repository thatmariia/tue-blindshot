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

NS_ASSUME_NONNULL_BEGIN

@interface ImageOpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;

- (void)setDelegate: (id<OpenCVCamDelegate>) delegate;
+ (void)passImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
