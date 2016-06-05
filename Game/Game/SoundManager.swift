//
//  SoundManager.swift
//  Wee Coders
//
//  Created by Chuanxi Xiong on 4/20/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import Foundation
import AudioToolbox

// This is a SoundManager class that is a Singleton. Different UIViewControllers share the same object.
class SoundManager {
    static let sharedInstance = SoundManager()
    private init() {}
    
    // The urls of all the sound resources are put into this array
    let urls : [NSURL?] = [NSBundle.mainBundle().URLForResource("1", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("2", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("3", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("4", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("5", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("blastOff",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("trombone",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("snap",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("tap",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("slide",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("jump",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("head",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("shoulders",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("knees",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("toes",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("Head Shoulders Knees and Toes",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("magic",withExtension: ".wav")]
    
    /// This method plays one of the source resources
    /// - Parameters:
    ///     - number: index of the sound clip in the urls array
    /// - Attributions: https://ff8276a3d76177159b643022d4cc86d3f633fc86.googledrive.com/host/0B3XzcKIiWyccdlgtOW42N0xQZjQ/MPCS51030/2016-Winter/Session6/MPCS51030-2016-Winter-Lecture6.pdf
    func play(number : Int) {
        let url = urls[number - 1]
        var start: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url!, &start)
        
        AudioServicesAddSystemSoundCompletion(start, nil, nil, {
            sound, context in
            AudioServicesRemoveSystemSoundCompletion(sound)
            AudioServicesDisposeSystemSoundID(sound)
            }, nil)
        
        AudioServicesPlayAlertSound(start)
    }
    
    // play the blast off audio
    func playBlastOff() {
        play(6)
    }
    
    // play the trambone sound
    func playTrombone() {
        play(7)
    }
    
    // play the sound effect for snapping into place
    func playSnap() {
        play(8)
    }
    
    // play the sound effect for tapping a puzzle piece
    func playTap() {
        play(9)
    }
    
    // play the sound effect for sliding back the piece
    func playSlide() {
        play(10)
    }
    
    // play the sound effect when the sheep is jumping
    func playJump() {
        play(11)
    }
    
    // play the sound clip for the body part
    func playBody(number : Int) {
        play(number + 11)
    }
    
    // play the whole song
    func playSong() {
        play(16)
    }
    
    // play the magic sound effect
    func playMagic() {
        play(17)
    }
}
