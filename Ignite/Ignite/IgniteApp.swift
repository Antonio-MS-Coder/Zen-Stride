//
//  IgniteApp.swift
//  Ignite
//
//  Created by Tono Murrieta  on 21/08/25.
//

import SwiftUI

@main
struct IgniteApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true // Skip onboarding for now
    @AppStorage("appTheme") private var appTheme = "system"
    @StateObject private var themeManager = ThemeManager.shared

    init() {
        setupPremiumAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            SimpleTabView() // Use the new simplified interface
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorScheme)
                .environmentObject(themeManager)
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
    
    private func setupPremiumAppearance() {
        #if canImport(UIKit)
        // Premium Navigation Bar Appearance (Adaptive for Dark Mode)
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        navigationBarAppearance.shadowColor = .clear
        
        // Dynamic text colors for navigation bar
        navigationBarAppearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.adaptivePremiumIndigo)
        
        // Premium Tab Bar Appearance (Adaptive for Dark Mode)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Global Tint Color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.adaptivePremiumIndigo)
        
        // Text Field Appearance
        UITextField.appearance().tintColor = UIColor(Color.adaptivePremiumIndigo)
        
        // Switch Appearance
        UISwitch.appearance().onTintColor = UIColor(Color.adaptivePremiumIndigo)
        
        // Page Control Appearance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.adaptivePremiumIndigo)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(ThemeManager.shared.tertiaryText)
        #endif
    }
}