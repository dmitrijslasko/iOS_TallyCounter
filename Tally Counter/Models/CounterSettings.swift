//
//  CounterSettings.swift
//  Tally Counter
//
//  Created by user on 23/01/2026.
//

import SwiftUI

struct CounterSettings {
    @AppStorage("counter_color_hex") var counterColorHex: String = "#007AFF"
    @AppStorage("tap_sound") var tapSoundRaw: String = TapSound.click.rawValue
    @AppStorage("step_size") var stepSize: Int = 1

    @AppStorage("haptics_enabled") var hapticsEnabled: Bool = true
    @AppStorage("haptic_strength") var hapticStrengthRaw: String = HapticStrength.heavy.rawValue

    @AppStorage("goal_enabled") var goalEnabled: Bool = false
    @AppStorage("goal_value") var goalValue: Int = 100
    @AppStorage("goal_continue") var goalContinue: Bool = true

    @AppStorage("counter_font") var counterFontRaw: String = CounterFont.defaultStyle.rawValue
    @AppStorage("tap_decrements") var tapDecrements: Bool = false
}

extension CounterSettings {

    var counterColor: Color {
        Color(hex: counterColorHex) ?? .blue
    }

    var tapSound: TapSound {
        TapSound(rawValue: tapSoundRaw) ?? .click
    }

    var hapticStrength: HapticStrength {
        HapticStrength(rawValue: hapticStrengthRaw) ?? .heavy
    }

    var counterFont: CounterFont {
        CounterFont(rawValue: counterFontRaw) ?? .defaultStyle
    }
}

struct DraftCounterSettings {
    var counterColorHex: String
    var tapSound: TapSound
    var stepSize: Int
    var hapticsEnabled: Bool
    var hapticStrength: HapticStrength
    var goalEnabled: Bool
    var goalValue: Int
    var goalContinue: Bool
    var counterFont: CounterFont
    var tapDecrements: Bool
}

extension CounterSettings {
    func toDraft() -> DraftCounterSettings {
        DraftCounterSettings(
            counterColorHex: counterColorHex,
            tapSound: tapSound,
            stepSize: stepSize,
            hapticsEnabled: hapticsEnabled,
            hapticStrength: hapticStrength,
            goalEnabled: goalEnabled,
            goalValue: goalValue,
            goalContinue: goalContinue,
            counterFont: counterFont,
            tapDecrements: tapDecrements
        )
    }

    mutating func apply(_ draft: DraftCounterSettings) {
        counterColorHex = draft.counterColorHex
        tapSoundRaw = draft.tapSound.rawValue
        stepSize = draft.stepSize
        hapticsEnabled = draft.hapticsEnabled
        hapticStrengthRaw = draft.hapticStrength.rawValue
        goalEnabled = draft.goalEnabled
        goalValue = draft.goalValue
        goalContinue = draft.goalContinue
        counterFontRaw = draft.counterFont.rawValue
        tapDecrements = draft.tapDecrements
    }
}
