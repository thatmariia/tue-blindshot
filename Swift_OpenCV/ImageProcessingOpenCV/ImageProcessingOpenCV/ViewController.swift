//
//  ViewController.swift
//  ImageProcessingOpenCV
//
//  Created by Mariia Turchina on 25/09/2019.
//  Copyright © 2019 Mariia Turchina. All rights reserved.
//

import UIKit
import AVKit

import AVFoundation
import Foundation

struct Result {
    var advice : Int
    var image : UIImage
}

class ViewController: UIViewController, AVAssetResourceLoaderDelegate {
    
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
    
    //var openCVWrapper: OpenCVWrapper!
    var imageOpenCVWrapper : ImageOpenCVWrapper!
    
    var lastTimeSet: Double = 0
    
    var advice : String = "not_detected"
    
    var audioPlayer: AVAudioPlayer? = nil
    var currentAudio : String = "none"
    
    var player : AVPlayer?
    var output : AVPlayerItemVideoOutput!
    
    @IBOutlet weak var image_h264: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        startButton.backgroundColor = UIColor(red:0.20, green:0.80, blue:0.20, alpha:1.0)
        startButton.layer.cornerRadius = 8
        stopButton.backgroundColor = UIColor(red:1.00, green:0.27, blue:0.00, alpha:1.0)
        stopButton.layer.cornerRadius = 8
        
        print("\(ImageOpenCVWrapper.openCVVersionString())")
        
        /*openCVWrapper = OpenCVWrapper()
        openCVWrapper.setDelegate(self)

        openCVWrapper.start()*/
        
        playAdvice()
        
        // H264 decoding
        //let videoURL = Bundle.main.url(forResource: "foxVillage", withExtension: "m3u8")
        //let url = "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
        let url =  "https://wolverine.raywenderlich.com/content/ios/tutorials/video_streaming/foxVillage.m3u8"
        //let url = "https://storage.googleapis.com/muxdemofiles/mux-video-intro.mp4"
        //let url = "http://192.168.1.121:8080/video"
        //let url = "rtsp://192.168.1.121:8080/h264_pcm.sdp"
        let videoURL = URL(string: url)
        let asset = AVURLAsset(url: videoURL!, options: nil)
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
            
             let bufferAttributes: [String: Any] = [
                       String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA),
                       String(kCVPixelBufferIOSurfacePropertiesKey): [String: AnyObject](),
                       String(kCVPixelBufferOpenGLCompatibilityKey): true
                   ]
                   
            output = AVPlayerItemVideoOutput(pixelBufferAttributes: bufferAttributes)
            output.suppressesPlayerRendering = true
            
            player?.currentItem?.add(output)
            player?.play()
        
        setTimer()
        //execute()
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        return true
    }
    
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(fire(timer:)), userInfo: nil, repeats: true)
        secLeft = 600
        print("TIMER SET")
    }
    
    var timer = Timer()
    var secLeft = 0
    
    @objc func fire(timer: Timer)
    {
        secLeft -= 1
        execute()
        
        if (secLeft <= 0){
            timer.invalidate()
            print("TIMER INVALIDATED")
        }
    }

    
    func execute() {
        DispatchQueue.main.async {
            
            // Decoder
            let time = self.output.itemTime(forHostTime: CACurrentMediaTime())
            print(time)
            
            if self.output.hasNewPixelBuffer(forItemTime: time) {
                let cvPixelBuffer = self.output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
                let ciImage = CIImage(cvImageBuffer: cvPixelBuffer!)
                let temporaryContext = CIContext();
              
                let width = CVPixelBufferGetWidth(cvPixelBuffer!)
                let height = CVPixelBufferGetHeight(cvPixelBuffer!)
                let cgRect = CGRect(x: 0,y: 0, width: width, height: height)
              
                let cgImage = temporaryContext.createCGImage(ciImage, from: cgRect)
                let uiImage = UIImage(cgImage: cgImage!)
                
                //self.imageOpenCVWrapper.processingImage(uiImage)
                
                //self.imageView.image = uiImage
                self.image_h264.image = uiImage
                }
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
        //execute()
    }
    
    @IBAction func stop(_ button: UIButton) {
        //openCVWrapper.stop()
    }
}
