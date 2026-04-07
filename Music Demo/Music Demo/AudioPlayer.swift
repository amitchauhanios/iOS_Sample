////
////  AudioPlayer.swift
////  Music Demo
////
////  Created by Ongraph Technologies on 26/08/22.
////
//
//import Foundation
//import AVFoundation
//import AVKit
//
//class AudioPlayer {
//   static let sharedInstance = AudioPlayer()
//   private var player: AVAudioPlayer?
//   private var updater : CADisplayLink! = nil
//   private var playerAV = AVPlayer()
//   private var vc = AVPlayerViewController()
//    
//    func play(_music :String , isURL : Bool  )  {
//        if let bundle = Bundle.main.path(forResource: _music, ofType: "mp3") {
//            let Music = NSURL(fileURLWithPath: bundle)
//            do {
//               //isURL = false
//                self.vc.player?.pause()
//                player = try AVAudioPlayer(contentsOf:Music as URL)
//                guard let audioPlayer = player else { return }
//                audioPlayer.numberOfLoops = 0
//                audioPlayer.prepareToPlay()
//                audioPlayer.play()
//                updater = CADisplayLink(target: self, selector: #selector(self.musicProgress))
//                updater.preferredFramesPerSecond = 1
//                updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
//                let audioSessin = AVAudioSession.sharedInstance()
//                do {
//                    try audioSessin.setCategory(.playback, mode: .default, options: [])
//                    
//                    try audioSessin.setActive(true)
//                }
//                catch {
//                    print(error)
//                }
//            } catch {
//                print(error)
//            }
//        }
//        
//        else{
//            if let url = URL(string: _music){
//                
//                do {
//                   // isURL = true
//                    self.player?.pause()
//                    playerAV = AVPlayer(url: url)
//                    let playerLayerAV = AVPlayerLayer(player: playerAV)
//                   // playerLayerAV.frame = self.hsider.bounds
//                    playerLayerAV.videoGravity = .resizeAspectFill
//                    vc.player = playerAV
//                    vc.player?.play()
//                    updater = CADisplayLink(target: self, selector: #selector(self.musicProgress))
//                    updater.preferredFramesPerSecond = 1
//                    updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
//                    let audioSessin = AVAudioSession.sharedInstance()
//                    do {
//                        try audioSessin.setCategory(.playback, mode: .default, options: [])
//                        
//                        try audioSessin.setActive(true)
//                    }
////                    self.addChild(vc)
//                    if #available(iOS 14.2, *) {
//                        vc.canStartPictureInPictureAutomaticallyFromInline = true
//                    }
//                    if #available(iOS 13.0, *) {
//                        vc.showsTimecodes = true
//                    }
//                } catch {
//                    print(error)
//                }
//            }
//        }
//    }
//    
//    
//    @objc func musicProgress()  {
//        if isURL{
//            let normalizedTime = Float(CMTimeGetSeconds((self.vc.player?.currentItem?.currentTime())!) as! Double / (CMTimeGetSeconds((self.vc.player?.currentItem?.asset.duration)!) as! Double ) )
//            self.hsider.setValue(normalizedTime, animated: true)
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
//                self.view.layoutIfNeeded()
//            }
//        }
//        
//        else{
//            if let audioPlayer = player  {
//                if !audioPlayer.isPlaying && play {
//                    self.nextBTN(self)
//               }
//            }
//            
//            let normalizedTime = Float(self.player?.currentTime as! Double / (self.player?.duration as! Double ) )
//            self.hsider.setValue(normalizedTime, animated: true)
//            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
//                self.view.layoutIfNeeded()
//            }
//        }
//        showTime()
//    }
//}
