//
//  ViewController.swift
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 23/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

import UIKit

class ViewController: UIViewController, OpenCVCamDelegate {
    
    let advice_lib : [String : String] = ["0" : "not detected",
                                          "1" : "detected",
                                          "2" : "shoot",
                                          "3" : "left",
                                          "4" : "right",
                                          "5" : "up",
                                          "6" : "down"]
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var adviceLabel: UILabel!
    
    var startTime = CFAbsoluteTimeGetCurrent()
    
    var openCVWrapper: OpenCVWrapper!
    
    var lastTimeSet: Double = 0
    
    var advice : String = "no info";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.backgroundColor = UIColor(red:0.20, green:0.80, blue:0.20, alpha:1.0)
        startButton.layer.cornerRadius = 8
        stopButton.backgroundColor = UIColor(red:1.00, green:0.27, blue:0.00, alpha:1.0)
        stopButton.layer.cornerRadius = 8
        
        //adviceLabel.text = "meow"
        
        print("\(OpenCVWrapper.openCVVersionString())")
        
        openCVWrapper = OpenCVWrapper()
        openCVWrapper.setDelegate(self)

        openCVWrapper.start()
    }


    func imageProcessed(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    func adviceUpdate(_ message: String!) {
        advice = message
        if let new_advice =  advice_lib[message]{
           print("****** NEW ADVICE : " + "\(new_advice)")
        }
        
    }
    
    
    @IBAction func start(_ button: UIButton) {
        //openCVWrapper.start()
    }
    
    @IBAction func stop(_ button: UIButton) {
        openCVWrapper.stop()
    }
}
