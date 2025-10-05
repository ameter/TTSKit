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
            Button("Speak Male Builtin", action: speakMaleBuiltin)
            Button("Speak with Callback", action: speakCallback)
            Button("Speak with Library", action: speakLibraryVoice)
            Button("Speak Queued", action: speakQueued)
            
            Button("Stop", action: tts.stop)
                .padding(.top)
            Button("Pause", action: tts.pause)
            Button("Resume", action: tts.resume)
        }
        .padding()
        .task {
            // sleep for 0.25 seconds to allow time for the app to finish loading
            try? await Task.sleep(for: .milliseconds(250))
            speak()
        }
    }
    
    private func speak() {
        do {
            try tts.speak(text: "Hello, World!")
        } catch {
            print("Error speaking: \(error)")
        }
    }
    
    private func speakMaleBuiltin() {
        tts.loadVoice(.male)
        do {
            try tts.speak(text: "Hello, World!")
        } catch {
            print("Error speaking: \(error)")
        }
    }
    
    private func speakCallback() {
        do {
            try tts.speak(text: "Hello, World!") {
                print("Finished speaking!")
            }
        } catch {
            print("Error speaking: \(error)")
        }
    }
    
    private func speakQueued() {
        do {
            try tts.speak(text: "Welcome to our whimsical weather report from the Mars Colony Café, where today’s forecast calls for scattered sandstorms, a 30% chance of meteor showers, and barometric pressure best described as “hang onto your helmet.” In culinary news, Chef Robo-Rita is unveiling her zero-gravity souffle, which finally decided to land after orbiting the kitchen for three days. And over in the community garden, the baby cacti have graduated to their first pair of training spines—proud hydroponic parents everywhere are beaming. Stay tuned for traffic on the rover route; spoilers: everyone is still stuck behind a wandering rock.")
            
            try tts.speak(text: "This will be spoken after the previous one finishes because of the queue parameter.", queue: true)
        } catch {
            print("Error speaking: \(error)")
        }
    }
    
    private func speakLibraryVoice() {
        do {
            try tts.loadVoice(fromLibrary: .cmuUsEey) // requires TTSVoiceLibrary (included in the TTSKKit package) is linked and imported
            try tts.speak(text: "Hello, World!")
        } catch {
            print("Error speaking: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
