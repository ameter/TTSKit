//
//  ContentView.swift
//  TTSKitDemo
//
//  Created by Chris Ameter on 8/21/25.
//

import SwiftUI
import TTSKit
import TTSVoice

struct ContentView: View {
    let tts = TTSKit()
    
    var body: some View {
        VStack {
            Button("Speak") {
                
                guard let url = clbURL() else { fatalError("invalid URL") }
                print("URL: \(url)")
                do {
                    try tts.loadVoice(at: url)
                    try tts.speak(text: "Hello, World!")
                    
                } catch {
                    print("Error speaking: \(error)")
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
