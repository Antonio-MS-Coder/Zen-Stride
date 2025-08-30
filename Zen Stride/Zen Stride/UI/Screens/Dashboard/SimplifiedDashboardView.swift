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
            Text(getGreeting())
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
            
            Text("Your Goals")
                .font(.premiumLargeTitle)
                .foregroundColor(.premiumGray1)
        }
    }
    
    // MARK: - Update Reminders
    private var updateRemindersSection: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("NEEDS UPDATE")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            ForEach(goalsNeedingUpdate) { goal in
                UpdateReminderCard(goal: goal) {
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
    
    private func getGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<22: return "GOOD EVENING"
        default: return "GOOD NIGHT"
        }
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
                
                // Progress visualization
                VStack(alignment: .leading, spacing: .spacing8) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.premiumGray6)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: progressColors(for: goal.progress),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * goal.progress, height: 8)
                                .animation(.premiumSpring, value: goal.progress)
                        }
                    }
                    .frame(height: 8)
                    
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

struct UpdateReminderCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color.premiumAmber.opacity(0.2))
                    .frame(width: 8, height: 8)
                
                Text(goal.name)
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray1)
                
                Spacer()
                
                Text("Update now")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumIndigo)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.premiumIndigo)
            }
            .padding(.spacing12)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(Color.premiumAmber.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
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

struct EmptyGoalsCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing16) {
                Image(systemName: "target")
                    .font(.system(size: 32))
                    .foregroundColor(.premiumIndigo)
                
                Text("Set Your First Goal")
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray1)
                
                Text("Define what success looks like for you")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing40)
            .padding(.horizontal, .spacing24)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusL)
                            .stroke(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundColor(.premiumGray5)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}