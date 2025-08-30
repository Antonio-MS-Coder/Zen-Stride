import SwiftUI
import CoreData

struct PremiumDashboardView: View {
    @StateObject var viewModel: ElegantDashboardViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingCelebration = false
    @State private var celebrationMessage = ""
    @State private var timeOfDay = TimeOfDay()
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sophisticated background
                backgroundView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Hero Header with Parallax
                        heroHeader
                            .padding(.top, getSafeAreaTop())
                            .padding(.horizontal, .spacing20)
                            .padding(.bottom, .spacing32)
                        
                        // Main Content
                        VStack(spacing: .spacing24) {
                            // Today's Overview Card
                            if !viewModel.habits.isEmpty {
                                todayOverviewCard
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                            }
                            
                            // Habits Section
                            habitsSection
                            
                            // Stats Dashboard
                            if !viewModel.habits.isEmpty {
                                statsDashboard
                                    .transition(.move(edge: .bottom))
                            }
                        }
                        .padding(.horizontal, .spacing20)
                        .padding(.bottom, .spacing80)
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
                
                // Floating Action Button
                floatingActionButton
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddHabit) {
                PremiumAddHabitView()
                    .environment(\.managedObjectContext, viewModel.viewContext)
                    .onDisappear {
                        viewModel.refreshData()
                    }
            }
            .sheet(item: $selectedHabit) { habit in
                PremiumHabitDetailView(habit: habit, viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.refreshData()
            timeOfDay = TimeOfDay()
        }
        .overlay(
            showingCelebration ?
            PremiumCelebrationView(
                isShowing: $showingCelebration,
                message: celebrationMessage
            ) : nil
        )
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [Color.premiumGray6, Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Dynamic time-based overlay
            Color.dynamicGradient(for: timeOfDay)
                .ignoresSafeArea()
                .opacity(0.3)
            
            // Floating orbs for depth
            GeometryReader { geometry in
                Circle()
                    .fill(Color.premiumIndigo.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: -100, y: -100 + scrollOffset * 0.3)
                
                Circle()
                    .fill(Color.premiumTeal.opacity(0.1))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: geometry.size.width - 150, y: 200 + scrollOffset * 0.2)
            }
        }
    }
    
    // MARK: - Hero Header
    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text(viewModel.greeting.uppercased())
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.5)
            
            Text(viewModel.currentUser?.name ?? "Achiever")
                .font(.premiumLargeTitle)
                .foregroundColor(.premiumGray1)
            
            HStack(spacing: .spacing8) {
                Image(systemName: motivationalIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.premiumIndigo)
                
                Text(viewModel.getPersonalizedMessage())
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
            }
            .padding(.top, .spacing4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .offset(y: scrollOffset > 0 ? -scrollOffset * 0.5 : 0)
        .opacity(scrollOffset > -50 ? 1 : 0)
        .animation(.premiumSmooth, value: scrollOffset)
    }
    
    // MARK: - Today Overview Card
    private var todayOverviewCard: some View {
        VStack(spacing: .spacing20) {
            HStack {
                VStack(alignment: .leading, spacing: .spacing4) {
                    Text("TODAY'S PROGRESS")
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                        .tracking(1.2)
                    
                    Text("\(viewModel.getCompletedCount()) of \(viewModel.habits.count) completed")
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                }
                
                Spacer()
                
                PremiumProgressRing(
                    progress: viewModel.todayCompletionRate,
                    size: 60,
                    lineWidth: 6,
                    showPercentage: true
                )
            }
            
            // Progress Bar with segments
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.premiumGray6)
                        .frame(height: 12)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: progressGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.todayCompletionRate, height: 12)
                        .animation(.premiumSpring, value: viewModel.todayCompletionRate)
                    
                    // Milestone dots
                    HStack(spacing: 0) {
                        ForEach(0..<viewModel.habits.count, id: \.self) { index in
                            let progress = Double(index + 1) / Double(viewModel.habits.count)
                            Circle()
                                .fill(viewModel.todayCompletionRate >= progress ? Color.white : Color.premiumGray5)
                                .frame(width: 8, height: 8)
                                .frame(width: geometry.size.width / CGFloat(viewModel.habits.count))
                                .scaleEffect(viewModel.todayCompletionRate >= progress ? 1.2 : 1.0)
                                .animation(.premiumSpring(delay: Double(index) * 0.05), value: viewModel.todayCompletionRate)
                        }
                    }
                }
            }
            .frame(height: 12)
            
            if viewModel.todayCompletionRate == 1.0 {
                HStack {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.premiumAmber)
                    
                    Text("Perfect Day!")
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                    
                    Spacer()
                }
                .padding(.top, .spacing8)
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
                .onAppear {
                    celebrationMessage = "All habits completed! You're amazing!"
                    showingCelebration = true
                }
            }
        }
        .padding(.spacing24)
        .premiumGlassCard()
    }
    
    // MARK: - Habits Section
    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            HStack {
                Text("HABITS")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                if !viewModel.habits.isEmpty {
                    Button {
                        // Toggle view mode
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16))
                            .foregroundColor(.premiumIndigo)
                    }
                }
            }
            
            if viewModel.habits.isEmpty {
                emptyStateCard
            } else {
                VStack(spacing: .spacing12) {
                    ForEach(Array(viewModel.habits.enumerated()), id: \.element) { index, habit in
                        PremiumHabitCard(
                            habit: habit,
                            progress: viewModel.getTodayProgress(for: habit),
                            streak: viewModel.getStreak(for: habit),
                            onTap: { selectedHabit = habit },
                            onComplete: { completeHabit(habit) }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                        .animation(.premiumSpring(delay: Double(index) * 0.05), value: viewModel.habits.count)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateCard: some View {
        VStack(spacing: .spacing20) {
            ZStack {
                Circle()
                    .fill(Color.premiumIndigo.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.premiumIndigo)
            }
            
            VStack(spacing: .spacing8) {
                Text("Start Your Journey")
                    .font(.premiumTitle3)
                    .foregroundColor(.premiumGray1)
                
                Text("Create your first habit to begin building a better you")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create First Habit") {
                showingAddHabit = true
            }
            .buttonStyle(PremiumPrimaryButton())
            .frame(maxWidth: 200)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing40)
        .padding(.horizontal, .spacing24)
        .premiumGlassCard()
    }
    
    // MARK: - Stats Dashboard
    private var statsDashboard: some View {
        VStack(spacing: .spacing16) {
            HStack {
                Text("STATISTICS")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
            }
            
            HStack(spacing: .spacing12) {
                PremiumStatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.getCurrentStreak())",
                    label: "Streak",
                    color: .premiumCoral,
                    trend: .up
                )
                
                PremiumStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.getTotalCompletedToday())",
                    label: "Today",
                    color: .premiumMint,
                    trend: .stable
                )
                
                PremiumStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(viewModel.weeklyCompletionRate * 100))%",
                    label: "Weekly",
                    color: .premiumTeal,
                    trend: viewModel.weeklyCompletionRate > 0.7 ? .up : .down
                )
            }
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                PremiumFloatingActionButton(icon: "plus") {
                    showingAddHabit = true
                    #if canImport(UIKit)
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    #endif
                }
            }
        }
        .padding(.spacing24)
    }
    
    // MARK: - Helpers
    private var motivationalIcon: String {
        switch viewModel.todayCompletionRate {
        case 0: return "sunrise.fill"
        case 0..<0.5: return "bolt.fill"
        case 0.5..<1: return "flame.fill"
        default: return "crown.fill"
        }
    }
    
    private var progressGradientColors: [Color] {
        switch viewModel.todayCompletionRate {
        case 0..<0.3: return [Color.premiumGray4, Color.premiumGray3]
        case 0.3..<0.7: return [Color.premiumIndigo, Color.premiumBlue]
        case 0.7..<1: return [Color.premiumBlue, Color.premiumTeal]
        default: return [Color.premiumTeal, Color.premiumMint]
        }
    }
    
    private func getSafeAreaTop() -> CGFloat {
        #if canImport(UIKit)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.windows.first?.safeAreaInsets.top ?? 0
        }
        #endif
        return 0
    }
    
    private func completeHabit(_ habit: Habit) {
        viewModel.toggleHabit(habit)
        
        if viewModel.isHabitComplete(habit) {
            celebrationMessage = "\(habit.name ?? "Habit") completed!"
            
            if viewModel.todayCompletionRate == 1.0 {
                celebrationMessage = "Perfect day achieved!"
                showingCelebration = true
            }
            
            #if canImport(UIKit)
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
            #endif
        }
    }
}

