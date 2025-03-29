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
    
    init() {
        // Cambiar el nombre que aparece en la barra de navegación
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.textPrimary)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.textPrimary)]
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(dataStore)
        }
    }
}
