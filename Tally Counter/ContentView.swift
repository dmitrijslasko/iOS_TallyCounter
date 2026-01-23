//
//  ContentView.swift
//  Tally Counter
//
//  Created by user on 21/01/2026.
//

import SwiftUI
import UIKit
import AudioToolbox

struct ContentView: View {
    
    // local State variables
    @State private var isAnimating = false
    @State private var showSettings = false
    
    // variable that go to AppStorage (preserved between launches)
    @State private var settings = CounterSettings()
    @AppStorage("tally_count") private var count: Int = 0
    
    @State private var isLongPressing = false
    @State private var isShaking = false
    @State private var shakeResetWorkItem: DispatchWorkItem?

    // font size variable for the counter
    var fontSize: CGFloat {
        if count > 999999 {
            return 60
        } else if count > 99999 {
            return 73
        } else if count > 9999 {
            return 82
        } else if count > 999 {
            return 95
        } else if count > 99 {
            return 120
        } else {
            return 132
        }
    }
    
    private func selectionHaptic() {
        guard settings.hapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    var body: some View {
        
        ZStack {
            ZStack {
                Color.black
                counterColorValue.opacity(0.2)
            }
            .ignoresSafeArea()
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.2),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )

            counterView

            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showSettings = true
                        }
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 28, weight: .semibold))
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 16)
                .padding(.trailing, 28)
                Spacer()
            }
        }
        .overlay {
            if showSettings {
                SettingsOverlay(
                    isPresented: $showSettings,
                    settings: $settings
                )
                .transition(.move(edge: .trailing)
                    .combined(with: .opacity))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeBegan)) { _ in
            isShaking = true
            shakeResetWorkItem?.cancel()
            let workItem = DispatchWorkItem {
                if isShaking {
                    count = 0
                    if settings.hapticsEnabled {
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    }
                }
            }
            shakeResetWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeEnded)) { _ in
            isShaking = false
            shakeResetWorkItem?.cancel()
            shakeResetWorkItem = nil
        }
    }

    private var counterView: some View {
        CounterDial(
            count: count,
            fontSize: fontSize,
            counterFontDesign: counterFontValue.design,
            color: counterColorValue,
            isAnimating: isAnimating,
            isLongPressing: isLongPressing
        )
        // single tap
        .onTapGesture {
            if settings.hapticsEnabled {
                let generator = UIImpactFeedbackGenerator(style: hapticStrengthValue.style)
                generator.prepare()
                generator.impactOccurred()
            }

            AudioServicesPlaySystemSound(tapSoundValue.systemSoundID)
            applyCountChange(settings.tapDecrements ? -settings.stepSize : settings.stepSize)

            withAnimation(.easeOut(duration: 0.2)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.2)) {
                    isAnimating = false
                }
            }
        }
        // long press
        .onLongPressGesture(
            minimumDuration: 1,
            maximumDistance: 50,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLongPressing = pressing
                }
            },
            perform: {
                AudioServicesPlaySystemSound(1105)
                count = 0
                withAnimation(.easeOut(duration: 0.2)) {
                    isLongPressing = false
                }
            }
        )
        // swipe up/down
        .simultaneousGesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    let dx = value.predictedEndTranslation.width
                    let dy = value.predictedEndTranslation.height
                    let isMostlyVertical = abs(dy) > abs(dx) * 1.2
                    guard isMostlyVertical else { return }

                    if dy > 40 {
                        selectionHaptic()
                        applyCountChange(-settings.stepSize)
                    } else if dy < -40 {
                        selectionHaptic()
                        applyCountChange(settings.stepSize)
                    }
                }
        )
    }


    private func applyCountChange(_ delta: Int) {
        let previous = count
        var newValue = count + delta
//        if newValue < 0 { newValue = 0 }
        if settings.goalEnabled, !settings.goalContinue, newValue > settings.goalValue {
            newValue = settings.goalValue
        }
        count = newValue

        if settings.goalEnabled, previous < settings.goalValue, newValue >= settings.goalValue {
            AudioServicesPlaySystemSound(1021)
        }
    }

    private var counterColorValue: Color {
        Color(hex: settings.counterColorHex) ?? .blue
    }

    private var counterColorBinding: Binding<Color> {
        Binding(
            get: { counterColorValue },
            set: { settings.counterColorHex = $0.toHex() ?? "#007AFF" }
        )
    }

    
    private var tapSoundValue: TapSound {
        TapSound(rawValue: settings.tapSoundRaw) ?? .click
    }

    private var tapSoundBinding: Binding<TapSound> {
        Binding(
            get: { tapSoundValue },
            set: { settings.tapSoundRaw = $0.rawValue }
        )
    }

    private var hapticStrengthValue: HapticStrength {
        HapticStrength(rawValue: settings.hapticStrengthRaw) ?? .heavy
    }

    private var hapticStrengthBinding: Binding<HapticStrength> {
        Binding(
            get: { hapticStrengthValue },
            set: { settings.hapticStrengthRaw = $0.rawValue }
        )
    }

    private var counterFontValue: CounterFont {
        CounterFont(rawValue: settings.counterFontRaw) ?? .defaultStyle
    }

    private var counterFontBinding: Binding<CounterFont> {
        Binding(
            get: { counterFontValue },
            set: { settings.counterFontRaw = $0.rawValue }
        )
    }
}

extension Color {
    init?(hex: String) {
        let trimmed = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleaned = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        guard cleaned.count == 6, let value = Int(cleaned, radix: 16) else { return nil }
        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}

extension Notification.Name {
    static let deviceDidShakeBegan = Notification.Name("deviceDidShakeBeganNotification")
    static let deviceDidShakeEnded = Notification.Name("deviceDidShakeEndedNotification")
}

extension UIWindow {
    open override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionBegan(motion, with: event)
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .deviceDidShakeBegan, object: nil)
    }

    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .deviceDidShakeEnded, object: nil)
    }

    open override func motionCancelled(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionCancelled(motion, with: event)
        guard motion == .motionShake else { return }
        NotificationCenter.default.post(name: .deviceDidShakeEnded, object: nil)
    }
}

#Preview {
    ContentView()
}