// MARK: - Supporting Views
struct PremiumHabitCard: View {
    let habit: Habit
    let progress: Progress?
    let streak: Int
    let onTap: () -> Void
    let onComplete: () -> Void
    
    @State private var isPressed = false
    
    private var isComplete: Bool {
        progress?.isComplete ?? false
    }
    
    var body: some View {
        HStack(spacing: .spacing16) {
            // Animated Checkbox
            PremiumCheckbox(isChecked: .constant(isComplete))
                .onTapGesture {
                    onComplete()
                }
            
            VStack(alignment: .leading, spacing: .spacing6) {
                Text(habit.name ?? "")
                    .font(.premiumHeadline)
                    .foregroundColor(isComplete ? .premiumGray3 : .premiumGray1)
                    .strikethrough(isComplete, color: .premiumGray4)
                
                HStack(spacing: .spacing8) {
                    if let category = habit.category {
                        Label(category, systemImage: iconForCategory(category))
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                    }
                    
                    if streak > 0 {
                        Label("\(streak) days", systemImage: "flame.fill")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumCoral)
                    }
                }
            }
            
            Spacer()
            
            // Progress Indicator
            if habit.targetValue > 1 && !isComplete {
                PremiumProgressRing(
                    progress: Double(progress?.value ?? 0) / Double(habit.targetValue),
                    size: 44,
                    lineWidth: 4
                )
            } else if isComplete {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.premiumMint)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
            }
        }
        .padding(.spacing20)
        .premiumGlassCard(isPressed: isPressed)
        .onTapGesture {
            onTap()
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.premiumQuick) {
                isPressed = pressing
            }
        }, perform: {})
    }
    
    private func iconForCategory(_ category: String) -> String {
        switch category.lowercased() {
        case "health": return "heart.fill"
        case "fitness": return "figure.run"
        case "mindfulness": return "brain.head.profile"
        case "learning": return "book.fill"
        case "creativity": return "paintbrush.fill"
        case "productivity": return "checklist"
        case "social": return "person.2.fill"
        default: return "star.fill"
        }
    }
}

