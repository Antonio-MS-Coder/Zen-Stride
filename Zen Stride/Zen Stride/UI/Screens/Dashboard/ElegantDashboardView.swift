import SwiftUI
import CoreData

struct ElegantDashboardView: View {
    @StateObject var viewModel: ElegantDashboardViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingCelebration = false
    @State private var celebrationMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background based on time
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: .zen24) {
                        // Personal Greeting Header
                        personalHeader
                        
                        // Progress Overview
                        if !viewModel.habits.isEmpty {
                            progressOverview
                        }
                        
                        // Today's Focus
                        todaysFocus
                        
                        // Quick Stats
                        if !viewModel.habits.isEmpty {
                            quickStats
                        }
                    }
                    .padding(.horizontal, .zen20)
                    .padding(.top, .zen16)
                    .padding(.bottom, .zen80)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddHabit) {
                ElegantAddHabitView()
                    .environment(\.managedObjectContext, viewModel.viewContext)
                    .onDisappear {
                        viewModel.refreshData()
                    }
            }
            .sheet(item: $selectedHabit) { habit in
                ElegantHabitDetailView(habit: habit, viewModel: viewModel)
            }
            .overlay(
                // Floating Action Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZenFloatingButton(icon: "plus") {
                            showingAddHabit = true
                        }
                    }
                }
                .padding(.zen20)
            )
        }
        .onAppear {
            viewModel.refreshData()
        }
        .overlay(
            showingCelebration ?
            ElegantCelebrationView(
                isShowing: $showingCelebration,
                message: celebrationMessage,
                achievement: "star.fill"
            ) : nil
        )
    }
    
    // MARK: - Components
    
    private var backgroundGradient: LinearGradient {
        switch viewModel.timeOfDay {
        case .morning:
            return Color.zenMorning
        case .afternoon:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.96, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.86)],
                startPoint: .top, endPoint: .bottom
            )
        case .evening:
            return Color.zenEvening
        case .night:
            return LinearGradient(
                colors: [Color(red: 0.88, green: 0.88, blue: 0.94), Color(red: 0.84, green: 0.84, blue: 0.91)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
    
    private var personalHeader: some View {
        VStack(alignment: .leading, spacing: .zen8) {
            Text(viewModel.greeting)
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
            
            Text(viewModel.currentUser?.name ?? "Friend")
                .font(.zenHero)
                .foregroundColor(.zenTextPrimary)
            
            Text(viewModel.getPersonalizedMessage())
                .font(.zenCallout)
                .foregroundColor(.zenTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .zen40)
    }
    
    private var progressOverview: some View {
        VStack(spacing: .zen16) {
            HStack {
                Text("Today's Progress")
                    .font(.zenSubheadline)
                    .foregroundColor(.zenTextPrimary)
                
                Spacer()
                
                Text("\(viewModel.getCompletedCount())/\(viewModel.habits.count)")
                    .font(.zenCaption)
                    .foregroundColor(.zenTextSecondary)
            }
            
            // Visual Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.zenCloud)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.zenPrimary, Color.zenSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.todayCompletionRate, height: 8)
                        .animation(.zenSpring, value: viewModel.todayCompletionRate)
                }
            }
            .frame(height: 8)
            
            if viewModel.todayCompletionRate == 1.0 {
                Text("Perfect day! 🎉")
                    .font(.zenCaption)
                    .foregroundColor(.zenSuccess)
                    .onAppear {
                        celebrationMessage = "All habits completed!"
                        showingCelebration = true
                    }
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var todaysFocus: some View {
        VStack(alignment: .leading, spacing: .zen16) {
            Text("Today's Habits")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            if viewModel.habits.isEmpty {
                emptyState
            } else {
                VStack(spacing: .zen12) {
                    ForEach(viewModel.habits) { habit in
                        ElegantHabitCard(
                            habit: habit,
                            progress: viewModel.getTodayProgress(for: habit),
                            streak: viewModel.getStreak(for: habit),
                            onTap: { selectedHabit = habit },
                            onComplete: { completeHabit(habit) }
                        )
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .zen16) {
            Image(systemName: "sparkles")
                .font(.system(size: 32))
                .foregroundColor(.zenPrimary)
            
            Text("Start your journey")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            Text("Add your first habit to begin")
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
            
            Button("Create Habit") {
                showingAddHabit = true
            }
            .buttonStyle(ZenPrimaryButton())
            .padding(.top, .zen8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .zen32)
        .zenCard()
    }
    
    private var quickStats: some View {
        HStack(spacing: .zen12) {
            ElegantStatCard(
                icon: "flame.fill",
                value: "\(viewModel.getCurrentStreak())",
                label: "Day Streak",
                color: .zenSecondary
            )
            
            ElegantStatCard(
                icon: "checkmark.circle.fill",
                value: "\(viewModel.getTotalCompletedToday())",
                label: "Completed",
                color: .zenTertiary
            )
            
            ElegantStatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(Int(viewModel.todayCompletionRate * 100))%",
                label: "Today",
                color: .zenPrimary
            )
        }
    }
    
    // MARK: - Actions
    
    private func completeHabit(_ habit: Habit) {
        viewModel.toggleHabit(habit)
        
        if viewModel.isHabitComplete(habit) {
            // Show celebration for completion
            celebrationMessage = "Great job! \(habit.name ?? "Habit") completed"
            
            // Check if all habits are complete
            if viewModel.todayCompletionRate == 1.0 {
                celebrationMessage = "Perfect day! All habits completed! 🎉"
                showingCelebration = true
            }
        }
    }
}

// MARK: - Supporting Views

struct ElegantHabitCard: View {
    let habit: Habit
    let progress: Progress?
    let streak: Int
    let onTap: () -> Void
    let onComplete: () -> Void
    
    private var isComplete: Bool {
        progress?.isComplete ?? false
    }
    
    var body: some View {
        HStack(spacing: .zen16) {
            // Custom Checkbox
            ZenCheckbox(isChecked: .constant(isComplete))
                .onTapGesture {
                    onComplete()
                }
            
            VStack(alignment: .leading, spacing: .zen4) {
                Text(habit.name ?? "")
                    .font(.zenBody)
                    .foregroundColor(isComplete ? .zenTextSecondary : .zenTextPrimary)
                    .strikethrough(isComplete, color: .zenTextTertiary)
                
                if let category = habit.category {
                    HStack(spacing: .zen4) {
                        Image(systemName: iconForCategory(category))
                            .font(.system(size: 10))
                        Text(category)
                            .font(.zenFootnote)
                    }
                    .foregroundColor(.zenTextTertiary)
                }
            }
            
            Spacer()
            
            // Progress or Streak Indicator
            if habit.targetValue > 1 && !isComplete {
                ZenProgressRing(
                    progress: Double(progress?.value ?? 0) / Double(habit.targetValue),
                    size: 36,
                    lineWidth: 3
                )
            } else if streak > 0 {
                HStack(spacing: .zen4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.zenSecondary)
                    Text("\(streak)")
                        .font(.zenCaption)
                        .foregroundColor(.zenTextSecondary)
                }
            } else if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.zenSuccess)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.zen16)
        .zenCard(isInteractive: true, isSelected: isComplete)
        .onTapGesture(perform: onTap)
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

struct ElegantStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: .zen8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.zenHeadline)
                .foregroundColor(.zenTextPrimary)
            
            Text(label)
                .font(.zenFootnote)
                .foregroundColor(.zenTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .zen16)
        .zenCard()
    }
}

struct ElegantHabitDetailView: View {
    let habit: Habit
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .zen24) {
                    // Stats Overview
                    VStack(spacing: .zen16) {
                        HabitStatRow(label: "Current Streak", value: "\(viewModel.getStreak(for: habit)) days")
                        Divider()
                        HabitStatRow(label: "Total Completions", value: "\(getTotalCompletions())")
                        Divider()
                        HabitStatRow(label: "Success Rate", value: "\(getSuccessRate())%")
                        Divider()
                        HabitStatRow(label: "Best Streak", value: "\(getBestStreak()) days")
                    }
                    .padding(.zen20)
                    .zenCard()
                    
                    // Progress History
                    Text("Recent Progress")
                        .font(.zenSubheadline)
                        .foregroundColor(.zenTextPrimary)
                    
                    // Placeholder for progress chart
                    RoundedRectangle(cornerRadius: .zenRadiusMedium)
                        .fill(Color.zenCloud)
                        .frame(height: 200)
                        .overlay(
                            Text("Progress chart coming soon")
                                .font(.zenCaption)
                                .foregroundColor(.zenTextTertiary)
                        )
                }
                .padding(.zen20)
            }
            .background(Color.zenBackground)
            .navigationTitle(habit.name ?? "Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getTotalCompletions() -> Int {
        // This would connect to the service
        return 0
    }
    
    private func getSuccessRate() -> Int {
        // This would connect to the service
        return 0
    }
    
    private func getBestStreak() -> Int {
        // This would connect to the service
        return 0
    }
}

struct HabitStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.zenBody)
                .foregroundColor(.zenTextSecondary)
            Spacer()
            Text(value)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
        }
    }
}