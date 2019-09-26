//
//  AVController.swift
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 26/09/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

extension ViewController {
    
    func playAdvice () {
        
        // quit if no message or the message has been received before
        if (currentAudio == advice) { return }
        
        // stop playing currently played advice
        if (currentAudio != "none"){
            audioCommunicate(fileName: currentAudio, stop: true)
        }
        
        // loop play newly received message
        advice = "up"
        currentAudio = advice
        audioCommunicate(fileName: currentAudio, stop: false)
        
    }
    
    
    func audioCommunicate (fileName : String, stop : Bool) {
        
        let soundURL = Bundle.main.url(forResource: fileName, withExtension: "m4a"/*, subdirectory: "/sounds"*/)
        
        //let path = Bundle.path(forResource: fileName, ofType: "m4a", inDirectory: "/Users/mariiaturchina/Desktop/Uni/Year_2/Q1/Engineering design/Soft/BlindshotCV_iPhone/Swift_OpenCV/ImageProcessingOpenCV/ImageProcessingOpenCV/")
        //let path = "/Users/mariiaturchina/Desktop/Uni/Year_2/Q1/Engineering_design/Soft/BlindshotCV_iPhone/Swift_OpenCV/ImageProcessingOpenCV/ImageProcessingOpenCV/" + fileName + ".m4a"
        //let soundURL = URL(fileURLWithPath: path)
        // /Users/mariiaturchina/Desktop/Uni/Year_2/Q1/Engineering design/Soft/BlindshotCV_iPhone/Swift_OpenCV/ImageProcessingOpenCV/ImageProcessingOpenCV/
        
        print("sound URL *** ", soundURL as Any)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:  soundURL!)
        } catch {
            print("Error playing sound")
        }
        //audioPlayer.
        
        if (stop){
            audioPlayer.stop()
        } else {
            audioPlayer.numberOfLoops = -1
            audioPlayer.play()
        }
    }
    
}