struct PremiumStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    var trend: Trend = .stable
    
    enum Trend {
        case up, down, stable
    }
    
    var body: some View {
        VStack(spacing: .spacing12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(spacing: .spacing4) {
                HStack(spacing: .spacing4) {
                    Text(value)
                        .font(.premiumTitle2)
                        .foregroundColor(.premiumGray1)
                    
                    if trend != .stable {
                        Image(systemName: trend == .up ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(trend == .up ? .premiumMint : .premiumError)
                    }
                }
                
                Text(label)
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing20)
        .premiumGlassCard()
    }
}

// MARK: - Preference Keys
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Celebration View
struct PremiumCelebrationView: View {
    @Binding var isShowing: Bool
    let message: String
    @State private var scale: CGFloat = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: .spacing24) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.premiumIndigo, Color.premiumTeal],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                Text(message)
                    .font(.premiumTitle2)
                    .foregroundColor(.premiumGray1)
                    .multilineTextAlignment(.center)
            }
            .padding(.spacing40)
            .background(
                RoundedRectangle(cornerRadius: .radius2XL)
                    .fill(.ultraThinMaterial)
            )
            .premiumShadowXL()
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.premiumBounce) {
                scale = 1
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.premiumSmooth) {
                    scale = 0
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShowing = false
                }
            }
        }
    }
}