//
//  OpenCVCamDelegate.h
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 25/09/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

#ifndef OpenCVCamDelegate_h
#define OpenCVCamDelegate_h

@protocol OpenCVCamDelegate <NSObject>
- (void) imageProcessed: (UIImage*) image;
- (void) adviceUpdate: (NSString*) message;
@end

#endif /* OpenCVCamDelegate_h */
