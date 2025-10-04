//
//  ContentView.swift
//  TTSKitDemo
//
//  Created by Chris Ameter on 8/21/25.
//

import SwiftUI
import TTSKit
import TTSVoiceLibrary

struct ContentView: View {
    let tts = TTSKit()
    
    var body: some View {
        VStack {
            Button("Speak", action: speak)
        }
        .padding()
        .task {
            // sleep for 0.25 seconds to allow time for the app to finish loading
            try? await Task.sleep(for: .milliseconds(250))
            speak()
        }
    }
    
    private func speak() {
        Task {
            do {
                try tts.loadVoice(fromLibrary: .cmuUsEey)
                tts.settings.pitchMean = 1000
                try tts.speak(text: "Hello, World!") {
                    print("done")
                }
                try? await Task.sleep(for: .milliseconds(2000))
                tts.settings.pitchMean = nil
                try tts.speak(text: "Hello, World!") {
                    print("done again")
                }
            } catch {
                print("Error speaking: \(error)")
            }
        }
    }
}

#Preview {
    ContentView()
}
