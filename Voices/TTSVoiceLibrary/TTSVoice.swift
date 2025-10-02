//
//  TTSVoice.swift
//  
//
//  Created by Chris Ameter on 10/1/25.
//
import Foundation
import TTSKit

public enum TTSVoiceLibrary: String {
    case caleb = "cmu_us_rms"
    
//    public func url() -> URL? {
//
//    }
}

public extension TTSKit {
    func loadVoice(fromLibrary voice: TTSVoiceLibrary) {
        let url = Bundle.module.url(forResource: voice.rawValue, withExtension: "flitevox")
    }
}
