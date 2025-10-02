import Testing
@testable import TTSKit
import Foundation

nonisolated(unsafe) let tts = TTSKit()

@Test func loadVoice() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    
//    flitew_register_eng_lang()
//    print( tts.loadVoice(at: url))
//    flitew_print_voices()
    
    do {
        try tts.speak(text: "This is a test.")
    } catch {
        print("error: \(error)")
    }
}
