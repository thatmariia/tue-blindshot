//
//  AVController.swift
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 26/09/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

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
        currentAudio = advice
        audioCommunicate(fileName: currentAudio, stop: false)
        
    }
    
    func audioCommunicate (fileName : String, stop : Bool) {
        
        if let soundURL = Bundle.main.url(forResource: fileName, withExtension: "m4a"){
            //print("sound URL *** ", soundURL as Any)
            
            do {
                try audioPlayer = AVAudioPlayer.init(contentsOf: soundURL)
                if (stop){
                    audioPlayer?.stop()
                } else {
                    audioPlayer?.numberOfLoops = -1
                    audioPlayer?.play()
                }
            } catch {
                print("Error playing sound")
            }
        } else {
            print("No such URL found")
        }
    }
}
