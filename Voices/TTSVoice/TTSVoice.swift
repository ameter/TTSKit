//
//  TTSVoice.swift
//  
//
//  Created by Chris Ameter on 10/1/25.
//
import Foundation

public enum TTSVoice: String {
    case caleb = "cmu_us_clb"
    
    public func url() -> URL? {
        Bundle.module.url(forResource: self.rawValue, withExtension: "flitevox")
    }
}
