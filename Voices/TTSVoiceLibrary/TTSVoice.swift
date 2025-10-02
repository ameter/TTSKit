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
    case cmuUsAew = "cmu_us_aew"
    case cmuUsAwb = "cmu_us_awb"
    case cmuUsAxb = "cmu_us_axb"
    case cmuUsAup = "cmu_us_aup"
    case cmuUsBdl = "cmu_us_bdl"
    case cmuUsEey = "cmu_us_eey"
    case cmuUsFem = "cmu_us_fem"
    case cmuUsGka = "cmu_us_gka"
    case cmuUsJmk = "cmu_us_jmk"
    case cmuUsKsp = "cmu_us_ksp"
    case cmuUsLjm = "cmu_us_ljm"
    case cmuUsRxr = "cmu_us_rxr"
    case cmuUsSlt = "cmu_us_slt"
}

public extension TTSKit {
    func loadVoice(fromLibrary voice: TTSVoiceLibrary) throws {
        guard let url = Bundle.module.url(forResource: voice.rawValue, withExtension: "flitevox") else {
            throw TTSKitError.unknownVoice
        }
        try loadVoice(at: url)
    }
}
