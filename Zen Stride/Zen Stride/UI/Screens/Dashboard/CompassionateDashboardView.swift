import SwiftUI
import CoreData

struct CompassionateDashboardView: View {
    @StateObject var viewModel: ElegantDashboardViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingReflection = false
    @State private var showingCelebration = false
    @State private var celebrationMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gentle gradient background
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: .zen24) {
                        // Warm greeting without pressure
                        warmGreeting
                        
                        // Today's gentle reminder
                        if !viewModel.habits.isEmpty {
                            gentleReminder
                        }
                        
                        // Habits with clear completion UI
                        todaysHabits
                        
                        // Progress without judgment
                        if !viewModel.habits.isEmpty {
                            progressEncouragement
                        }
                        
                        // Quick actions
                        quickActions
                    }
                    .padding(.horizontal, .zen20)
                    .padding(.top, .zen16)
                    .padding(.bottom, .zen80)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddHabit) {
                CompassionateAddHabitView()
                    .environment(\.managedObjectContext, viewModel.viewContext)
                    .onDisappear {
                        viewModel.refreshData()
                    }
            }
            .sheet(item: $selectedHabit) { habit in
                HabitReflectionView(habit: habit, viewModel: viewModel)
            }
            .sheet(isPresented: $showingReflection) {
                DailyReflectionView(viewModel: viewModel)
            }
            .overlay(
                // Floating Add Button (less prominent)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingAddHabit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.zenTextSecondary)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.zenSurface)
                                        .zenShadowSmall()
                                )
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
            GentleCelebrationView(
                isShowing: $showingCelebration,
                message: celebrationMessage
            ) : nil
        )
    }
    
    // MARK: - Components
    
    private var backgroundGradient: LinearGradient {
        // Softer, more neutral gradients
        switch viewModel.timeOfDay {
        case .morning:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.98, blue: 0.97), Color(red: 0.96, green: 0.96, blue: 0.95)],
                startPoint: .top, endPoint: .bottom
            )
        case .afternoon:
            return LinearGradient(
                colors: [Color(red: 0.97, green: 0.97, blue: 0.96), Color(red: 0.95, green: 0.95, blue: 0.94)],
                startPoint: .top, endPoint: .bottom
            )
        case .evening:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.93, green: 0.93, blue: 0.95)],
                startPoint: .top, endPoint: .bottom
            )
        case .night:
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.93, blue: 0.95), Color(red: 0.91, green: 0.91, blue: 0.93)],
                startPoint: .top, endPoint: .bottom
            )
        }
    }
    
    private var warmGreeting: some View {
        VStack(alignment: .leading, spacing: .zen8) {
            Text(viewModel.greeting)
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
            
            Text(viewModel.currentUser?.name ?? "Friend")
                .font(.zenHero)
                .foregroundColor(.zenTextPrimary)
            
            Text(getCompassionateMessage())
                .font(.zenCallout)
                .foregroundColor(.zenTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, .zen40)
    }
    
    private var gentleReminder: some View {
        HStack(spacing: .zen12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundColor(.zenSecondary)
            
            Text(getDailyWisdom())
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
                .italic()
            
            Spacer()
        }
        .padding(.zen16)
        .background(
            RoundedRectangle(cornerRadius: .zenRadiusSmall)
                .fill(Color.zenSecondary.opacity(0.05))
        )
    }
    
    private var todaysHabits: some View {
        VStack(alignment: .leading, spacing: .zen16) {
            HStack {
                Text("Today's Intentions")
                    .font(.zenSubheadline)
                    .foregroundColor(.zenTextPrimary)
                
                Spacer()
                
                if !viewModel.habits.isEmpty {
                    Text("\(viewModel.getCompletedCount()) of \(viewModel.habits.count)")
                        .font(.zenCaption)
                        .foregroundColor(.zenTextTertiary)
                }
            }
            
            if viewModel.habits.isEmpty {
                emptyStateEncouragement
            } else {
                VStack(spacing: .zen8) {
                    ForEach(viewModel.habits) { habit in
                        CompassionateHabitCard(
                            habit: habit,
                            progress: viewModel.getTodayProgress(for: habit),
                            onComplete: { completeHabit(habit) },
                            onPartial: { partialComplete(habit) },
                            onReflect: { selectedHabit = habit }
                        )
                    }
                }
            }
        }
    }
    
    private var emptyStateEncouragement: some View {
        VStack(spacing: .zen16) {
            Image(systemName: "leaf")
                .font(.system(size: 32))
                .foregroundColor(.zenTertiary)
            
            Text("Start small, grow steadily")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
            
            Text("Choose one habit that matters to you")
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
            
            Button("Add Your First Habit") {
                showingAddHabit = true
            }
            .font(.zenButton)
            .foregroundColor(.zenPrimary)
            .padding(.horizontal, .zen20)
            .padding(.vertical, .zen12)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusSmall)
                    .stroke(Color.zenPrimary, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .zen32)
        .zenCard()
    }
    
    private var progressEncouragement: some View {
        VStack(spacing: .zen16) {
            // Simple progress without pressure
            HStack {
                Text("Your Progress Today")
                    .font(.zenCaption)
                    .foregroundColor(.zenTextSecondary)
                
                Spacer()
            }
            
            // Visual progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.zenCloud)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.zenTertiary)
                        .frame(width: geometry.size.width * viewModel.todayCompletionRate, height: 6)
                        .animation(.zenGentle, value: viewModel.todayCompletionRate)
                }
            }
            .frame(height: 6)
            
            Text(getProgressMessage())
                .font(.zenCaption)
                .foregroundColor(.zenTextSecondary)
        }
        .padding(.zen20)
        .background(
            RoundedRectangle(cornerRadius: .zenRadiusMedium)
                .fill(Color.zenSurface)
        )
    }
    
    private var quickActions: some View {
        HStack(spacing: .zen12) {
            QuickActionCard(
                icon: "arrow.clockwise",
                title: "Fresh Start",
                subtitle: "Reset without guilt",
                color: .zenTertiary
            ) {
                showFreshStartDialog()
            }
            
            QuickActionCard(
                icon: "pencil.line",
                title: "Reflect",
                subtitle: "Note your progress",
                color: .zenPrimary
            ) {
                showingReflection = true
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getCompassionateMessage() -> String {
        let completed = viewModel.getCompletedCount()
        let total = viewModel.habits.count
        
        if total == 0 {
            return "Take a moment to think about what you'd like to cultivate"
        }
        
        switch viewModel.timeOfDay {
        case .morning:
            return "Each small step counts"
        case .afternoon:
            if completed > 0 {
                return "You're making progress"
            } else {
                return "There's still time, no pressure"
            }
        case .evening:
            if completed == total {
                return "You honored your intentions today"
            } else if completed > 0 {
                return "You showed up today, that's what matters"
            } else {
                return "Tomorrow is a fresh start"
            }
        case .night:
            return "Rest well, you've done enough"
        }
    }
    
    private func getDailyWisdom() -> String {
        let wisdoms = [
            "Progress, not perfection",
            "One small step is still a step forward",
            "Be gentle with yourself today",
            "Your worth isn't measured by your productivity",
            "Starting again is a sign of strength",
            "Some days, showing up is enough",
            "Growth happens in cycles, not straight lines"
        ]
        return wisdoms.randomElement() ?? wisdoms[0]
    }
    
    private func getProgressMessage() -> String {
        let rate = viewModel.todayCompletionRate
        
        if rate == 0 {
            return "No pressure, start when you're ready"
        } else if rate < 0.5 {
            return "Every bit counts"
        } else if rate < 1.0 {
            return "You're doing great"
        } else {
            return "Wonderful! Take time to appreciate this"
        }
    }
    
    private func completeHabit(_ habit: Habit) {
        viewModel.toggleHabit(habit)
        
        if viewModel.isHabitComplete(habit) {
            celebrationMessage = "Well done! You completed \(habit.name ?? "your habit")"
            showingCelebration = true
        }
    }
    
    private func partialComplete(_ habit: Habit) {
        // Log partial completion
        celebrationMessage = "Great! Some progress is still progress"
        showingCelebration = true
    }
    
    private func showFreshStartDialog() {
        // Implement fresh start functionality
    }
}

// MARK: - Supporting Views

struct CompassionateHabitCard: View {
    let habit: Habit
    let progress: Progress?
    let onComplete: () -> Void
    let onPartial: () -> Void
    let onReflect: () -> Void
    
    @State private var showingOptions = false
    
    private var isComplete: Bool {
        progress?.isComplete ?? false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .zen16) {
                // Main completion button - LARGE and CLEAR
                Button {
                    if !isComplete {
                        onComplete()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .stroke(isComplete ? Color.zenSuccess : Color.zenCloud, lineWidth: 2)
                            .frame(width: 32, height: 32)
                        
                        if isComplete {
                            Circle()
                                .fill(Color.zenSuccess)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // Habit info
                VStack(alignment: .leading, spacing: .zen4) {
                    Text(habit.name ?? "")
                        .font(.zenBody)
                        .foregroundColor(isComplete ? .zenTextSecondary : .zenTextPrimary)
                        .strikethrough(isComplete, color: .zenTextTertiary)
                    
                    if let target = formatTarget(habit), !isComplete {
                        Text(target)
                            .font(.zenCaption)
                            .foregroundColor(.zenTextTertiary)
                    }
                }
                
                Spacer()
                
                // More options
                Menu {
                    if !isComplete {
                        Button {
                            onPartial()
                        } label: {
                            Label("I did some", systemImage: "star.leadinghalf.filled")
                        }
                        
                        Button {
                            onComplete()
                        } label: {
                            Label("Mark complete", systemImage: "checkmark.circle")
                        }
                    }
                    
                    Button {
                        onReflect()
                    } label: {
                        Label("Add note", systemImage: "pencil")
                    }
                    
                    if isComplete {
                        Button {
                            onComplete() // This will toggle it off
                        } label: {
                            Label("Unmark", systemImage: "arrow.uturn.backward")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16))
                        .foregroundColor(.zenTextTertiary)
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, .zen16)
            .padding(.vertical, .zen12)
            
            // Progress indicator (if applicable)
            if habit.targetValue > 1 && !isComplete {
                HStack {
                    Text("Tap to log progress")
                        .font(.zenFootnote)
                        .foregroundColor(.zenTextTertiary)
                    
                    Spacer()
                    
                    Text("\(Int(progress?.value ?? 0))/\(Int(habit.targetValue))")
                        .font(.zenFootnote)
                        .foregroundColor(.zenTextSecondary)
                }
                .padding(.horizontal, .zen16)
                .padding(.bottom, .zen8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: .zenRadiusMedium)
                .fill(isComplete ? Color.zenSuccess.opacity(0.05) : Color.zenSurface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: .zenRadiusMedium)
                .stroke(isComplete ? Color.zenSuccess.opacity(0.2) : Color.zenCloud, lineWidth: 1)
        )
    }
    
    private func formatTarget(_ habit: Habit) -> String? {
        guard habit.targetValue > 1 else { return nil }
        let value = Int(habit.targetValue)
        let unit = habit.targetUnit ?? ""
        return "\(value) \(unit)"
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .zen8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.zenCaption)
                    .foregroundColor(.zenTextPrimary)
                
                Text(subtitle)
                    .font(.zenFootnote)
                    .foregroundColor(.zenTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .zen16)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusMedium)
                    .fill(Color.zenSurface)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GentleCelebrationView: View {
    @Binding var isShowing: Bool
    let message: String
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack {
            HStack(spacing: .zen12) {
                Image(systemName: "sparkle")
                    .font(.system(size: 16))
                    .foregroundColor(.zenTertiary)
                
                Text(message)
                    .font(.zenBody)
                    .foregroundColor(.zenTextPrimary)
                
                Spacer()
            }
            .padding(.zen16)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusSmall)
                    .fill(Color.zenSurface)
                    .zenShadowMedium()
            )
            .padding(.horizontal, .zen20)
            .padding(.top, .zen48)
            
            Spacer()
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.zenGentle) {
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.zenSmooth) {
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - Additional Views

struct CompassionateAddHabitView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Add Habit - Focus on what matters to you")
                .navigationTitle("New Habit")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }
}

struct HabitReflectionView: View {
    let habit: Habit
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Reflection for \(habit.name ?? "")")
                .navigationTitle("Reflection")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }
}

struct DailyReflectionView: View {
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Daily Reflection")
                .navigationTitle("Reflect")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
        }
    }
}