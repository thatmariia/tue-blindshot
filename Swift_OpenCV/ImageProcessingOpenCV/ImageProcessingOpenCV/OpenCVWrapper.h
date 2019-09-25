//
//  OpenCVWrapper.h
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 23/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenCVCamDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

+ (NSString *)openCVVersionString;

- (void)setDelegate: (id<OpenCVCamDelegate>) delegate;
- (void)start;
- (void)stop;

@end

NS_ASSUME_NONNULL_END
