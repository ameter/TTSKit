//
//  ContentView.swift
//  TTSKitDemo
//
//  Created by Chris Ameter on 8/21/25.
//

import SwiftUI
import TTSKit

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
                        
//        guard let url = TTSVoice.caleb.url() else { fatalError("invalid URL") }
        tts.loadVoice(.female)
        
        do {

            try tts.speak(text: "Hello, World!")
            
        } catch {
            print("Error speaking: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
