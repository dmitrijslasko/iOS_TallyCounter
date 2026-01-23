//
//  CounterFont.swift
//  Tally Counter
//
//  Created by user on 22/01/2026.
//

import SwiftUI

enum CounterFont: String, CaseIterable, Identifiable {
    case defaultStyle
    case rounded
    case serif
    case monospaced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .defaultStyle: return "Default"
        case .rounded: return "Rounded"
        case .serif: return "Serif"
        case .monospaced: return "Mono"
        }
    }

    var design: Font.Design {
        switch self {
        case .defaultStyle: return .default
        case .rounded: return .rounded
        case .serif: return .serif
        case .monospaced: return .monospaced
        }
    }
}
