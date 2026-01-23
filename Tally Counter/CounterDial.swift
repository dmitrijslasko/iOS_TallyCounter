//
//  CounterDial.swift
//  Tally Counter
//
//  Created by user on 23/01/2026.
//


import SwiftUI

struct CounterDial: View {
    let count: Int
    let fontSize: CGFloat
    let counterFontDesign: Font.Design
    let color: Color

    let isAnimating: Bool
    let isLongPressing: Bool

    var body: some View {
        Text(count, format: .number.grouping(.never))
            .font(.system(size: fontSize, weight: .bold, design: counterFontDesign))
            .blur(radius: isAnimating ? 8 : 0)
            .foregroundStyle(color)
            .frame(width: 320, height: 320)
            .background(
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.25),
                                color.opacity(0.15),
                                color.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 135,
                            endRadius: isAnimating ? 200 : 160
                        )
                    )
            )
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 25)
            )
            .scaleEffect(isAnimating ? 1.2 : 1.0)
            .opacity(isAnimating ? 0.6 : 1.0)
            .scaleEffect(isLongPressing ? 0.9 : 1.0)
    }
}

#Preview {
    CounterDial(
        count: 123,
        fontSize: 132,
        counterFontDesign: .rounded,
        color: .blue,
        isAnimating: false,
        isLongPressing: false
    )
    .preferredColorScheme(.dark)
}
