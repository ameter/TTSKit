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
            // sleep for 0.2 seconds to allow time for the app to finish loading
            try? await Task.sleep(for: .milliseconds(200))
            speak()
        }
    }
    
    private func speak() {
                        
//        guard let url = TTSVoice.caleb.url() else { fatalError("invalid URL") }

        do {
//            try tts.loadVoice(at: url)
            try tts.speak(text: "Hello, World!")
            
        } catch {
            print("Error speaking: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
