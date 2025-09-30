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
        self.init(Data(bytes: buffer, count: count))
    }
    
    func nextChunk(maxCount: UInt32) -> Data.SubSequence? {
        let sent = sentCount.withLock { $0 }
        // convert data.count into AVAudioPacketCount
        // compute remaining: avAudioCount - sent
        // if remaining is 0, return nil.  else...
        // set return size to lessor of maxCount or remaining
        // add return size to sentCount
        // update sentCount
        // return a Data subset of sent (previously) through return size, by adjusting size back into bytes
    }
}
