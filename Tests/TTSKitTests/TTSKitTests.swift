import Testing
@testable import TTSKit
import FliteWrapper
import Foundation

private enum TTSKitTestError: Error {
    case expectedFailure
}

private enum VoiceFixture {
    static let directory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Voices/TTSVoiceLibrary", isDirectory: true)

    static func url(named name: String = "cmu_us_awb") -> URL {
        directory.appendingPathComponent(name).appendingPathExtension("flitevox")
    }
}

private actor CompletionTracker {
    private var completed = false

    func markCompleted() {
        completed = true
    }

    func isCompleted() -> Bool {
        completed
    }
}

private func waitUntil(
    timeout: Duration = .seconds(5),
    pollInterval: Duration = .milliseconds(20),
    condition: @escaping @Sendable () async -> Bool
) async -> Bool {
    let clock = ContinuousClock()
    let deadline = clock.now + timeout

    while clock.now < deadline {
        if await condition() {
            return true
        }
        try? await Task.sleep(for: pollInterval)
    }

    return await condition()
}

private func decode<Element>(_ output: DataFeeder<Element>.Output, as _: Element.Type = Element.self) -> [Element] {
    output.data.withUnsafeBytes { rawBuffer in
        Array(rawBuffer.bindMemory(to: Element.self))
    }
}

private func synthesizeAndWait(
    tts: TTSKit,
    text: String,
    queue: Bool = false,
    exerciseControls: Bool = false
) async throws {
    let tracker = CompletionTracker()

    try tts.speak(text: text, queue: queue) {
        Task {
            await tracker.markCompleted()
        }
    }

    if exerciseControls {
        tts.pause()
        tts.resume()
    }

    let completed = await waitUntil {
        await tracker.isCompleted()
    }
    #expect(completed)
}

@Suite(.serialized) struct TTSKitTests {
    @Test func dataFeederReturnsSequentialChunksFromUnsafeBuffer() throws {
        let samples: [Int16] = [100, 200, 300, 400, 500]
        let feeder = samples.withUnsafeBufferPointer { buffer in
            DataFeeder(buffer.baseAddress!, count: buffer.count)
        }

        let first = try #require(feeder.nextChunk(maxCount: 2))
        let second = try #require(feeder.nextChunk(maxCount: 2))
        let third = try #require(feeder.nextChunk(maxCount: 2))

        #expect(first.count == 2)
        #expect(second.count == 2)
        #expect(third.count == 1)
        #expect(decode(first) == [100, 200])
        #expect(decode(second) == [300, 400])
        #expect(decode(third) == [500])
        #expect(feeder.nextChunk(maxCount: 1) == nil)
    }

    @Test func dataFeederDoesNotAdvanceOnNonPositiveRequests() throws {
        let feeder = DataFeeder<UInt8>(Data([1, 2, 3]))

        #expect(feeder.nextChunk(maxCount: 0) == nil)
        #expect(feeder.nextChunk(maxCount: -4) == nil)

        let chunk = try #require(feeder.nextChunk(maxCount: 2))
        #expect(chunk.count == 2)
        #expect(Array(chunk.data) == [1, 2])
    }

    @Test func dataFeederIsSafeUnderConcurrentConsumption() async {
        let values = Array(0..<256).map(UInt16.init)
        let feeder = values.withUnsafeBufferPointer { buffer in
            DataFeeder(buffer.baseAddress!, count: buffer.count)
        }

        actor Collector {
            var chunks: [UInt16] = []

            func append(_ values: [UInt16]) {
                chunks += values
            }

            func snapshot() -> [UInt16] {
                chunks
            }
        }

        let collector = Collector()

        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<8 {
                group.addTask {
                    while let chunk = feeder.nextChunk(maxCount: 7) {
                        await collector.append(decode(chunk, as: UInt16.self))
                    }
                }
            }
        }

        let collected = await collector.snapshot()
        #expect(collected.count == values.count)
        #expect(Set(collected) == Set(values))
    }

    @Test func voiceSettingsApplyPendingValuesAndClearFeatures() throws {
        flitew_init()

        let settings = TTSVoiceSettings()
        settings.duration = 1.3
        settings.shift = 0.9
        settings.pitchMean = 145
        settings.pitchStdDeviation = 18

        settings.clear()
        #expect(settings.duration == nil)
        #expect(settings.shift == nil)
        #expect(settings.pitchMean == nil)
        #expect(settings.pitchStdDeviation == nil)

        settings.duration = 0.85
        settings.shift = 1.1
        settings.pitchMean = 160
        settings.pitchStdDeviation = 22

        let voice = try #require(flitew_register_cmu_us_slt())
        let features = try #require(voice.pointee.features)

        settings.apply(voice)

        #expect(feat_present(features, "duration_stretch") != 0)
        #expect(abs(feat_float(features, "duration_stretch") - 0.85) < 0.0001)
        #expect(feat_present(features, "f0_shift") != 0)
        #expect(abs(feat_float(features, "f0_shift") - 1.1) < 0.0001)
        #expect(feat_present(features, "int_f0_target_mean") != 0)
        #expect(abs(feat_float(features, "int_f0_target_mean") - 160) < 0.0001)
        #expect(feat_present(features, "int_f0_target_stddev") != 0)
        #expect(abs(feat_float(features, "int_f0_target_stddev") - 22) < 0.0001)

        settings.duration = 1.5
        #expect(abs(feat_float(features, "duration_stretch") - 1.5) < 0.0001)

        settings.clear()
        #expect(feat_present(features, "duration_stretch") == 0)
        #expect(feat_present(features, "f0_shift") == 0)
        #expect(feat_present(features, "int_f0_target_mean") == 0)
        #expect(feat_present(features, "int_f0_target_stddev") == 0)
    }

    @Test func loadVoiceAtThrowsUnknownVoiceForMissingFile() throws {
        let tts = TTSKit()
        let missingURL = VoiceFixture.directory
            .appendingPathComponent("does_not_exist")
            .appendingPathExtension("flitevox")

        do {
            try tts.loadVoice(at: missingURL)
            throw TTSKitTestError.expectedFailure
        } catch TTSKitError.unknownVoice {
        }
    }

    @Test func speakAutoLoadsTheDefaultVoiceAndCompletesPlayback() async throws {
        let tts = TTSKit()
        try await synthesizeAndWait(tts: tts, text: "Automatic voice loading.")
        tts.stop()
    }

    @Test func loadVoiceAtSupportsQueuedPlaybackAndControls() async throws {
        let tts = TTSKit()
        try tts.loadVoice(at: VoiceFixture.url())
        try await synthesizeAndWait(
            tts: tts,
            text: "Queued playback coverage.",
            queue: true,
            exerciseControls: true
        )
        tts.stop()
    }

    @Test func builtinMaleVoiceCanSynthesizeSpeech() async throws {
        let tts = TTSKit()
        tts.loadVoice(.male)
        try await synthesizeAndWait(tts: tts, text: "Builtin male voice.")
        tts.stop()
    }
}
