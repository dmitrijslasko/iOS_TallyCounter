//
//  SettingsOverlay.swift
//  Tally Counter
//
//  Created by user on 22/01/2026.
//

import SwiftUI
import AudioToolbox

struct SettingsOverlay: View {
    
    struct AppDivider: View {
        var body: some View {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
                .padding(.vertical, 8)
        }
    }
    
    private var draftCounterColor: Color {
        Color(hex: draft.counterColorHex) ?? .blue
    }
    
    @Binding var isPresented: Bool
    @Binding var settings: CounterSettings
    
    @State private var draft: DraftCounterSettings
    

    private let allowedColors: [Color] = [
        .gray, .white, .red, .orange, .yellow, .green, .mint, .blue, .indigo, .purple, .pink, .brown
    ]

    private func colorsEqual(_ lhs: Color, _ rhs: Color) -> Bool {
        lhs.toHex() == rhs.toHex()
    }

    init(isPresented: Binding<Bool>, settings: Binding<CounterSettings>) {
        _isPresented = isPresented
        _settings = settings
        _draft = State(initialValue: settings.wrappedValue.toDraft())
    }

    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            Color.black.opacity(0.8)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 12) {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.red)
                            .frame(width: 44, height: 44)
                            .background(.black.opacity(0.35))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        settings.apply(draft)
                        isPresented = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.green)
                            .frame(width: 44, height: 44)
                            .background(.black.opacity(0.35))
                            .clipShape(Circle())
                    }
                }

                VStack(alignment: .leading, spacing: 18) {
                    
                    AppDivider()
                    
                    Text("Counter Color")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(allowedColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                Color.white.opacity(
                                                    colorsEqual(color, draftCounterColor) ? 0.9 : 0.2
                                                ),
                                                lineWidth: colorsEqual(color, draftCounterColor) ? 2 : 0
                                            )
                                    )
                                    .onTapGesture {
                                        draft.counterColorHex = color.toHex() ?? "#007AFF"

                                    }
                            }
                        }
                        .frame(height: 52)
                    }
                    // .background(Color.white.opacity(0.08))
                    // .cornerRadius(10)
                }

                AppDivider()

                VStack(alignment: .leading, spacing: 8) {
                    Picker("Tap Sound", selection: $draft.tapSound) {
                        ForEach(TapSound.allCases) { sound in
                            Text(sound.title).tag(sound)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: draft.tapSound) { newSound in
                        AudioServicesPlaySystemSound(newSound.systemSoundID)
                    }
                    .onAppear {
                        let normalAttributes: [NSAttributedString.Key: Any] = [
                            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
                        ]
                        let selectedAttributes: [NSAttributedString.Key: Any] = [
                            .foregroundColor: UIColor.black
                        ]
                        UISegmentedControl.appearance()
                            .setTitleTextAttributes(normalAttributes, for: .normal)
                        UISegmentedControl.appearance()
                            .setTitleTextAttributes(selectedAttributes, for: .selected)
                    }
                }

                AppDivider()


                HStack {
                    Text("Step Size")
                        .foregroundStyle(.white)

                    Spacer()

                    TextField("", value: $draft.stepSize, format: .number)
                        .foregroundStyle(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    UIApplication.shared.sendAction(
                                        #selector(UIResponder.resignFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil
                                    )
                                }
                            }
                        }


                    Stepper("", value: $draft.stepSize, in: 1...1000)
                        .labelsHidden()
                        .tint(.white)
                }
                .onChange(of: draft.stepSize) { newValue in
                    if newValue < 1 { draft.stepSize = 1 }
                    if newValue > 1000 { draft.stepSize = 1000 }
                }
                    
                    Toggle("Reverse Count", isOn: $draft.tapDecrements)
                    .foregroundStyle(.white)

                AppDivider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Font Style")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Picker("Counter Font", selection: $draft.counterFont) {
                        ForEach(CounterFont.allCases) { font in
                            Text(font.title).tag(font)
                        }
                    }
                    .pickerStyle(.segmented)
                    .opacity(1.0)
                }

                AppDivider()

                    Toggle("Haptic Feedback", isOn: $draft.hapticsEnabled)
                    .foregroundStyle(.white)

                    Picker("Haptic Strength", selection: $draft.hapticStrength) {
                        ForEach(HapticStrength.allCases) { strength in
                            Text(strength.title).tag(strength)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.red)
                    .opacity(draft.hapticsEnabled ? 1.0 : 0.4)
                    .disabled(!draft.hapticsEnabled)

                AppDivider()

                    Toggle("Enable Goal", isOn: $draft.goalEnabled)
                    .foregroundStyle(.white)

                HStack {
                    Text("Goal")
                        .foregroundStyle(.white)

                    Spacer()

                    TextField("", value: $draft.goalValue, format: .number)
                        .foregroundStyle(.white)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 90)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(8)

                    Stepper("", value: $draft.goalValue, in: 1...10000)
                        .labelsHidden()
                        .tint(.white)
                }
                .opacity(draft.goalEnabled ? 1 : 0.4)
                .disabled(!draft.goalEnabled)
                .onChange(of: draft.goalValue) { newValue in
                    if newValue < 1 { draft.goalValue = 1 }
                    if newValue > 10000 { draft.goalValue = 10000 }
                }

                Toggle("Continue After Goal", isOn: $draft.goalContinue)
                    .opacity(draft.goalEnabled ? 1 : 0.4)
                    .disabled(!draft.goalEnabled)
                    .foregroundStyle(.white)

                Divider()
                    .frame(height: 2)
                    .background(Color.white.opacity(0.6))

                Text("v1.0.0\nDeveloped by Dmitrijs Lasko | 2026\nUI by Anastasiya Badun")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                }
                .padding(20)
            }
            .frame(maxHeight: .infinity)
            .background(draftCounterColor.opacity(0.1))
            .shadow(radius: 10)
        }
    }
}
