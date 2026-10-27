//
//  MyApp.swift
//  Paisa
//
//  Created by Vasu Chovatiya on 26/10/26.
//

import SwiftUI
import SwiftData

@main
struct PaisaApp: App {

    private let container = ModelContainerFactory.makeContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .modelContainer(container)
        }
    }
}
