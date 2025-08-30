import SwiftUI

struct SimplifiedDashboardView: View {
    @State private var goals = Goal.sampleGoals
    @State private var selectedGoal: Goal?
    @State private var showingAddGoal = false
    @State private var showingUpdateProgress = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: .spacing32) {
                        // Simple header
                        headerSection
                        
                        // Goals that need updates
                        if hasGoalsNeedingUpdate {
                            updateRemindersSection
                        }
                        
                        // Active goals - the main focus
                        activeGoalsSection
                        
                        // Completed goals (if any)
                        if hasCompletedGoals {
                            completedGoalsSection
                        }
                    }
                    .padding(.horizontal, .spacing20)
                    .padding(.vertical, .spacing24)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(goals: $goals)
            }
            .sheet(item: $selectedGoal) { goal in
                UpdateProgressView(goal: binding(for: goal), goals: $goals)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            Text(getEmotionalGreeting().greeting)
                .font(.premiumCaption1)
                .foregroundColor(.premiumIndigo.opacity(0.7))
                .tracking(0.5)
            
            Text(getEmotionalGreeting().subtitle)
                .font(.premiumLargeTitle)
                .foregroundColor(.premiumGray1)
        }
    }
    
    // MARK: - Update Reminders (Gentle Invitations)
    private var updateRemindersSection: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("READY FOR CHECK-IN")
                .font(.premiumCaption1)
                .foregroundColor(.premiumIndigo.opacity(0.7))
                .tracking(1.2)
            
            ForEach(goalsNeedingUpdate) { goal in
                GentleInvitationCard(goal: goal) {
                    selectedGoal = goal
                }
            }
        }
    }
    
    // MARK: - Active Goals
    private var activeGoalsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            HStack {
                Text("IN PROGRESS")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                Button {
                    showingAddGoal = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.premiumIndigo)
                }
            }
            
            if activeGoals.isEmpty {
                EmptyGoalsCard {
                    showingAddGoal = true
                }
            } else {
                ForEach(activeGoals) { goal in
                    SimplifiedGoalCard(goal: goal) {
                        selectedGoal = goal
                    }
                }
            }
        }
    }
    
    // MARK: - Completed Goals
    private var completedGoalsSection: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("COMPLETED")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            ForEach(completedGoals) { goal in
                CompletedGoalCard(goal: goal)
            }
        }
    }
    
    // MARK: - Helpers
    private var activeGoals: [Goal] {
        goals.filter { $0.isActive && $0.progress < 1.0 }
    }
    
    private var completedGoals: [Goal] {
        goals.filter { $0.progress >= 1.0 }
    }
    
    private var goalsNeedingUpdate: [Goal] {
        activeGoals.filter { $0.isUpdateDue }
    }
    
    private var hasGoalsNeedingUpdate: Bool {
        !goalsNeedingUpdate.isEmpty
    }
    
    private var hasCompletedGoals: Bool {
        !completedGoals.isEmpty
    }
    
    private func getEmotionalGreeting() -> (greeting: String, subtitle: String) {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        let hasRecentProgress = checkRecentProgress()
        let daysSinceLastUpdate = calculateDaysSinceLastUpdate()
        
        // Check for returning users
        if daysSinceLastUpdate > 3 {
            return ("Welcome back", "Every return is a victory")
        }
        
        // Weekend encouragement
        if dayOfWeek == 1 || dayOfWeek == 7 {
            if hasRecentProgress {
                return ("Weekend warrior", "Keep the momentum going")
            } else {
                return ("Weekend vibes", "Perfect time for progress")
            }
        }
        
        // Time-based emotional greetings
        switch hour {
        case 5..<9:
            return ("Fresh start", "Your intentions shape the day")
        case 9..<12:
            return ("Building momentum", "Small steps, big impact")
        case 12..<15:
            return ("Midday check-in", "Progress over perfection")
        case 15..<18:
            return ("Afternoon push", "You're closer than this morning")
        case 18..<22:
            return ("Evening reflection", "Today's efforts matter")
        case 22..<24:
            return ("Night owl", "Dedication after dark")
        default:
            return ("Late night", "Rest is part of progress")
        }
    }
    
    private func checkRecentProgress() -> Bool {
        // Check if user has made progress in last 24 hours
        let oneDayAgo = Date().addingTimeInterval(-86400)
        return goals.contains { goal in
            goal.updates.contains { $0.date > oneDayAgo }
        }
    }
    
    private func calculateDaysSinceLastUpdate() -> Int {
        let mostRecentUpdate = goals.compactMap { goal in
            goal.updates.max(by: { $0.date < $1.date })?.date
        }.max() ?? Date()
        
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: mostRecentUpdate, to: Date()).day ?? 0
    }
    
    private func binding(for goal: Goal) -> Binding<Goal> {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else {
            return .constant(goal)
        }
        return $goals[index]
    }
}

