//
//  TapSound.swift
//  Tally Counter
//
//  Created by user on 22/01/2026.
//

import AudioToolbox

enum TapSound: String, CaseIterable, Identifiable {
    case click
    case pop
    case tick
    case chime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .click: return "Click"
        case .pop: return "Pop"
        case .tick: return "Tick"
        case .chime: return "Chime"
        }
    }

    var systemSoundID: SystemSoundID {
        switch self {
        case .click: return 1104
        case .pop: return 1103
        case .tick: return 1157
        case .chime: return 1113
        }
    }
}
