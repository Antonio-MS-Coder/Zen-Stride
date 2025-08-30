import SwiftUI

struct MinimalMainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var dashboardVM = DashboardViewModel()
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        if !hasCompletedOnboarding {
            MinimalOnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            TabView(selection: $selectedTab) {
                MinimalDashboardView(viewModel: dashboardVM)
                    .tabItem {
                        Label("Today", systemImage: selectedTab == 0 ? "house.fill" : "house")
                    }
                    .tag(0)
                
                MinimalHabitsView()
                    .tabItem {
                        Label("Habits", systemImage: selectedTab == 1 ? "list.bullet.rectangle.fill" : "list.bullet.rectangle")
                    }
                    .tag(1)
                
                MinimalProgressView()
                    .tabItem {
                        Label("Progress", systemImage: selectedTab == 2 ? "chart.bar.fill" : "chart.bar")
                    }
                    .tag(2)
            }
            .accentColor(.notionAccent)
            .onAppear {
                setupAppearance()
            }
        }
    }
    
    private func setupAppearance() {
        #if canImport(UIKit)
        // Minimal tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.shadowColor = UIColor(Color.notionBorder)
        
        // Configure item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.notionTextTertiary)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.notionTextTertiary),
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.notionAccent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.notionAccent),
            .font: UIFont.systemFont(ofSize: 10)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.white
        navAppearance.shadowColor = UIColor(Color.notionBorder)
        navAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.notionText),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.notionText),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        #endif
    }
}