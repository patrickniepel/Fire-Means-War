//
//  AudioPlayer.swift
//  Fire Means War
//
//  Created by Patrick Niepel on 04.06.17.
//  Copyright © 2017 Patrick Niepel. All rights reserved.
//

import UIKit
import AVFoundation

/** Handles the music and volume of the game */
class AudioPlayer: NSObject {
    
    /** Player for all track except the battle theme */
    var audioPlayer : AVAudioPlayer? = nil
    var volume : Float = 0
    
    /** Second player for the battle theme. Plays in the background */
    var battlePlayer : AVAudioPlayer? = nil
    
    // Loads the last used volume from the UserDefaults
    fileprivate func loadVolume() {
        
        let vol = UserDefaults.standard.float(forKey: "volume")
        
        // Default value when no value was saved / available
        if vol == 0 {
            audioPlayer!.volume = 0.5
        }
        
        // Value when player set the volume to 0
        else if vol == -1 {
            audioPlayer!.volume = 0
        }
            
        //Every other volume value
        else {
            audioPlayer!.volume = vol
        }
        
        volume = audioPlayer!.volume
    }
    
    /** Plays the fire sound when a ship got attacked */
    func playFire() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "fire", ofType: "mp3")!))
        }
        catch {}
        
        audioPlayer!.prepareToPlay()
        audioPlayer!.volume = volume
        audioPlayer!.play()
    }
    
    /** Plays the missed sound when no ship got attacked */
    func playMissed() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "missed", ofType: "mp3")!))
        }
        catch {}
        
        audioPlayer!.prepareToPlay()
        audioPlayer!.volume = volume
        audioPlayer!.play()
    }
    
    /** Track that gets played when in menu */
    func playMain() {
        
        /** When match was terminated -> stop background player */
        if battlePlayer != nil {
            battlePlayer!.stop()
            battlePlayer = nil
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "main", ofType: "wav")!))
        }
        catch {}
        
        audioPlayer!.prepareToPlay()
        
        loadVolume()
        audioPlayer!.volume = 0
        audioPlayer!.play()
        audioPlayer!.setVolume(volume, fadeDuration: 2)
        
        audioPlayer!.numberOfLoops = 99
    }
    
    /** Plays the horn sound when match is about to start */
    func playHorn() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "horn", ofType: "mp3")!))
        }
        catch {}

        audioPlayer!.prepareToPlay()
        audioPlayer!.volume = volume
        audioPlayer!.play()
    }
    
    /** Plays the battle theme when match has begun */
    func playBattle() {
        
        do {
            battlePlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "battle", ofType: "wav")!))
        }
        catch {}
        
        battlePlayer!.prepareToPlay()
        battlePlayer!.volume = 0
        battlePlayer!.play()
        battlePlayer!.setVolume(volume / 5, fadeDuration: 2)
        
        battlePlayer!.numberOfLoops = 99
    }
    
    /** Plays the victory theme */
    func playVictory() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "victory", ofType: "mp3")!))
        }
        catch {}
        
        audioPlayer!.prepareToPlay()
        audioPlayer!.volume = volume
        audioPlayer!.play()
    }
    
    /** Plays the defeat theme */
    func playDefeat() {
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "defeat", ofType: "mp3")!))
        }
        catch {}
        
        audioPlayer!.prepareToPlay()
        audioPlayer!.volume = volume
        audioPlayer!.play()
    }
    
    /** Sets the volume to 0 within 2 seconds (Fade out -> transition between menu and beginning of the match) */
    func volumeToZero() {
        audioPlayer!.setVolume(0, fadeDuration: 2)
    }
    
    func volumeToZeroBattleTheme() {
        battlePlayer!.setVolume(0, fadeDuration: 2)
    }
    
    /** Stops the audioPlayer manually */
    func stop() {
        
        if audioPlayer != nil {
            audioPlayer!.stop()
            audioPlayer = nil
        }
        
    }
    
    /** Sets the volume of the audioPlayer to the given value */
    func setVolume(vol: Float) {
        audioPlayer!.volume = vol
        volume = vol
    }
    
    /** Pauses and resumes the battle player */
    func pauseResumeBattlePlayer(pause: Bool) {
        if pause {
            if battlePlayer != nil {
                battlePlayer!.pause()
            }
        }
        else {
            if battlePlayer != nil {
                battlePlayer!.play()
            }
        }
    }

}
