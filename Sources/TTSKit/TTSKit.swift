//
//  TTSKit.swift
//  TTSKit
//
//  Created by Chris Ameter on 8/24/25.
//

import FliteWrapper
import Foundation

public class TTSKit {
    private var voice: UnsafeMutablePointer<cst_voice>?
    private var player = PCMPlayer()
    
    public init() {
        flitew_init()
        flitew_register_eng_lang()
    }
    
    public enum TTSVoice: String {
        case cmuUsKal = "cmu_us_kal"
        case cmuUsKal16 = "cmu_us_kal16"
        case cmuUsRms = "cmu_us_rms"
        case cmuUsSlt = "cmu_us_slt"
    }
    
    public func loadVoice(_ ttsVoice: TTSVoice) {
        let builtin: UnsafeMutablePointer<cst_voice>? = {
            switch ttsVoice {
            case .cmuUsKal:
                return flitew_register_cmu_us_kal()
            case .cmuUsKal16:
                return flitew_register_cmu_us_kal16()
            case .cmuUsRms:
                return flitew_register_cmu_us_rms()
            case .cmuUsSlt:
                return flitew_register_cmu_us_slt()
            }
        }()
        
        guard let resolvedVoice = builtin else {
            voice = nil
            return
        }
        
        voice = resolvedVoice
    }
    
    public func loadVoice(at url: URL) throws {
        guard let path = url.path.cString(using: .utf8),
              let loadedVoice = flitew_voice_load(path) else {
            throw TTSKitError.unknownVoice
        }
        
        voice = loadedVoice
    }
    
    public func speak(text: String) throws {
        var samplesPtr: UnsafeMutablePointer<Int16>? = nil
        var count: Int32 = 0
        var rate: Int32 = 0
        
        if voice == nil {
            loadVoice(.cmuUsSlt)
        }
        
        let err = text.withCString { cstr in
            flitew_text_to_pcm(cstr, voice, &samplesPtr, &count, &rate)
        }
        guard err == 0, let samples = samplesPtr, count > 0, rate > 0 else {
            throw NSError(domain: "TTSKit", code: Int(err), userInfo: [NSLocalizedDescriptionKey: "flitew_text_to_pcm failed (\(err))"]) }
        defer { flitew_free_pcm(samples) }
        
        try player.playPCM(samples: samples, count: Int(count), sampleRate: Int(rate))
    }
}
