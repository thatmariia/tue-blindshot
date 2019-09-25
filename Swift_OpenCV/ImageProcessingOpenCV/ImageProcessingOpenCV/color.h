//
//  color.h
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 31/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

//
//  color.hpp
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 31/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

#ifndef color_h
#define color_h

#include <opencv2/opencv.hpp>

class Color {
public:
    cv::Scalar high;
    cv::Scalar low;
    std::string name;
    
    Color(std::string name, cv::Scalar low, cv::Scalar high) : name(name), low(low), high(high) {
        
    }
};

#endif /* color_hpp */
