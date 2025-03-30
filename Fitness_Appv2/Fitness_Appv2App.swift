//
//  Fitness_Appv2App.swift
//  Fitness_Appv2
//
//  Created by Kem Jian Diaz Mena on 29/3/25.
//

import SwiftUI

// Estructura para gestionar las imágenes/iconos de atletas
struct AthleteImages {
    // Usar SF Symbols en lugar de imágenes externas
    static let runningIcons = ["figure.run", "figure.outdoor.cycle", "figure.hiking"]
    static let strengthIcons = ["dumbbell", "figure.strengthtraining.traditional", "figure.core.training"]
    static let yogaIcons = ["figure.mind.and.body", "figure.yoga", "figure.cooldown"]
    static let cyclingIcons = ["figure.outdoor.cycle", "bicycle", "figure.rolling"]
    static let swimmingIcons = ["figure.pool.swim", "drop.fill", "water.waves"]
    static let generalIcons = ["figure.mixed.cardio", "heart.fill", "bolt.fill"]
    
    static func getIconForWorkoutType(_ type: WorkoutType) -> String {
        switch type {
        case .running:
            return runningIcons.randomElement() ?? "figure.run"
        case .strength:
            return strengthIcons.randomElement() ?? "dumbbell"
        case .yoga:
            return yogaIcons.randomElement() ?? "figure.yoga"
        case .cycling:
            return cyclingIcons.randomElement() ?? "bicycle"
        case .swimming:
            return swimmingIcons.randomElement() ?? "figure.pool.swim"
        default:
            return generalIcons.randomElement() ?? "figure.mixed.cardio"
        }
    }
    
    static func getRandomAthleteIcon() -> String {
        let allIcons = runningIcons + strengthIcons + yogaIcons + cyclingIcons + swimmingIcons + generalIcons
        return allIcons.randomElement() ?? "figure.run"
    }
    
    // Colores para los iconos según el tipo de entrenamiento
    static func getColorForWorkoutType(_ type: WorkoutType) -> Color {
        switch type {
        case .running:
            return .blue
        case .strength:
            return .orange
        case .yoga:
            return .purple
        case .cycling:
            return .green
        case .swimming:
            return .cyan
        default:
            return .indigo
        }
    }
}

@main
struct Fitness_Appv2App: App {
    // Crear una instancia del AppDataStore que será compartida en toda la app
    @StateObject var dataStore = AppDataStore()
    @Environment(\.colorScheme) var systemColorScheme
    @State private var userColorScheme: ColorScheme? = nil
    @State private var isShowingOnboarding = false
    
    init() {
        // Cambiar el nombre que aparece en la barra de navegación
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.textPrimary)]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(PureLifeColors.textPrimary)]
        
        // Check if onboarding has been completed
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        self._isShowingOnboarding = State(initialValue: !hasCompletedOnboarding)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isShowingOnboarding {
                    OnboardingView(isShowingOnboarding: $isShowingOnboarding)
                        .environmentObject(dataStore)
                } else {
                    MainTabView()
                        .environmentObject(dataStore)
                        .onAppear {
                            updateColorScheme()
                        }
                        .onChange(of: dataStore.currentUser.userPreferences.userAppearance) { _, _ in
                            updateColorScheme()
                        }
                        .preferredColorScheme(userColorScheme)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LogoutAndShowOnboarding"))) { _ in
                // Show onboarding when receiving the logout notification
                isShowingOnboarding = true
            }
        }
    }
    
    private func updateColorScheme() {
        switch dataStore.currentUser.userPreferences.userAppearance {
        case .light:
            userColorScheme = .light
        case .dark:
            userColorScheme = .dark
        case .system:
            userColorScheme = nil // Use system setting
        }
    }
}
