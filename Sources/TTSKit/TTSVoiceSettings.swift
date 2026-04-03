//
//  TTSVoiceSettings.swift
//  TTSKit
//
//  Created by Chris Ameter on 10/3/25.
//
import FliteWrapper

public class TTSVoiceSettings {
    private var voice: UnsafeMutablePointer<cst_voice>?
    
    // Multiplies overall speaking rate.
    // 1.0 is normal; higher slows speech; lower speeds it up.
    public var duration: Float? {
        didSet {
            setDuration()
        }
    }
    
    // Multiplies the pitch contour (simple semitone/pitch scaling).
    // 1.0 neutral; 1.122 ≈ +2 semitones; 0.8909 ≈ −2.
    public var shift: Float? {
        didSet {
            setShift()
        }
    }
    
    // Overrides the baseline pitch (Hz).
    public var pitchMean: Float? {
        didSet {
            setPitchMean()
        }
    }
    
    // Widens or narrows pitch variation (Hz).
    public var pitchStdDeviation: Float? {
        didSet {
            setPitchStdDeviation()
        }
    }
    
    // Some words can be difficult when passed as short single word utterances.
    // This setting enabled a substitution table to improve pronounciation in these cases.
    public var substitutionsEnabled = true
    
    public func clear() {
        duration = nil
        shift = nil
        pitchMean = nil
        pitchStdDeviation = nil
    }
    
    func apply(_ newVoice: UnsafeMutablePointer<cst_voice>) {
        voice = newVoice
        
        setDuration()
        setShift()
        setPitchMean()
        setPitchStdDeviation()
    }
    
    private func setDuration() {
        guard let voice else { return }
        if let duration {
            flitew_voice_set_duration_stretch(voice, duration)
        } else {
            flitew_voice_clear_duration_stretch(voice)
        }
    }
    
    private func setShift() {
        guard let voice else { return }
        if let shift {
            flitew_voice_set_f0_shift(voice, shift)
        } else {
            flitew_voice_clear_f0_shift(voice)
        }
    }
    
    private func setPitchMean() {
        guard let voice else { return }
        if let pitchMean {
            flitew_voice_set_f0_target_mean(voice, pitchMean)
        } else {
            flitew_voice_clear_f0_target_mean(voice)
        }
    }
    
    private func setPitchStdDeviation() {
        guard let voice else { return }
        if let pitchStdDeviation {
            flitew_voice_set_f0_target_stddev(voice, pitchStdDeviation)
        } else {
            flitew_voice_clear_f0_target_stddev(voice)
        }
    }
}
