//
//  Zen_StrideApp.swift
//  Zen Stride
//
//  Created by Tono Murrieta  on 21/08/25.
//

import SwiftUI

@main
struct Zen_StrideApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        setupPremiumAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                SimpleTabView() // Use the new simplified interface
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .preferredColorScheme(.light) // Premium design optimized for light mode
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .preferredColorScheme(.light)
            }
        }
    }
    
    private func setupPremiumAppearance() {
        #if canImport(UIKit)
        // Premium Navigation Bar Appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.98)
        navigationBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        navigationBarAppearance.shadowColor = .clear
        
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.premiumGray1),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationBarAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.premiumGray1),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().tintColor = UIColor(Color.premiumIndigo)
        
        // Premium Tab Bar Appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.98)
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Global Tint Color
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(Color.premiumIndigo)
        
        // Text Field Appearance
        UITextField.appearance().tintColor = UIColor(Color.premiumIndigo)
        
        // Switch Appearance
        UISwitch.appearance().onTintColor = UIColor(Color.premiumIndigo)
        
        // Page Control Appearance
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.premiumIndigo)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.premiumGray5)
        #endif
    }
}