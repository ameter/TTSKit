//
//  Substitutions.swift
//  TTSKit
//
//  Created by Chris on 4/3/26.
//

enum Substitutions {
    static func check(_ text: String) -> String {
        values[text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)] ?? text
    }
    
    private static let values: [String: String] = [
        "to" : "too",
    ]
}
