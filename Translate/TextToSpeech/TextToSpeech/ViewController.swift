//
//  ViewController.swift
//  TextToSpeech
//
//  Created by Amit on 11/10/22.
//

import UIKit

import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = "Hello, World!"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)

        // Do any additional setup after loading the view.
    }


}

