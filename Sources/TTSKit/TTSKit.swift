// The Swift Programming Language
// https://docs.swift.org/swift-book

@preconcurrency import Flite
import FliteWrapper
import Foundation

public class TTSKit {
    public var voice: UnsafeMutablePointer<cst_voice>?
    
    private var player = PCMPlayer()
    
    public init() {
        flite_init()
        flitew_register_eng_lang()
    }
    
    public func loadVoice(at url: URL) throws {
        guard let path = url.path.cString(using: .utf8),
              let v = flite_voice_load(path) else { throw TTSKitError.unknownVoice }
        _ = v // use or cache
        
        flite_add_voice(v)
        
        voice = v
        
        guard let _ = voice else { throw TTSKitError.unknownVoice }
        
        flitew_print_voices()
    }
    
    //    public func speak(text: String) throws {
    //
    //        guard let voice = voice else { throw TTSKitError.unknownVoice }
    //        //        flite_register_cmu_us_rms();
    //
    //        //        fitew_print_voices()
    //
    //        //        guard let v = flite_voice_select("cmu_us_clb") else { throw TTSKitError.unknownVoice }
    //
    //        _ = text.utf8CString.withUnsafeBufferPointer { buffer in
    //            flite_text_to_speech(buffer.baseAddress, voice, "wav")
    //        }
    //    }
    
    @MainActor
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
    
    //    @MainActor
    //    func listVoices() {
    //        var v = flite_voice_list
    //        while v != nil {
    //            if let car = val_car(v), let name = val_string(car) {
    //                print("Voice: \(String(cString: name))")
    //            }
    //            v = val_cdr(v)
    //        }
    //    }
}
