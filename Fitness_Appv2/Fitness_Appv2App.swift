//
//  Fitness_Appv2App.swift
//  Fitness_Appv2
//
//  Created by Kem Jian Diaz Mena on 29/3/25.
//

import SwiftUI

@main
struct Fitness_Appv2App: App {
    // Crear una instancia del AppDataStore que será compartida en toda la app
    @StateObject var dataStore = AppDataStore()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataStore)
        }
    }
}
