//
//  DataFeeder.swift
//  TTSKit
//
//  Created by Chris Ameter on 9/30/25.
//
import Foundation
import os.lock

final class DataFeeder<Element>: Sendable where Element: Sendable {
    private let data: Data
    private let sentCount = OSAllocatedUnfairLock(initialState: 0)
    
    init(_ data : Data) {
        self.data = data
    }
    
    convenience init(_ buffer: UnsafePointer<Element>, count: Int) {
        let byteCount = count * MemoryLayout<Element>.stride
        self.init(Data(bytes: UnsafeRawPointer(buffer), count: byteCount))
    }
    
    func nextChunk(maxCount: Int) -> DataFeeder.Output? {
        let bytesPerPacket = MemoryLayout<Element>.stride
        guard bytesPerPacket > 0 else { return nil }

        return sentCount.withLock { sent -> DataFeeder.Output? in
            let totalPackets = data.count / bytesPerPacket
            guard sent < totalPackets else { return nil }

            let remainingPackets = totalPackets - sent
            let requestedPackets = min(maxCount, remainingPackets)
            guard requestedPackets > 0 else { return nil }
            let byteOffset = sent * bytesPerPacket
            let byteCount = requestedPackets * bytesPerPacket

            sent += requestedPackets

            let start = data.index(data.startIndex, offsetBy: byteOffset)
            let end = data.index(start, offsetBy: byteCount)
            return DataFeeder.Output(data: data[start..<end], count: requestedPackets)
        }
    }
    
    struct Output {
        let data: Data.SubSequence
        let count: Int
    }
}
