//
//  SplashView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI

struct SplashView: View {
    var onFinished: (() -> Void)?

    @State private var isAnimating = false
    @State private var opacity: Double = 0.0
    @State private var scale: CGFloat = 0.85

    var body: some View {
        ZStack {
            Color.bgBase
                .ignoresSafeArea()

            // Ambient background glow
            Circle()
                .fill(Color.paisaPrimary.opacity(0.12))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .scaleEffect(isAnimating ? 1.2 : 0.8)

            VStack(spacing: PaisaSpacing.lg) {
                // App Logo Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.paisaPrimary, Color(hex: "#00E5A5")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 96, height: 96)
                        .shadow(color: Color.paisaPrimary.opacity(0.45), radius: 24, x: 0, y: 10)

                    Image(systemName: "indianrupeesign")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                }
                .scaleEffect(scale)

                VStack(spacing: PaisaSpacing.xs) {
                    Text("Paisa")
                        .font(PaisaFont.bold(38, design: .rounded))
                        .foregroundStyle(Color.textPrimary)

                    Text("Personal Expense Tracker")
                        .font(PaisaFont.callout())
                        .foregroundStyle(Color.textSecondary)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1.0
                scale = 1.0
                isAnimating = true
            }

            // Automatically transition to the main app after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    onFinished?()
                }
            }
        }
        .onTapGesture {
            // Allow tap to skip splash immediately
            onFinished?()
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
