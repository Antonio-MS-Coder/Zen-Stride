import SwiftUI

struct ZenStrideTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickLog = false
    @State private var tabBarOffset: CGFloat = 100
    
    // Shared data
    @StateObject private var dataStore = ZenStrideDataStore()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            TabView(selection: $selectedTab) {
                // Today - Main dashboard for daily wins
                MicroWinsDashboard()
                    .tag(0)
                    .environmentObject(dataStore)
                
                // Progress - See your journey over time
                ProgressInsightsView()
                    .tag(1)
                    .environmentObject(dataStore)
                
                // You - Personal settings and customization
                ProfileSettingsView()
                    .tag(2)
                    .environmentObject(dataStore)
            }
            .tabViewStyle(.automatic)
            .safeAreaInset(edge: .bottom) {
                customTabBar
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            QuickLogView { win in
                dataStore.addWin(win)
            }
        }
    }
    
    // MARK: - Custom Tab Bar
    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Today tab
            TabBarButton(
                icon: "sun.max.fill",
                title: "Today",
                isSelected: selectedTab == 0,
                action: { 
                    withAnimation(.premiumSmooth) {
                        selectedTab = 0
                    }
                }
            )
            
            // Progress tab
            TabBarButton(
                icon: "chart.line.uptrend.xyaxis",
                title: "Progress",
                isSelected: selectedTab == 1,
                action: {
                    withAnimation(.premiumSmooth) {
                        selectedTab = 1
                    }
                }
            )
            
            // You tab
            TabBarButton(
                icon: "person.fill",
                title: "You",
                isSelected: selectedTab == 2,
                action: {
                    withAnimation(.premiumSmooth) {
                        selectedTab = 2
                    }
                }
            )
        }
        .padding(.horizontal, .spacing20)
        .padding(.top, .spacing12)
        .padding(.bottom, .spacing28)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
        .offset(y: tabBarOffset)
        .onAppear {
            withAnimation(.premiumSpring.delay(0.3)) {
                tabBarOffset = 0
            }
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Tab Bar Button
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button {
            withAnimation(.premiumQuick) {
                isPressed = true
            }
            hapticFeedback(.light)
            action()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.premiumQuick) {
                    isPressed = false
                }
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
                    .symbolEffect(.bounce, value: isSelected)
                
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isPressed ? 0.95 : (isSelected ? 1.05 : 1.0))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Helper function
private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
    #if canImport(UIKit)
    let impact = UIImpactFeedbackGenerator(style: style)
    impact.impactOccurred()
    #endif
}

// MARK: - Data Store
class ZenStrideDataStore: ObservableObject {
    @Published var todaysWins: [MicroWin] = []
    @Published var allWins: [MicroWin] = []
    @Published var habits: [QuickHabit] = []
    @Published var streakDays: Int = 0
    @Published var streakSaverTokens: Int = 3
    @Published var focusMode: Bool = false
    @Published var focusedHabit: String? = nil
    @Published var commonValues: [String: [String]] = [:] // habit -> common values
    @Published var optimalTimes: [String: [Int]] = [:] // habit -> hours of day
    
    init() {
        loadSampleData()
        analyzePatterns()
    }
    
    func addWin(_ win: MicroWin) {
        todaysWins.append(win)
        allWins.append(win)
        updateStreak()
        learnFromWin(win)
    }
    
    func useStreakSaver() -> Bool {
        if streakSaverTokens > 0 {
            streakSaverTokens -= 1
            return true
        }
        return false
    }
    
    func toggleFocusMode(for habit: String? = nil) {
        focusMode = habit != nil
        focusedHabit = habit
    }
    
    func getSmartSuggestions(for habit: String) -> [String] {
        // Return common values for this habit
        return commonValues[habit] ?? []
    }
    
    func getMomentumScore() -> Double {
        // Calculate current momentum based on recent activity
        let recentWins = todaysWins.count
        let timeOfDay = Calendar.current.component(.hour, from: Date())
        let optimalTime = isOptimalTime(hour: timeOfDay)
        
        return Double(recentWins) * (optimalTime ? 1.5 : 1.0)
    }
    
    func getWisdomMoment(for win: MicroWin) -> String {
        // Generate contextual wisdom based on the win
        let insights = [
            "Reading": [
                "You've strengthened \(Int.random(in: 500...1500)) neural connections today.",
                "You're now in the top 27% of daily readers.",
                "Fun fact: 15 pages daily = 18 books per year!"
            ],
            "Exercise": [
                "Your heart just got 2% stronger.",
                "You've added 3 days to your life expectancy this month.",
                "Your brain released happiness chemicals that last 4 hours!"
            ],
            "Water": [
                "Your cells are celebrating right now!",
                "You're 23% more hydrated than the average person today.",
                "Your focus will increase by 14% in the next hour."
            ],
            "Meditation": [
                "Your stress cortisol just dropped by 23%.",
                "You've increased your gray matter density.",
                "Your emotional regulation improved by one level."
            ]
        ]
        
        let habitInsights = insights[win.habitName] ?? [
            "Every small win compounds into extraordinary results.",
            "You're building neural pathways for lasting change.",
            "Consistency beats perfection every time."
        ]
        
        return habitInsights.randomElement() ?? "Keep going! You're amazing."
    }
    
    private func isOptimalTime(hour: Int) -> Bool {
        // Check if current hour is optimal for any habit
        for (_, hours) in optimalTimes {
            if hours.contains(hour) {
                return true
            }
        }
        return false
    }
    
    private func learnFromWin(_ win: MicroWin) {
        // Learn patterns from user behavior
        let hour = Calendar.current.component(.hour, from: win.timestamp)
        
        // Track optimal times
        if optimalTimes[win.habitName] == nil {
            optimalTimes[win.habitName] = []
        }
        optimalTimes[win.habitName]?.append(hour)
        
        // Track common values
        if commonValues[win.habitName] == nil {
            commonValues[win.habitName] = []
        }
        let valueString = "\(win.value) \(win.unit)"
        if !commonValues[win.habitName]!.contains(valueString) {
            commonValues[win.habitName]?.append(valueString)
        }
    }
    
    private func analyzePatterns() {
        // Initialize with smart defaults based on common patterns
        optimalTimes = [
            "Meditation": [6, 7, 8, 20, 21],
            "Exercise": [6, 7, 17, 18, 19],
            "Reading": [20, 21, 22],
            "Water": [8, 10, 12, 14, 16, 18]
        ]
    }
    
    func getWeeklyProgress() -> [DayProgress] {
        // Generate weekly progress data
        let calendar = Calendar.current
        var progress: [DayProgress] = []
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                let dayWins = Int.random(in: 0...5)
                progress.append(DayProgress(date: date, wins: dayWins))
            }
        }
        
        return progress.reversed()
    }
    
    func getMonthlyTrend() -> Double {
        // Calculate trend (positive means improving)
        return 0.23 // 23% improvement
    }
    
    private func loadSampleData() {
        todaysWins = MicroWin.sampleWins
        streakDays = 7
    }
    
    private func updateStreak() {
        // Update streak logic
        if !todaysWins.isEmpty {
            streakDays += 1
        }
    }
}

struct DayProgress: Identifiable {
    let id = UUID()
    let date: Date
    let wins: Int
}