// MARK: - Goal Card Components
struct SimplifiedGoalCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: .spacing16) {
                // Header with icon and name
                HStack {
                    Image(systemName: goal.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.premiumIndigo)
                    
                    Text(goal.name)
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                    
                    Spacer()
                    
                    if goal.isOnTrack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.premiumMint)
                    } else if let daysLeft = goal.daysUntilDeadline, daysLeft < 7 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.premiumWarning)
                    }
                }
                
                // Progress visualization with momentum
                VStack(alignment: .leading, spacing: .spacing8) {
                    // Enhanced progress bar with momentum effects
                    EmotionalProgressBar(
                        progress: goal.progress,
                        colors: progressColors(for: goal.progress)
                    )
                    
                    // Progress text
                    HStack {
                        Text(goal.formattedProgress)
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray2)
                        
                        Spacer()
                        
                        Text("\(goal.progressPercentage)%")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                    }
                }
                
                // Bottom info
                HStack {
                    if let daysLeft = goal.daysUntilDeadline {
                        Label("\(daysLeft) days left", systemImage: "calendar")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                    }
                    
                    Spacer()
                    
                    Text(goal.motivationalMessage)
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumGray3)
                        .lineLimit(1)
                }
            }
            .padding(.spacing20)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowXS()
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func progressColors(for progress: Double) -> [Color] {
        switch progress {
        case 0..<0.3: return [Color.premiumGray4, Color.premiumGray3]
        case 0.3..<0.7: return [Color.premiumIndigo, Color.premiumBlue]
        case 0.7..<1.0: return [Color.premiumBlue, Color.premiumTeal]
        default: return [Color.premiumTeal, Color.premiumMint]
        }
    }
}

struct GentleInvitationCard: View {
    let goal: Goal
    let onTap: () -> Void
    @State private var breathe = false
    
    private var invitationText: String {
        let calendar = Calendar.current
        let lastUpdate = goal.updates.max(by: { $0.date < $1.date })?.date ?? goal.createdDate
        let daysSince = calendar.dateComponents([.day], from: lastUpdate, to: Date()).day ?? 0
        
        switch daysSince {
        case 0: return "Today's update?"
        case 1: return "Ready for today's check-in?"
        case 2...3: return "When you're ready"
        case 4...7: return "No pressure, just checking in"
        default: return "Whenever feels right"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: .spacing12) {
                // Soft, breathing dot instead of warning
                ZStack {
                    Circle()
                        .fill(Color.premiumIndigo.opacity(0.15))
                        .frame(width: 12, height: 12)
                        .scaleEffect(breathe ? 1.3 : 1.0)
                        .opacity(breathe ? 0.5 : 1.0)
                    
                    Circle()
                        .fill(Color.premiumIndigo.opacity(0.6))
                        .frame(width: 6, height: 6)
                }
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true),
                    value: breathe
                )
                
                VStack(alignment: .leading, spacing: .spacing4) {
                    Text(goal.name)
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray1)
                    
                    Text(invitationText)
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.premiumIndigo.opacity(0.5))
            }
            .padding(.horizontal, .spacing16)
            .padding(.vertical, .spacing14)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.premiumIndigo.opacity(0.03),
                                Color.premiumIndigo.opacity(0.06)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            breathe = true
        }
    }
}

struct CompletedGoalCard: View {
    let goal: Goal
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 24))
                .foregroundColor(.premiumMint)
            
            VStack(alignment: .leading, spacing: .spacing4) {
                Text(goal.name)
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                    .strikethrough()
                
                Text("Completed!")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumMint)
            }
            
            Spacer()
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.premiumMint.opacity(0.1))
        )
    }
}

// MARK: - Emotional Progress Bar
struct EmotionalProgressBar: View {
    let progress: Double
    let colors: [Color]
    @State private var showMomentum = false
    @State private var sparkleOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Base track
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.premiumGray6)
                    .frame(height: 8)
                
                // Progress bar with gradient
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 8)
                    .animation(.interpolatingSpring(stiffness: 120, damping: 15), value: progress)
                
                // Momentum glow effect when progress increases
                if showMomentum && progress > 0 && progress < 1 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    colors.first?.opacity(0.6) ?? Color.clear,
                                    colors.last?.opacity(0.3) ?? Color.clear,
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress + 30, height: 12)
                        .blur(radius: 6)
                        .opacity(showMomentum ? 0.8 : 0)
                        .animation(.easeOut(duration: 1.2), value: showMomentum)
                }
                
                // Leading edge sparkle for active progress
                if progress > 0 && progress < 1 {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 10, height: 10)
                        .blur(radius: 1)
                        .offset(x: geometry.size.width * progress - 5 + sparkleOffset)
                        .opacity(0.8)
                        .animation(
                            Animation.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                            value: sparkleOffset
                        )
                }
            }
        }
        .frame(height: 8)
        .onAppear {
            sparkleOffset = 2
        }
        .onChange(of: progress) { oldValue, newValue in
            if newValue > oldValue {
                showMomentum = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showMomentum = false
                }
            }
        }
    }
}

struct EmptyGoalsCard: View {
    let onTap: () -> Void
    @State private var breathe = false
    @State private var pulse = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing20) {
                // Breathing icon container
                ZStack {
                    Circle()
                        .fill(Color.premiumIndigo.opacity(0.08))
                        .frame(width: 80, height: 80)
                        .scaleEffect(breathe ? 1.15 : 1.0)
                        .opacity(breathe ? 0.6 : 1.0)
                    
                    Circle()
                        .fill(Color.premiumIndigo.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.premiumIndigo)
                        .scaleEffect(breathe ? 1.05 : 1.0)
                }
                .animation(
                    Animation.easeInOut(duration: 3)
                        .repeatForever(autoreverses: true),
                    value: breathe
                )
                .animation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(0.5),
                    value: pulse
                )
                
                VStack(spacing: .spacing8) {
                    Text("Ready when you are")
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                    
                    Text("No rush, no pressure")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray3)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing40)
            .padding(.horizontal, .spacing24)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.premiumGray6.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusL)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.premiumIndigo.opacity(0.1),
                                        Color.premiumIndigo.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
            )
            .premiumShadowXS()
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            breathe = true
            pulse = true
        }
    }
}