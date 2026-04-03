import Testing
@testable import FliteWrapper
import Foundation

private enum VoiceFixture {
    static let directory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Voices/TTSVoiceLibrary", isDirectory: true)

    static func url(named name: String = "cmu_us_slt") -> URL {
        directory.appendingPathComponent(name).appendingPathExtension("flitevox")
    }
}

@Suite(.serialized) struct FliteWrapperTests {
    @Test func builtinVoiceRegistrationReturnsNamedVoices() throws {
        flitew_init()

        let male = try #require(flitew_register_cmu_us_rms())
        let female = try #require(flitew_register_cmu_us_slt())

        let maleName = try #require(male.pointee.name).withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        }
        let femaleName = try #require(female.pointee.name).withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        }

        #expect(maleName == "rms")
        #expect(femaleName == "slt")
        #expect(male != female)
    }

    @Test func voiceLoadRejectsMissingFileAndLoadsKnownVoiceFile() throws {
        flitew_init()
        flitew_register_eng_lang()

        let missingVoice = "/tmp/ttskit-missing-voice.flitevox".withCString { path in
            flitew_voice_load(path)
        }
        #expect(missingVoice == nil)

        let voice = try #require(VoiceFixture.url().path.withCString { path in
            flitew_voice_load(path)
        })
        let name = try #require(voice.pointee.name).withMemoryRebound(to: CChar.self, capacity: 1) {
            String(cString: $0)
        }

        #expect(name == "cmu_us_slt")
    }

    @Test func voiceFeatureHelpersMutateExpectedFeatureKeys() throws {
        flitew_init()

        let voice = try #require(flitew_register_cmu_us_slt())
        let features = try #require(voice.pointee.features)

        flitew_voice_clear_duration_stretch(voice)
        flitew_voice_clear_f0_shift(voice)
        flitew_voice_clear_f0_target_mean(voice)
        flitew_voice_clear_f0_target_stddev(voice)

        flitew_voice_set_duration_stretch(voice, 1.25)
        flitew_voice_set_f0_shift(voice, 0.85)
        flitew_voice_set_f0_target_mean(voice, 140)
        flitew_voice_set_f0_target_stddev(voice, 24)

        #expect(feat_present(features, "duration_stretch") != 0)
        #expect(abs(feat_float(features, "duration_stretch") - 1.25) < 0.0001)
        #expect(feat_present(features, "f0_shift") != 0)
        #expect(abs(feat_float(features, "f0_shift") - 0.85) < 0.0001)
        #expect(feat_present(features, "int_f0_target_mean") != 0)
        #expect(abs(feat_float(features, "int_f0_target_mean") - 140) < 0.0001)
        #expect(feat_present(features, "int_f0_target_stddev") != 0)
        #expect(abs(feat_float(features, "int_f0_target_stddev") - 24) < 0.0001)

        flitew_voice_clear_duration_stretch(voice)
        flitew_voice_clear_f0_shift(voice)
        flitew_voice_clear_f0_target_mean(voice)
        flitew_voice_clear_f0_target_stddev(voice)

        #expect(feat_present(features, "duration_stretch") == 0)
        #expect(feat_present(features, "f0_shift") == 0)
        #expect(feat_present(features, "int_f0_target_mean") == 0)
        #expect(feat_present(features, "int_f0_target_stddev") == 0)

        flitew_voice_set_duration_stretch(nil, 1.0)
        flitew_voice_clear_duration_stretch(nil)
    }

    @Test func textToPCMRejectsInvalidArguments() {
        var samples: UnsafeMutablePointer<Int16>?
        var count: Int32 = 0
        var rate: Int32 = 0

        let result = flitew_text_to_pcm(nil, nil, &samples, &count, &rate)

        #expect(result == 1)
        #expect(samples == nil)
        #expect(count == 0)
        #expect(rate == 0)

        flitew_free_pcm(nil)
    }

    @Test func textToPCMSynthesizesNonEmptyAudioForLoadedVoice() throws {
        flitew_init()
        flitew_register_eng_lang()

        let voice = try #require(VoiceFixture.url().path.withCString { path in
            flitew_voice_load(path)
        })

        var samples: UnsafeMutablePointer<Int16>?
        var count: Int32 = 0
        var rate: Int32 = 0

        let result = "Wrapper synthesis coverage.".withCString { text in
            flitew_text_to_pcm(text, voice, &samples, &count, &rate)
        }

        #expect(result == 0)
        #expect(count > 0)
        #expect(rate > 0)

        let pcm = try #require(samples)
        defer { flitew_free_pcm(pcm) }

        let samplePrefix = Array(UnsafeBufferPointer(start: pcm, count: min(Int(count), 128)))
        #expect(!samplePrefix.isEmpty)
        #expect(samplePrefix.contains(where: { $0 != 0 }))
    }
}
