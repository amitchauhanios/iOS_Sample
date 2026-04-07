//
//  ViewController.swift
//  Music Demo
//
//  Created by Ongraph Technologies on 26/08/22.
//

import UIKit
import MediaPlayer
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var shuffleIMG: UIImageView!
    @IBOutlet weak var playIMG: UIImageView!
    @IBOutlet weak var playBTN: UIButton!
    
    var vc = AVPlayerViewController()
    var playerAV = AVPlayer()
    var progressMusic = UIProgressView()
    var hsider = UISlider()
    var runTime = UILabel()
    var totalTime = UILabel()
    var imageView = UIImageView()
    
    var updater : CADisplayLink! = nil
    var playFile = ""
    var shuffle = false
    var play = false
    var isURL = false
    var currentTrack = 0
    var currentPlayerTime = 0.00
    var urlSeekTime : CMTime?
    var songPlayer : AVAudioPlayer?
    var audioArr = ["HarHarShambhu","Galiyaan","Kesariya","RataLambiyan", "https://dl.espressif.com/dl/audio/ff-16b-2c-44100hz.m4a"]
    
    @IBOutlet weak var musicTView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRemoteCommandCenter()
        playFile = audioArr.first ?? ""
        musicTView.delegate = self
        musicTView.dataSource = self
        musicTView.register(UINib(nibName: "MusicTVC", bundle: nil), forCellReuseIdentifier: "MusicTVC")
        hsider.addTarget(self, action: #selector(seekMusic), for: .valueChanged)
        hsider.frame = CGRect(x: 60, y: self.playIMG.frame.minY-120, width: self.view.frame.width-120, height: 30)
        imageView.frame = CGRect(x: 0, y: self.hsider.frame.minY-120, width: 100, height: 100)
        imageView.center.x = self.view.center.x
        imageView.image = UIImage(systemName: "music.note.tv.fill")
        runTime.frame = CGRect(x: 10, y: self.playIMG.frame.minY-120, width: 50, height: 30)
        totalTime.frame = CGRect(x: self.view.frame.maxX-55, y: self.playIMG.frame.minY-120, width: 50, height: 30)
        self.view.addSubview(hsider)
        self.view.addSubview(imageView)
        self.view.addSubview(runTime)
        self.view.addSubview(totalTime)
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: vc.player?.currentItem)
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBAction func playBTN(_ sender: Any) {
            if self.play{
                self.stop()
            }
            else{
                if currentTrack <= 0 || currentTrack+1 > audioArr.count{
                    if CMTimeGetSeconds((urlSeekTime) ?? CMTime(value: Int64(0) , timescale: 1))  > 0.0000000000 {
                        self.play(_music:audioArr.first ?? "")
                        self.vc.player?.seek(to: urlSeekTime!)
                    }else{
                        self.play(_music:audioArr.first ?? "")
                    }
                }
                else{
                    if CMTimeGetSeconds((urlSeekTime) ?? CMTime(value: Int64(0) , timescale: 1))  > 0.0000000000 {
                        self.play(_music: audioArr[currentTrack])
                        self.vc.player?.seek(to: urlSeekTime!)
                    }else{
                        
                        self.play(_music: audioArr[currentTrack])
                    }
                }
                playIMG.image = UIImage(systemName: "pause.fill")
        }
        musicTView.reloadData()
        play = !play

    }
    
    
    @IBAction func shuffleBTN(_ sender: Any) {
        if !shuffle{
            let lower : UInt32 = 0
            let upper : UInt32 = UInt32(audioArr.count-1)
            let randomNumber = arc4random_uniform(upper - lower) + lower
            currentTrack = Int(randomNumber)
            playFile = audioArr[currentTrack]
            shuffleIMG.image = UIImage(systemName: "shuffle.circle.fill")
           urlSeekTime = CMTime(value: Int64(0) , timescale: 1)
        }
        else{
            shuffleIMG.image = UIImage(systemName: "shuffle.circle")
        }
        shuffle = !shuffle
    }
    
    
    @IBAction func listBTN(_ sender: Any) {
        
    }
    
    @IBAction func previousBTN(_ sender: Any) {
        
        if shuffle{
            let lower : UInt32 = 0
            let upper : UInt32 = UInt32(audioArr.count-1)
            let randomNumber = arc4random_uniform(upper - lower) + lower
            currentTrack = Int(randomNumber)
            playFile = audioArr[currentTrack]
            handelPrevious()
        }
        else{
            handelPrevious()
        }
        self.musicTView.reloadData()
        
    }
    
    
    @IBAction func nextBTN(_ sender: Any) {
        if shuffle{
            let lower : UInt32 = 0
            let upper : UInt32 = UInt32(audioArr.count-1)
            let randomNumber = arc4random_uniform(upper - lower) + lower
            currentTrack = Int(randomNumber)
            playFile = audioArr[currentTrack]
            handelNext()
        }
        else{
            handelNext()
        }
        self.musicTView.reloadData()
    }
    
    
    private var player: AVAudioPlayer?
    func play(_music :String)  {
        if let bundle = Bundle.main.path(forResource: _music, ofType: "mp3") {
            let Music = NSURL(fileURLWithPath: bundle)
            do {
                self.isURL = true
                self.player?.pause()
                playerAV = AVPlayer(url: Music as URL)
                let playerLayerAV = AVPlayerLayer(player: playerAV)
                playerLayerAV.videoGravity = .resizeAspectFill
                vc.player = playerAV
                vc.player?.play()
                let audioSessin = AVAudioSession.sharedInstance()
                do {
                    try audioSessin.setCategory(.playback, mode: .default, options: [])

                    try audioSessin.setActive(true)
                }
                if #available(iOS 14.2, *) {
                    vc.canStartPictureInPictureAutomaticallyFromInline = true
                }
                if #available(iOS 13.0, *) {
                    vc.showsTimecodes = true
                }
            } catch {
                print(error)
            }
        }
        
        else{
            if let url = URL(string: _music){
                
                do {
                    self.isURL = true
                    self.player?.pause()
                    playerAV = AVPlayer(url: url)
                    let playerLayerAV = AVPlayerLayer(player: playerAV)
                    playerLayerAV.videoGravity = .resizeAspectFill
                    vc.player = playerAV
                    vc.player?.play()
                    let audioSessin = AVAudioSession.sharedInstance()
                    do {
                        try audioSessin.setCategory(.playback, mode: .default, options: [])

                        try audioSessin.setActive(true)
                    }
                    if #available(iOS 14.2, *) {
                        vc.canStartPictureInPictureAutomaticallyFromInline = true
                    }
                    if #available(iOS 13.0, *) {
                        vc.showsTimecodes = true
                    }
                } catch {
                    print(error)
                }
            }
        }
        updater = CADisplayLink(target: self, selector: #selector(self.musicProgress))
        updater.preferredFramesPerSecond = 0
        updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    @objc func musicProgress()  {
            let normalizedTime = Float(CMTimeGetSeconds((self.vc.player?.currentItem?.currentTime())!) as! Double / (CMTimeGetSeconds((self.vc.player?.currentItem?.asset.duration)!) as! Double ) )
            self.hsider.setValue(normalizedTime, animated: true)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                self.view.layoutIfNeeded()
            }
        showTime()
        }
   
    
   
    @objc func seekMusic(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                updater.isPaused = true
            
            case .ended:
                
                let timeToSeek = TimeInterval(hsider.value * Float(CMTimeGetSeconds((self.vc.player?.currentItem?.asset.duration)!) ))
                vc.player?.seek(to: CMTime(seconds: timeToSeek, preferredTimescale: 1000000))
                urlSeekTime = CMTime(seconds: timeToSeek, preferredTimescale: 1000000)
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.updater = CADisplayLink(target: self, selector: #selector(self.musicProgress))
                    self.updater.preferredFramesPerSecond = 0
                    self.updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
                }
                
            default:
                break
            }
        }
    }
    
    
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared();
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.playIMG.image = UIImage(systemName: "pause.fill")
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.playIMG.image = UIImage(systemName: "play.fill")
            return .success
        }
    }
    
    func stop() {
        showTime()
        playIMG.image = UIImage(systemName: "play.fill")
            self.urlSeekTime = self.vc.player?.currentItem?.currentTime()
            self.vc.player?.pause()
    }
    
    func handelNext(){
        self.currentPlayerTime = 0
        currentTrack = currentTrack+1
        if currentTrack+1 > audioArr.count || currentTrack <= 0 {
            currentTrack = 0
            self.play(_music: audioArr.first ?? "")
        }
        else {
            self.play(_music: audioArr[currentTrack] )
        }
        playIMG.image = UIImage(systemName: "pause.fill")
        play = true
    }
    
    func handelPrevious(){
        self.currentPlayerTime = 0
        currentTrack = currentTrack-1
        if currentTrack <= 0{
            currentTrack = 0
            self.playFile = audioArr.first ?? ""
            self.play(_music: audioArr.first ?? "")
        }
        else {
            self.play(_music: audioArr[currentTrack] )
        }
        playIMG.image = UIImage(systemName: "pause.fill")
        play = true
    }
    
    func showTime(){
            let duration = Int(CMTimeGetSeconds((self.vc.player?.currentItem?.asset.duration)!))
            let minutes2 = duration/60
            let seconds2 = duration - minutes2 * 60
            totalTime.text = NSString(format: "%02d:%02d", minutes2,seconds2) as String
            
            //this for current time
            let currentTime1 = Int(CMTimeGetSeconds((self.vc.player?.currentItem?.currentTime())!))
            let minutes = currentTime1/60
            let seconds = currentTime1 - minutes * 60
            runTime.text = NSString(format: "%02d:%02d", minutes,seconds) as String
    }
    @objc func playerDidFinishPlaying(note: NSNotification) {
        self.nextBTN(self)
    }
}


extension ViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTVC", for: indexPath) as! MusicTVC
        cell.nameLBL.text = audioArr[indexPath.row]
        cell.playingIMG.image = UIImage.gif(name:"1732373_1cecd")
        cell.playingIMG.isHidden = true
        cell.numberLBL.text = "\(indexPath.row+1)"
        cell.playCallBack = {
            self.play(_music: self.audioArr[indexPath.row])
            self.currentTrack = indexPath.row
            self.playFile = self.audioArr[indexPath.row]
            self.playIMG.image = UIImage(systemName: "pause.fill")
            self.musicTView.reloadData()
            self.play = true
        }
        
        if currentTrack == indexPath.row{
            cell.playingIMG.isHidden = false
            cell.playIMG.isHidden = true
        }
        else{
            cell.playingIMG.isHidden = true
            cell.playIMG.isHidden = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.play(_music: audioArr[indexPath.row])
        self.currentTrack = indexPath.row
        self.playFile = audioArr[indexPath.row]
        self.playIMG.image = UIImage(systemName: "pause.fill")
    }
    
}

extension ViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("Audio player finished playing")
        }
    }
   
}


