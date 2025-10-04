//
//  TTSVoiceSettings.swift
//  TTSKit
//
//  Created by Chris Ameter on 10/3/25.
//
import FliteWrapper

public class TTSVoiceSettings {
    private static let durationFeatureKey = "duration_stretch"
    private static let shiftFeatureKey = "f0_shift"
    private static let pitchMeanFeatureKey = "int_f0_target_mean"
    private static let pitchStdDeviationFeatureKey = "int_f0_target_stddev"
    
    private var voice: UnsafeMutablePointer<cst_voice>?
    
    // Default settings (set after loading a voice)
    private var defaultDuration: Float?
    private var defaultShift: Float?
    private var defaultPitchMean: Float?
    private var defaultPitchStdDeviation: Float?
    
    // Multiplies overall speaking rate.
    // 1.0 is normal; higher slows speech; lower speeds it up.
    public var duration: Float? {
        didSet {
            guard let voice else { return }
            let setting = duration ?? defaultDuration
            if let setting {
                flitew_voice_set_float_feature(voice, Self.durationFeatureKey, setting)
            }
        }
    }
    
    // Multiplies the pitch contour (simple semitone/pitch scaling).
    // 1.0 neutral; 1.122 ≈ +2 semitones; 0.8909 ≈ −2.
    public var shift: Float? {
        didSet {
            guard let voice else { return }
            let setting = shift ?? defaultShift
            if let setting {
                flitew_voice_set_float_feature(voice, Self.shiftFeatureKey, setting)
            }
        }
    }
    
    // Overrides the baseline pitch (Hz).
    public var pitchMean: Float? {
        didSet {
            guard let voice else { return }
            let setting = pitchMean ?? defaultPitchMean
            if let setting {
                flitew_voice_set_float_feature(voice, Self.pitchMeanFeatureKey, setting)
            }
        }
    }
    
    // Widens or narrows pitch variation (Hz).
    public var pitchStdDeviation: Float? {
        didSet {
            guard let voice else { return }
            let setting = pitchStdDeviation ?? defaultPitchStdDeviation
            if let setting {
                flitew_voice_set_float_feature(voice, Self.pitchStdDeviationFeatureKey, setting)
            }
        }
    }
    
    public func restoreDefaults() {
        duration = defaultDuration
        shift = defaultShift
        pitchMean = defaultPitchMean
        pitchStdDeviation = defaultPitchStdDeviation
    }
    
    func apply(_ newVoice: UnsafeMutablePointer<cst_voice>) {
        voice = newVoice
        defaultDuration = flitew_voice_get_float_feature(newVoice, Self.durationFeatureKey)
        defaultShift = flitew_voice_get_float_feature(newVoice, Self.shiftFeatureKey)
        defaultPitchMean = flitew_voice_get_float_feature(newVoice, Self.pitchMeanFeatureKey)
        defaultPitchStdDeviation = flitew_voice_get_float_feature(newVoice, Self.pitchStdDeviationFeatureKey)
        
//        if defaultDuration == -999 || defaultShift == -999 || defaultPitchMean == -999 || defaultPitchStdDeviation == -999 {
//            fatalError("got something unexpected from flitew_voice_get_float_feature")
//        }
        
        print(defaultDuration, defaultShift, defaultPitchMean, defaultPitchStdDeviation)
        
        if let duration {
            flitew_voice_set_float_feature(newVoice, Self.durationFeatureKey, duration)
        }
        
        if let shift {
            flitew_voice_set_float_feature(newVoice, Self.shiftFeatureKey, shift)
        }
        
        if let pitchMean {
            flitew_voice_set_float_feature(newVoice, Self.pitchMeanFeatureKey, pitchMean)
        }
        
        if let pitchStdDeviation {
            flitew_voice_set_float_feature(newVoice, Self.pitchStdDeviationFeatureKey, pitchStdDeviation)
        }
    }
}
