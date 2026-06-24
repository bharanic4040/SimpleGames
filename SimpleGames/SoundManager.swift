//
//  SoundManager.swift
//  SimpleGames
//
//  Created by lavanya chennu on 24/06/26.
//

import AVFoundation

final class SoundManager {
    
    static let shared = SoundManager()
    
    private var player: AVAudioPlayer?
    
    func playFlip() {
        guard let url = Bundle.main.url(forResource: "flip", withExtension: "mp3")
        else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("Failed to play sound:", error)
        }
    }
}
