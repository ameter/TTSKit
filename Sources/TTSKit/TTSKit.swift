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
    
    public enum TTSBuiltinVoice {
        case male       // cmu_us_rms
        case female     // cmu_us_slt
    }
    
    public func loadVoice(_ ttsBuiltinVoice: TTSBuiltinVoice) {
        let builtin: UnsafeMutablePointer<cst_voice>? = {
            switch ttsBuiltinVoice {
            case .male:
                return flitew_register_cmu_us_rms()
            case .female:
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
            loadVoice(.female)
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
