//
//  SoundManager.swift
//  Game
//
//  Created by Chuanxi Xiong on 4/20/16.
//  Copyright © 2016 Chuanxi Xiong. All rights reserved.
//

import Foundation
import AudioToolbox

class SoundManager {
    static let sharedInstance = SoundManager()
    private init() {}
    let urls : [NSURL?] = [NSBundle.mainBundle().URLForResource("1", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("2", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("3", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("4", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("5", withExtension: ".wav"), NSBundle.mainBundle().URLForResource("blastOff",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("trombone",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("snap",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("tap",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("slide",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("magic",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("head",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("shoulders",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("knees",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("toes",withExtension: ".wav"), NSBundle.mainBundle().URLForResource("Head Shoulders Knees and Toes",withExtension: ".wav")]
    
    
    
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
    
    func playBlastOff() {
        play(6)
    }
    
    func playTrombone() {
        play(7)
    }
    
    func playSnap() {
        play(8)
    }
    
    func playTap() {
        play(9)
    }
    
    func playSlide() {
        play(10)
    }
    
    func playMagic() {
        play(11)
    }
    
    func playBody(number : Int) {
        play(number + 11)
    }
    
    func playSong() {
        play(16)
    }
}
