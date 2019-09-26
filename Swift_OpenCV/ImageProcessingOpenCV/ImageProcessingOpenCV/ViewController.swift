//
//  ViewController.swift
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 23/05/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class ViewController: UIViewController, OpenCVCamDelegate {
    
    let advice_lib : [String : String] = ["0" : "not_detected",
                                          "1" : "detected",
                                          "2" : "shoot",
                                          "3" : "left",
                                          "4" : "right",
                                          "5" : "up",
                                          "6" : "down"]
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    var startTime = CFAbsoluteTimeGetCurrent()
    
    var openCVWrapper: OpenCVWrapper!
    
    var lastTimeSet: Double = 0
    
    var advice : String = "not_detected"
    
    var audioPlayer: AVAudioPlayer? = nil
    var currentAudio : String = "none"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.backgroundColor = UIColor(red:0.20, green:0.80, blue:0.20, alpha:1.0)
        startButton.layer.cornerRadius = 8
        stopButton.backgroundColor = UIColor(red:1.00, green:0.27, blue:0.00, alpha:1.0)
        stopButton.layer.cornerRadius = 8
        
        print("\(OpenCVWrapper.openCVVersionString())")
        
        openCVWrapper = OpenCVWrapper()
        openCVWrapper.setDelegate(self)

        openCVWrapper.start()
        
        playAdvice()
    }


    func imageProcessed(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
    
    func adviceUpdate(_ message: String!) {
        if let new_advice =  advice_lib[message]{
            advice = new_advice
            playAdvice()
            print("****** NEW ADVICE : " + "\(new_advice)")
        }
    }
    
    
    @IBAction func start(_ button: UIButton) {
        //openCVWrapper.start()
    }
    
    @IBAction func stop(_ button: UIButton) {
        openCVWrapper.stop()
    }
    
    func playAdvice () {
        
        // quit if no message or the message has been received before
        if (currentAudio == advice) { return }
        
        // stop playing currently played advice
        if (currentAudio != "none"){
            audioCommunicate(fileName: currentAudio, stop: true)
        }
        
        // loop play newly received message
        currentAudio = advice
        audioCommunicate(fileName: currentAudio, stop: false)
        
    }
    
    func audioCommunicate (fileName : String, stop : Bool) {
        
        let soundURL = Bundle.main.url(forResource: fileName, withExtension: "m4a")
        //let path = Bundle.main.path(forResource: fileName, ofType: "m4a")!
        //let soundNSURL = NSURL(fileURLWithPath: path)
        //let soundURL : URL = soundNSURL as URL
        
        print("sound URL *** ", soundURL as Any)
        
        do {
            try audioPlayer = AVAudioPlayer.init(contentsOf: soundURL!)
            if (stop){
                audioPlayer?.stop()
            } else {
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.play()
            }
        } catch {
            print("Error playing sound")
        }
    }
    
}
