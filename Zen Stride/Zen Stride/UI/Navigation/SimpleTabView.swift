import SwiftUI

struct SimpleTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickLog = false
    @State private var showingProfile = false
    @State private var goals: [Goal] = Goal.sampleGoals
    @StateObject private var dataStore = ZenStrideDataStore()
    
    var body: some View {
        ZStack {
            // Main content
            TabView(selection: $selectedTab) {
                // Today - Quick wins logging
                SimpleTodayView(goals: $goals, showingQuickLog: $showingQuickLog)
                    .tag(0)
                    .tabItem {
                        Label("Today", systemImage: "circle.fill")
                    }
                    .environmentObject(dataStore)
                
                // Progress - Visual journey over time
                SimpleProgressView(goals: $goals)
                    .tag(1)
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .environmentObject(dataStore)
            }
            .accentColor(.premiumIndigo)
            
            // Profile button in corner
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingProfile = true
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.premiumGray3)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            QuickLogView { win in
                dataStore.addWin(win)
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileSettingsView()
                .environmentObject(dataStore)
        }
    }
}

// MARK: - Simple Today View (Focus on logging)
struct SimpleTodayView: View {
    @Binding var goals: [Goal]
    @Binding var showingQuickLog: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                if goals.isEmpty {
                    // Clean empty state
                    VStack(spacing: 24) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.premiumIndigo.opacity(0.3))
                        
                        Text("Start your journey")
                            .font(.premiumTitle2)
                            .foregroundColor(.premiumGray2)
                        
                        Button {
                            showingQuickLog = true
                        } label: {
                            Text("Log your first win")
                                .font(.premiumHeadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 16)
                                .background(
                                    Capsule()
                                        .fill(Color.premiumIndigo)
                                )
                        }
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Simple greeting
                            HStack {
                                Text("Today")
                                    .font(.premiumLargeTitle)
                                    .foregroundColor(.premiumGray1)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Active goals with minimal info
                            ForEach(goals.filter { $0.isActive }) { goal in
                                MinimalGoalCard(goal: goal, onTap: {
                                    showingQuickLog = true
                                })
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 80)
                    }
                }
                
                // Floating action button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingQuickLog = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(Color.premiumIndigo)
                                )
                                .shadow(color: .premiumIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Minimal Goal Card (Less numbers, more visual)
struct MinimalGoalCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon only
                Image(systemName: goal.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.premiumIndigo)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                    
                    // Visual progress bar only - no numbers
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.premiumGray6)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.premiumIndigo.opacity(0.7))
                                .frame(width: geometry.size.width * goal.progress)
                        }
                    }
                    .frame(height: 4)
                }
                
                Spacer()
                
                // Simple status indicator
                if goal.progress >= 1.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.premiumMint)
                } else if goal.isUpdateDue {
                    Circle()
                        .fill(Color.premiumIndigo.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Simple Progress View (Visual focus)
struct SimpleProgressView: View {
    @Binding var goals: [Goal]
    @State private var selectedGoal: Goal?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                if goals.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 48))
                            .foregroundColor(.premiumGray4)
                        
                        Text("No progress yet")
                            .font(.premiumHeadline)
                            .foregroundColor(.premiumGray3)
                        
                        Text("Start logging to see your journey")
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray4)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Simple header
                            HStack {
                                Text("Progress")
                                    .font(.premiumLargeTitle)
                                    .foregroundColor(.premiumGray1)
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            // Goal progress cards
                            ForEach(goals) { goal in
                                ProgressCard(goal: goal, onTap: {
                                    selectedGoal = goal
                                })
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 80)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal, goals: $goals)
            }
        }
    }
}

// MARK: - Progress Card (Visual focused)
struct ProgressCard: View {
    let goal: Goal
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(goal.name)
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray4)
                }
                
                // Large visual progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.premiumGray6)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: progressGradient(for: goal.progress),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * goal.progress)
                    }
                }
                .frame(height: 24)
                
                // Minimal text info
                HStack {
                    if let daysLeft = goal.daysUntilDeadline, daysLeft > 0 {
                        Text("\(daysLeft) days left")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                    }
                    
                    Spacer()
                    
                    if goal.progress >= 1.0 {
                        Text("Complete")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumMint)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func progressGradient(for progress: Double) -> [Color] {
        switch progress {
        case 0..<0.3: return [Color.premiumGray4, Color.premiumGray3]
        case 0.3..<0.7: return [Color.premiumIndigo.opacity(0.6), Color.premiumIndigo]
        case 0.7..<1.0: return [Color.premiumIndigo, Color.premiumTeal]
        default: return [Color.premiumTeal, Color.premiumMint]
        }
    }
}

// MARK: - Goal Detail View (Dynamic per goal)
struct GoalDetailView: View {
    let goal: Goal
    @Binding var goals: [Goal]
    @Environment(\.dismiss) private var dismiss
    @State private var showingUpdateProgress = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Visual progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.premiumGray5, lineWidth: 20)
                                .frame(width: 200, height: 200)
                            
                            Circle()
                                .trim(from: 0, to: goal.progress)
                                .stroke(
                                    LinearGradient(
                                        colors: [.premiumIndigo, .premiumTeal],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(), value: goal.progress)
                            
                            VStack(spacing: 8) {
                                Text("\(Int(goal.progress * 100))%")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.premiumGray1)
                                
                                Text(goal.motivationalMessage)
                                    .font(.premiumCaption1)
                                    .foregroundColor(.premiumGray3)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(.top, 40)
                        
                        // Goal info
                        VStack(spacing: 20) {
                            InfoRow(label: "Type", value: goal.type.rawValue)
                            InfoRow(label: "Category", value: goal.category)
                            
                            if let deadline = goal.deadline {
                                InfoRow(
                                    label: "Deadline",
                                    value: DateFormatter.localizedString(from: deadline, dateStyle: .medium, timeStyle: .none)
                                )
                            }
                            
                            InfoRow(label: "Update frequency", value: goal.updateFrequency.rawValue)
                        }
                        .padding(.horizontal)
                        
                        // Recent updates (visual timeline)
                        if !goal.updates.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Journey")
                                    .font(.premiumHeadline)
                                    .foregroundColor(.premiumGray2)
                                    .padding(.horizontal)
                                
                                ForEach(goal.updates.reversed().prefix(5), id: \.date) { update in
                                    HStack {
                                        Circle()
                                            .fill(Color.premiumIndigo)
                                            .frame(width: 8, height: 8)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            if let note = update.note {
                                                Text(note)
                                                    .font(.premiumCallout)
                                                    .foregroundColor(.premiumGray2)
                                            }
                                            
                                            Text(RelativeDateTimeFormatter().localizedString(for: update.date, relativeTo: Date()))
                                                .font(.premiumCaption1)
                                                .foregroundColor(.premiumGray4)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // Update button
                        Button {
                            showingUpdateProgress = true
                        } label: {
                            Text("Update Progress")
                                .font(.premiumHeadline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.premiumIndigo)
                                )
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(goal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingUpdateProgress) {
                UpdateProgressView(goal: binding(for: goal), goals: $goals)
            }
        }
    }
    
    private func binding(for goal: Goal) -> Binding<Goal> {
        guard let index = goals.firstIndex(where: { $0.id == goal.id }) else {
            return .constant(goal)
        }
        return $goals[index]
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray3)
            
            Spacer()
            
            Text(value)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
        }
    }
}