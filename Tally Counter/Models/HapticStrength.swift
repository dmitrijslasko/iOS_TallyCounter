//
//  HapticStrength.swift
//  Tally Counter
//
//  Created by user on 22/01/2026.
//

import UIKit

enum HapticStrength: String, CaseIterable, Identifiable {
    case light
    case medium
    case heavy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        }
    }

    var style: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        }
    }
}

