import SwiftUI
import CoreData

struct PremiumMainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedTab") private var selectedTab = 0
    
    @StateObject private var dashboardViewModel: ElegantDashboardViewModel
    @State private var tabScale: [CGFloat] = [1.0, 1.0, 1.0, 1.0]
    @State private var showingOnboarding = false
    
    init() {
        let context = PersistenceController.shared.container.viewContext
        _dashboardViewModel = StateObject(wrappedValue: ElegantDashboardViewModel(context: context))
        
        // Configure tab bar appearance
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial)
        
        // Configure item appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.premiumGray3)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.premiumGray3),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.premiumIndigo)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.premiumIndigo),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }
    
    var body: some View {
        ZStack {
            if !hasCompletedOnboarding {
                PremiumOnboardingView()
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                TabView(selection: $selectedTab) {
                    // Dashboard Tab
                    PremiumDashboardView(viewModel: dashboardViewModel)
                        .tabItem {
                            Label("Today", systemImage: selectedTab == 0 ? "house.fill" : "house")
                        }
                        .tag(0)
                        .onAppear { animateTab(0) }
                    
                    // Habits Tab
                    PremiumHabitsListView(viewModel: dashboardViewModel)
                        .tabItem {
                            Label("Habits", systemImage: selectedTab == 1 ? "target" : "circle.dashed")
                        }
                        .tag(1)
                        .onAppear { animateTab(1) }
                    
                    // Progress Tab
                    PremiumProgressView(viewModel: dashboardViewModel)
                        .tabItem {
                            Label("Progress", systemImage: selectedTab == 2 ? "chart.line.uptrend.xyaxis" : "chart.line.uptrend.xyaxis")
                        }
                        .tag(2)
                        .onAppear { animateTab(2) }
                    
                    // Profile Tab
                    PremiumProfileView()
                        .tabItem {
                            Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
                        }
                        .tag(3)
                        .onAppear { animateTab(3) }
                }
                .accentColor(.premiumIndigo)
                .onAppear {
                    dashboardViewModel.refreshData()
                }
            }
        }
        .animation(.premiumSmooth, value: hasCompletedOnboarding)
    }
    
    private func animateTab(_ index: Int) {
        withAnimation(.premiumBounce) {
            for i in 0..<tabScale.count {
                tabScale[i] = i == index ? 1.1 : 1.0
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.premiumQuick) {
                tabScale[index] = 1.0
            }
        }
        
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Premium Onboarding View
struct PremiumOnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var animateContent = false
    
    let onboardingPages = [
        OnboardingPage(
            title: "Welcome to ZenStride",
            subtitle: "Your everyday success companion",
            description: "Build lasting habits with a beautiful, intuitive experience designed for your journey.",
            icon: "sparkles",
            color: Color.premiumIndigo
        ),
        OnboardingPage(
            title: "Track Progress",
            subtitle: "Visualize your growth",
            description: "See your consistency build over time with elegant charts and meaningful insights.",
            icon: "chart.line.uptrend.xyaxis",
            color: Color.premiumTeal
        ),
        OnboardingPage(
            title: "Stay Motivated",
            subtitle: "Celebrate every win",
            description: "Receive encouragement and celebrate milestones as you build your ideal routine.",
            icon: "star.fill",
            color: Color.premiumAmber
        )
    ]
    
    var body: some View {
        ZStack {
            // Dynamic Background
            LinearGradient(
                colors: [
                    onboardingPages[currentPage].color.opacity(0.2),
                    Color.premiumGray6
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.premiumSlow, value: currentPage)
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundColor(.premiumGray2)
                    .padding()
                }
                
                Spacer()
                
                // Content
                VStack(spacing: .spacing32) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(onboardingPages[currentPage].color.opacity(0.15))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: onboardingPages[currentPage].icon)
                            .font(.system(size: 50))
                            .foregroundColor(onboardingPages[currentPage].color)
                    }
                    .scaleEffect(animateContent ? 1 : 0.5)
                    .opacity(animateContent ? 1 : 0)
                    
                    VStack(spacing: .spacing16) {
                        Text(onboardingPages[currentPage].title)
                            .font(.premiumTitle1)
                            .foregroundColor(.premiumGray1)
                        
                        Text(onboardingPages[currentPage].subtitle)
                            .font(.premiumHeadline)
                            .foregroundColor(onboardingPages[currentPage].color)
                        
                        Text(onboardingPages[currentPage].description)
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .spacing32)
                    }
                    .offset(y: animateContent ? 0 : 20)
                    .opacity(animateContent ? 1 : 0)
                }
                
                Spacer()
                
                // Navigation
                VStack(spacing: .spacing24) {
                    // Page Indicators
                    HStack(spacing: .spacing8) {
                        ForEach(0..<onboardingPages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? onboardingPages[currentPage].color : Color.premiumGray5)
                                .frame(width: index == currentPage ? 28 : 8, height: 8)
                                .animation(.premiumSpring, value: currentPage)
                        }
                    }
                    
                    // Action Button
                    Button {
                        if currentPage < onboardingPages.count - 1 {
                            withAnimation(.premiumSmooth) {
                                animateContent = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                currentPage += 1
                                withAnimation(.premiumSmooth) {
                                    animateContent = true
                                }
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage < onboardingPages.count - 1 ? "Continue" : "Get Started")
                    }
                    .buttonStyle(PremiumPrimaryButton())
                    .padding(.horizontal, .spacing40)
                }
                .padding(.bottom, .spacing40)
            }
        }
        .onAppear {
            withAnimation(.premiumSmooth.delay(0.3)) {
                animateContent = true
            }
        }
    }
    
    private func completeOnboarding() {
        withAnimation(.premiumSmooth) {
            hasCompletedOnboarding = true
        }
        
        #if canImport(UIKit)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        #endif
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Premium Habits List View
struct PremiumHabitsListView: View {
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var searchText = ""
    
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return viewModel.habits
        } else {
            return viewModel.habits.filter {
                ($0.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.category ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: .spacing20) {
                        // Search Bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.premiumGray3)
                            
                            TextField("Search habits...", text: $searchText)
                                .font(.premiumCallout)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .fill(Color.white)
                        )
                        .premiumShadowXS()
                        .padding(.horizontal, .spacing20)
                        .padding(.top, .spacing16)
                        
                        // Habits List
                        LazyVStack(spacing: .spacing12) {
                            ForEach(filteredHabits) { habit in
                                PremiumHabitCard(
                                    habit: habit,
                                    progress: viewModel.getTodayProgress(for: habit),
                                    streak: viewModel.getStreak(for: habit),
                                    onTap: { selectedHabit = habit },
                                    onComplete: { viewModel.toggleHabit(habit) }
                                )
                                .padding(.horizontal, .spacing20)
                            }
                        }
                        .padding(.bottom, .spacing80)
                    }
                }
                
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        PremiumFloatingActionButton(icon: "plus") {
                            showingAddHabit = true
                        }
                    }
                }
                .padding(.spacing24)
            }
            .navigationTitle("All Habits")
            .sheet(isPresented: $showingAddHabit) {
                PremiumAddHabitView()
                    .environment(\.managedObjectContext, viewModel.viewContext)
            }
            .sheet(item: $selectedHabit) { habit in
                PremiumHabitDetailView(habit: habit, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}


// MARK: - Premium Profile View
struct PremiumProfileView: View {
    @AppStorage("userName") private var userName = "User"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: .spacing24) {
                        // Profile Header
                        VStack(spacing: .spacing16) {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.premiumIndigo, Color.premiumTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(userName.prefix(1).uppercased())
                                        .font(.premiumTitle1)
                                        .foregroundColor(.white)
                                )
                            
                            Text(userName)
                                .font(.premiumTitle2)
                                .foregroundColor(.premiumGray1)
                        }
                        .padding(.top, .spacing32)
                        
                        // Settings Options
                        VStack(spacing: .spacing12) {
                            SettingsRow(icon: "person.fill", title: "Edit Profile", color: .premiumIndigo)
                            SettingsRow(icon: "bell.fill", title: "Notifications", color: .premiumTeal)
                            SettingsRow(icon: "moon.fill", title: "Dark Mode", color: .premiumIndigo)
                            SettingsRow(icon: "questionmark.circle.fill", title: "Help", color: .premiumMint)
                        }
                        .padding(.horizontal, .spacing20)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            Text(title)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.premiumGray4)
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}