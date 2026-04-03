import Testing
import Foundation
@testable import TTSVoiceLibrary
import TTSKit

private func allVoices() -> [TTSVoiceLibrary] {
    [
        .cmuUsAew,
        .cmuUsAwb,
        .cmuUsAxb,
        .cmuUsAup,
        .cmuUsBdl,
        .cmuUsEey,
        .cmuUsFem,
        .cmuUsGka,
        .cmuUsJmk,
        .cmuUsKsp,
        .cmuUsLjm,
        .cmuUsRms,
        .cmuUsRxr,
        .cmuUsSlt,
    ]
}

private enum VoiceFixture {
    static let directory = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Voices/TTSVoiceLibrary", isDirectory: true)
}

@Suite(.serialized) struct TTSVoiceLibraryTests {
    @Test func enumCasesMatchCheckedInVoiceFiles() throws {
        let filenames = try FileManager.default.contentsOfDirectory(
            at: VoiceFixture.directory,
            includingPropertiesForKeys: nil
        )
        .filter { $0.pathExtension == "flitevox" }
        .map { $0.deletingPathExtension().lastPathComponent }

        #expect(Set(filenames) == Set(allVoices().map(\.rawValue)))
    }

    @Test func everyLibraryVoiceLoadsThroughBundleResolution() throws {
        for voice in allVoices() {
            let tts = TTSKit()
            try tts.loadVoice(fromLibrary: voice)
        }
    }
}
