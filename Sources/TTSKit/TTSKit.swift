//
//  TTSKit.swift
//  TTSKit
//
//  Created by Chris Ameter on 8/24/25.
//

import FliteWrapper
import Foundation

public class TTSKit {
    public var voice: UnsafeMutablePointer<cst_voice>?
    
    private var player = PCMPlayer()
    
    public init() {
        flitew_init()
        flitew_register_eng_lang()
    }
    
    public func loadVoice(at url: URL) throws {
        guard let path = url.path.cString(using: .utf8),
              let v = flitew_voice_load(path) else { throw TTSKitError.unknownVoice }
        _ = v // use or cache
        
        flitew_add_voice(v)
        
        voice = v
        
        guard let _ = voice else { throw TTSKitError.unknownVoice }
        
        flitew_print_voices()
    }
    
    public func speak(text: String) throws {
        var samplesPtr: UnsafeMutablePointer<Int16>? = nil
        var count: Int32 = 0
        var rate: Int32 = 0
        
        guard let v = voice else { throw TTSKitError.unknownVoice }
        
        let err = text.withCString { cstr in
            flitew_text_to_pcm(cstr, v, &samplesPtr, &count, &rate)
        }
        guard err == 0, let samples = samplesPtr, count > 0, rate > 0 else {
            throw NSError(domain: "TTSKit", code: Int(err), userInfo: [NSLocalizedDescriptionKey: "flitew_text_to_pcm failed (\(err))"]) }
        defer { flitew_free_pcm(samples) }
        
        try player.playPCM(samples: samples, count: Int(count), sampleRate: Int(rate))
    }
}
