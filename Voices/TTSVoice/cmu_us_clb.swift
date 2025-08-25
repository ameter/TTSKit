//
//  cmu_us_clb.swift
//  TTSKit
//
//  Created by Chris Ameter on 8/22/25.
//
import Foundation

public func clbURL() -> URL? {
    Bundle.module.url(forResource: "cmu_us_clb", withExtension: "flitevox")
}
