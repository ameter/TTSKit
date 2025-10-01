//
//  TTSPlayer.swift
//  TTSKit
//
//  Created by Chris Ameter on 8/24/25.
//

import AVFoundation

final class PCMPlayer {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    
    public init() {
        engine.attach(player)
        
        // Player -> Mixer (automatic negotiation)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        
        // Mixer -> Output (explicit, helps macOS)
        //        let hwIn = engine.outputNode.inputFormat(forBus: 0)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: nil)
        
        engine.prepare()
    }
    
    /// Play 16-bit mono PCM samples via AVAudioEngine.
    /// - Parameters:
    ///   - samples: Pointer to interleaved mono Int16 PCM samples.
    ///   - count: Number of Int16 samples.
    ///   - sampleRate: Sample rate in Hz (e.g., 16000).
    public func playPCM(samples: UnsafePointer<Int16>, count: Int, sampleRate: Int) throws {
        let inSampleRate = Double(sampleRate)
        
        // Ensure the engine is running before querying negotiated formats
        if !engine.isRunning { try engine.start() }
        
        // --- Convert Int16 mono @ srIn -> player's negotiated format (Float32 @ srOut, N channels) using AVAudioConverter ---
        guard let inFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: inSampleRate, channels: 1, interleaved: false) else {
            throw NSError(domain: "PCMPlayer", code: -6, userInfo: [NSLocalizedDescriptionKey: "Unable to create input AVAudioFormat (Int16)"])
        }
        
        // Use the engine's negotiated mixer input format: typically Float32, stereo, 44.1k/48k
        let outFormat = engine.mainMixerNode.inputFormat(forBus: 0)
        let outSampleRate = outFormat.sampleRate
        let channels = Int(outFormat.channelCount)
        guard channels >= 1, outFormat.commonFormat == .pcmFormatFloat32 else {
            throw NSError(domain: "PCMPlayer", code: -5, userInfo: [NSLocalizedDescriptionKey: "Unsupported output format from player: \(outFormat)"])
        }
        
        // Prepare an output buffer sized for the expected frame count after sample-rate conversion
        let estimatedOutFrames = AVAudioFrameCount((Double(count) * outSampleRate / inSampleRate).rounded(.toNearestOrEven) + 32)
        guard let outBuf = AVAudioPCMBuffer(pcmFormat: outFormat, frameCapacity: estimatedOutFrames) else {
            throw NSError(domain: "PCMPlayer", code: -8, userInfo: [NSLocalizedDescriptionKey: "Unable to create output AVAudioPCMBuffer"])
        }
        
        guard let converter = AVAudioConverter(from: inFormat, to: outFormat) else {
            throw NSError(domain: "PCMPlayer", code: -9, userInfo: [NSLocalizedDescriptionKey: "Unable to create AVAudioConverter"])
        }
        
        let dataFeeder = DataFeeder(samples, count: count)
        
        var convError: NSError?
        let convStatus = converter.convert(to: outBuf, error: &convError) { packetCount, status in
            guard let chunk = dataFeeder.nextChunk(maxCount: Int(packetCount)) else {
                status.pointee = .endOfStream
                return nil
            }
            
            // Build the input buffer *inside* the closure (no capture of AVAudioPCMBuffer)
            guard let inBuffer = AVAudioPCMBuffer(pcmFormat: inFormat, frameCapacity: UInt32(chunk.count)) else {
                status.pointee = .endOfStream
                return nil
            }
            
            chunk.data.withUnsafeBytes { ptr in
                guard let src = ptr.bindMemory(to: Int16.self).baseAddress else {
                    inBuffer.frameLength = 0
                    return
                }
                
                inBuffer.int16ChannelData?.pointee.update(from: src, count: chunk.count)
                inBuffer.frameLength = AVAudioFrameCount(chunk.count)
            }
            
            guard inBuffer.frameLength > 0 else {
                status.pointee = .endOfStream
                return nil
            }
            
            status.pointee = .haveData
            return inBuffer
        }
        
        if let convError { throw convError }
        guard convStatus != .error else {
            throw NSError(domain: "PCMPlayer", code: -10, userInfo: [NSLocalizedDescriptionKey: "AVAudioConverter reported an error"])
        }
        
        // Ensure a non-zero frameLength (converter usually sets this)
        if outBuf.frameLength == 0 {
            outBuf.frameLength = outBuf.frameCapacity
        }
        
        let buffer = outBuf
        
        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: []) { }
        player.play()
    }
}
