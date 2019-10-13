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

typedef struct Result {
    int advice;
    UIImage * image;
} Result;

@interface ImageOpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;

+ (Result)processingImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
