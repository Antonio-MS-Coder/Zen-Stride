import SwiftUI
import CoreData

struct MinimalDashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header Section
                    headerSection
                        .padding(.horizontal, .notion16)
                        .padding(.vertical, .notion24)
                    
                    Divider()
                        .foregroundColor(.notionDivider)
                    
                    // Today's Habits
                    todaySection
                    
                    // Stats Section
                    if !viewModel.habits.isEmpty {
                        Divider()
                            .foregroundColor(.notionDivider)
                            .padding(.top, .notion24)
                        
                        statsSection
                            .padding(.vertical, .notion24)
                    }
                }
            }
            .background(Color.notionBackground)
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddHabit) {
                MinimalAddHabitView()
            }
            .sheet(item: $selectedHabit) { habit in
                MinimalHabitDetailView(habit: habit)
            }
            .overlay(
                toastOverlay
            )
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: .notion8) {
            Text(DateFormatter.dayFormatter.string(from: Date()))
                .font(.notionCaption)
                .foregroundColor(.notionTextTertiary)
            
            Text("Today")
                .font(.notionLargeTitle)
                .foregroundColor(.notionText)
            
            if let user = viewModel.currentUser {
                HStack(spacing: .notion16) {
                    statItem(value: "\(viewModel.habits.count)", label: "habits")
                    statItem(value: "\(Int(viewModel.todayCompletionRate * 100))%", label: "complete")
                    statItem(value: "\(user.currentLevel)", label: "level")
                }
                .padding(.top, .notion8)
            }
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        HStack(spacing: .notion4) {
            Text(value)
                .font(.notionSubheading)
                .foregroundColor(.notionText)
            Text(label)
                .font(.notionCaption)
                .foregroundColor(.notionTextSecondary)
        }
    }
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section Header
            HStack {
                Text("Habits")
                    .font(.notionSubheading)
                    .foregroundColor(.notionText)
                
                Spacer()
                
                Button(action: { showingAddHabit = true }) {
                    Image(systemName: "plus")
                        .font(.notionBody)
                        .foregroundColor(.notionTextSecondary)
                }
            }
            .padding(.horizontal, .notion16)
            .padding(.vertical, .notion12)
            
            // Habits List
            if viewModel.habits.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.habits) { habit in
                        MinimalHabitRow(
                            habit: habit,
                            isComplete: viewModel.getTodayProgress(for: habit)?.isComplete ?? false,
                            onTap: {
                                selectedHabit = habit
                            },
                            onToggle: {
                                toggleHabit(habit)
                            }
                        )
                        
                        if habit != viewModel.habits.last {
                            Divider()
                                .foregroundColor(.notionDivider)
                                .padding(.leading, .notion48)
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .notion16) {
            Text("No habits yet")
                .font(.notionBody)
                .foregroundColor(.notionTextSecondary)
            
            Button(action: { showingAddHabit = true }) {
                Text("Add your first habit")
                    .font(.notionBody)
                    .foregroundColor(.notionAccent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .notion48)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: .notion16) {
            Text("Statistics")
                .font(.notionSubheading)
                .foregroundColor(.notionText)
                .padding(.horizontal, .notion16)
            
            HStack(spacing: .notion16) {
                MinimalStatCard(
                    title: "Streak",
                    value: "\(viewModel.activeStreaks.first?.currentLength ?? 0)",
                    unit: "days"
                )
                
                MinimalStatCard(
                    title: "Points",
                    value: "\(viewModel.currentUser?.totalPoints ?? 0)",
                    unit: "total"
                )
                
                MinimalStatCard(
                    title: "Completed",
                    value: "\(viewModel.todayProgress.filter { $0.isComplete }.count)",
                    unit: "today"
                )
            }
            .padding(.horizontal, .notion16)
        }
    }
    
    private var toastOverlay: some View {
        VStack {
            if showToast {
                NotionToast(message: toastMessage, type: .success)
                    .padding(.horizontal, .notion16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
            }
            Spacer()
        }
        .padding(.top, .notion48)
    }
    
    // MARK: - Actions
    
    private func toggleHabit(_ habit: Habit) {
        let isCurrentlyComplete = viewModel.getTodayProgress(for: habit)?.isComplete ?? false
        
        if !isCurrentlyComplete {
            viewModel.logProgress(for: habit, value: habit.targetValue)
            toastMessage = "Great job! \(habit.name ?? "Habit") completed"
        } else {
            // Implement uncomplete if needed
            toastMessage = "\(habit.name ?? "Habit") marked as incomplete"
        }
        
        withAnimation(.notionDefault) {
            showToast = true
        }
        
        #if canImport(UIKit)
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        #endif
    }
}

// MARK: - Supporting Views

struct MinimalHabitRow: View {
    let habit: Habit
    let isComplete: Bool
    let onTap: () -> Void
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: .notion12) {
            // Checkbox
            NotionCheckbox(isChecked: isComplete, action: onToggle)
            
            // Habit Info
            VStack(alignment: .leading, spacing: .notion4) {
                Text(habit.name ?? "")
                    .font(.notionBody)
                    .foregroundColor(isComplete ? .notionTextTertiary : .notionText)
                    .strikethrough(isComplete)
                
                if let target = formatTarget(habit) {
                    Text(target)
                        .font(.notionCaption)
                        .foregroundColor(.notionTextTertiary)
                }
            }
            
            Spacer()
            
            // Streak indicator (if active)
            if let streak = getStreak(for: habit), streak > 0 {
                HStack(spacing: .notion4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.notionAccent)
                    Text("\(streak)")
                        .font(.notionCaption)
                        .foregroundColor(.notionTextSecondary)
                }
            }
        }
        .padding(.horizontal, .notion16)
        .padding(.vertical, .notion12)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    private func formatTarget(_ habit: Habit) -> String? {
        guard habit.targetValue > 0 else { return nil }
        let value = Int(habit.targetValue)
        let unit = habit.targetUnit ?? ""
        return "\(value) \(unit)"
    }
    
    private func getStreak(for habit: Habit) -> Int? {
        // This would need to be implemented properly with Core Data
        return nil
    }
}

struct MinimalStatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: .notion4) {
            Text(title)
                .font(.notionCaption)
                .foregroundColor(.notionTextTertiary)
            
            HStack(spacing: .notion4) {
                Text(value)
                    .font(.notionTitle)
                    .foregroundColor(.notionText)
                
                Text(unit)
                    .font(.notionCaption)
                    .foregroundColor(.notionTextSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.notion12)
        .notionCard()
    }
}

// MARK: - Date Formatter

extension DateFormatter {
    static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }()
}