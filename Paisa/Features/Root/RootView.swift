//
//  RootView.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

struct RootView: View {
    @State private var isShowingSplash: Bool = true

    var body: some View {
        ZStack {
            TabBarView()

            if isShowingSplash {
                SplashView {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        isShowingSplash = false
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 1.05)))
                .zIndex(1)
            }
        }
        .background(Color.bgBase.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

// MARK: - Backwards Compatibility Alias
typealias ContentView = RootView

#Preview {
    RootView()
        .modelContainer(ModelContainerFactory.makePreviewContainer())
}
