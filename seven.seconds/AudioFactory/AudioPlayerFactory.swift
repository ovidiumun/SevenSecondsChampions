//
//  AudioPlayerFactory.swift
//  seven.seconds
//
//  Created by Ovidiu Muntean on 05.09.2023.
//

import UIKit
import AVFoundation
import GameKit

class AudioPlayerFactory {
    static func createAudioPlayer(fileName: String, fileType: String) -> AVAudioPlayer? {
        if let audioURL = Bundle.main.url(forResource: fileName, withExtension: fileType) {
            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.prepareToPlay()
                return audioPlayer
            } catch {
                print("Error creating audio player: \(error.localizedDescription)")
            }
        }
        return nil
    }
}
