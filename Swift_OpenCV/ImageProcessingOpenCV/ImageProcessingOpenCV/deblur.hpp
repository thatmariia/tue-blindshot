//
//  deblur.hpp
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 29/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

#ifndef deblur_hpp
#define deblur_hpp

#include <opencv2/opencv.hpp>
#include <stdio.h>

class AntiBlur {
public:
    AntiBlur() {}
    
void calcPSF(cv::Mat& outputImg, cv::Size filterSize, int len, double theta);
void fftshift(cv::Mat& inputImg, cv::Mat& outputImg);
void filter2DFreq(cv::Mat& inputImg, cv::Mat& outputImg, cv::Mat& H);
void calcWnrFilter(cv::Mat& input_h_PSF, cv::Mat& output_G, double nsr);
void edgetaper(cv::Mat& inputImg, cv::Mat& outputImg, double gamma = 5.0, double beta = 0.2);

};
    
#endif /* deblur_hpp */
