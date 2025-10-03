//
//  TTSVoiceSettings.swift
//  TTSKit
//
//  Created by Chris Ameter on 10/3/25.
//
import FliteWrapper

public class TTSVoiceSettings {
    private var voice: UnsafeMutablePointer<cst_voice>?
    
    // Default settings (set after loading a voice)
    private var defaultDuration: Float?
    private var defaultShift: Float?
    private var defaultPitchMean: Float?
    private var defaultPitchStdDeviation: Float?
    
    // Multiplies overall speaking rate.
    // 1.0 is normal; higher slows speech; lower speeds it up.
    public var duration: Float?
    
    // Multiplies the pitch contour (simple semitone/pitch scaling).
    // 1.0 neutral; 1.122 ≈ +2 semitones; 0.8909 ≈ −2.
    public var shift: Float?
    
    // Overrides the baseline pitch (Hz).
    public var pitchMean: Float?
    
    // Widens or narrows pitch variation (Hz).
    public var pitchStdDeviation: Float?
    
    public func restoreDefaults() {
        duration = defaultDuration
        shift = defaultShift
        pitchMean = defaultPitchMean
        pitchStdDeviation = defaultPitchStdDeviation
    }
    
    private func apply(_ newVoice: UnsafeMutablePointer<cst_voice>) {
        // store voice defaults
        //TODO - store voice defaults
        
        // apply custom settings
        //TODO - apply custom settings
    }
}
