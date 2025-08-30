import SwiftUI
import CoreData
import Charts

struct PremiumHabitDetailView: View {
    let habit: Habit
    @ObservedObject var viewModel: ElegantDashboardViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedTimeRange = 0
    @State private var showingEditView = false
    @State private var showingDeleteConfirmation = false
    
    let timeRanges = ["Week", "Month", "Year"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing24) {
                        // Hero Card
                        heroCard
                            .padding(.top, .spacing20)
                        
                        // Time Range Selector
                        PremiumSegmentedControl(
                            selection: $selectedTimeRange,
                            options: timeRanges
                        )
                        
                        // Progress Chart
                        progressChart
                        
                        // Statistics Grid
                        statisticsGrid
                        
                        // Insights Section
                        insightsSection
                        
                        // Actions
                        actionButtons
                    }
                    .padding(.horizontal, .spacing20)
                    .padding(.bottom, .spacing32)
                }
            }
            .navigationTitle(habit.name ?? "Habit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.premiumIndigo)
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            // Edit view would go here
            Text("Edit Habit View")
        }
        .alert("Delete Habit", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteHabit()
            }
        } message: {
            Text("Are you sure you want to delete this habit? This action cannot be undone.")
        }
    }
    
    // MARK: - Hero Card
    private var heroCard: some View {
        VStack(spacing: .spacing20) {
            HStack(spacing: .spacing20) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.premiumIndigo.opacity(0.2), Color.premiumTeal.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: habit.iconName ?? "star.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.premiumIndigo)
                }
                
                VStack(alignment: .leading, spacing: .spacing4) {
                    Text(habit.name ?? "")
                        .font(.premiumTitle3)
                        .foregroundColor(.premiumGray1)
                    
                    Text(habit.category ?? "")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray3)
                    
                    if habit.targetValue > 1 {
                        Text("\(habit.targetValue) times \(habit.frequency?.lowercased() ?? "daily")")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                    }
                }
                
                Spacer()
                
                // Current Streak Badge
                VStack(spacing: .spacing4) {
                    Text("\(viewModel.getStreak(for: habit))")
                        .font(.premiumTitle1)
                        .foregroundColor(.premiumCoral)
                    
                    Label("Streak", systemImage: "flame.fill")
                        .font(.premiumCaption2)
                        .foregroundColor(.premiumGray3)
                }
            }
            
            // Today's Progress
            if let progress = viewModel.getTodayProgress(for: habit) {
                VStack(spacing: .spacing12) {
                    HStack {
                        Text("Today's Progress")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                        
                        Spacer()
                        
                        Text("\(progress.value)/\(habit.targetValue)")
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray2)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.premiumGray6)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.premiumIndigo, Color.premiumTeal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * (Double(progress.value) / Double(habit.targetValue)),
                                    height: 8
                                )
                                .animation(.premiumSpring, value: progress.value)
                        }
                    }
                    .frame(height: 8)
                }
            }
        }
        .padding(.spacing24)
        .premiumGlassCard()
    }
    
    // MARK: - Progress Chart
    private var progressChart: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("PROGRESS HISTORY")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Placeholder chart
            ZStack {
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
                    .frame(height: 200)
                
                // Sample data visualization
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { day in
                        VStack(spacing: .spacing4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.premiumIndigo.opacity(Double.random(in: 0.3...1)),
                                            Color.premiumTeal.opacity(Double.random(in: 0.3...1))
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: CGFloat.random(in: 40...150))
                            
                            Text(dayLabel(for: day))
                                .font(.premiumCaption2)
                                .foregroundColor(.premiumGray3)
                        }
                    }
                }
                .padding()
            }
            .premiumShadowS()
        }
        .padding(.horizontal, .spacing20)
        .padding(.vertical, .spacing16)
        .premiumGlassCard()
    }
    
    // MARK: - Statistics Grid
    private var statisticsGrid: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("STATISTICS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
                .padding(.horizontal, .spacing20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .spacing12) {
                PremiumStatisticCard(
                    title: "Total Completed",
                    value: "\(getTotalCompletions())",
                    icon: "checkmark.circle.fill",
                    color: .premiumMint
                )
                
                PremiumStatisticCard(
                    title: "Success Rate",
                    value: "\(getSuccessRate())%",
                    icon: "percent",
                    color: .premiumIndigo
                )
                
                PremiumStatisticCard(
                    title: "Best Streak",
                    value: "\(getBestStreak()) days",
                    icon: "crown.fill",
                    color: .premiumAmber
                )
                
                PremiumStatisticCard(
                    title: "Average/Week",
                    value: "\(getWeeklyAverage())",
                    icon: "chart.bar.fill",
                    color: .premiumTeal
                )
            }
            .padding(.horizontal, .spacing20)
        }
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("INSIGHTS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            VStack(alignment: .leading, spacing: .spacing12) {
                InsightRow(
                    icon: "lightbulb.fill",
                    text: getBestTimeInsight(),
                    color: .premiumAmber
                )
                
                InsightRow(
                    icon: "chart.line.uptrend.xyaxis",
                    text: getTrendInsight(),
                    color: .premiumMint
                )
                
                if let motivationalTip = getMotivationalTip() {
                    InsightRow(
                        icon: "star.fill",
                        text: motivationalTip,
                        color: .premiumIndigo
                    )
                }
            }
            .padding(.spacing20)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowXS()
        }
        .padding(.horizontal, .spacing20)
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: .spacing12) {
            Button {
                showingEditView = true
            } label: {
                Label("Edit Habit", systemImage: "pencil")
            }
            .buttonStyle(PremiumSecondaryButton())
            
            Button {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Habit", systemImage: "trash")
                    .foregroundColor(.premiumError)
            }
            .buttonStyle(PremiumTertiaryButton())
        }
        .padding(.horizontal, .spacing20)
    }
    
    // MARK: - Helper Methods
    private func dayLabel(for index: Int) -> String {
        let days = ["M", "T", "W", "T", "F", "S", "S"]
        return days[index]
    }
    
    private func getTotalCompletions() -> Int {
        // This would connect to the service
        return Int.random(in: 20...100)
    }
    
    private func getSuccessRate() -> Int {
        // This would connect to the service
        return Int.random(in: 65...95)
    }
    
    private func getWeeklyAverage() -> String {
        // This would connect to the service
        return String(format: "%.1f", Double.random(in: 4...6))
    }
    
    private func getBestStreak() -> Int {
        // This would connect to the service to get the best streak from Streak entity
        return Int.random(in: 7...30)
    }
    
    private func getBestTimeInsight() -> String {
        "You perform best in the morning"
    }
    
    private func getTrendInsight() -> String {
        "Your consistency improved by 23% this month"
    }
    
    private func getMotivationalTip() -> String? {
        let tips = [
            "Keep going! You're building a strong foundation",
            "Consistency is key to lasting change",
            "Small steps lead to big transformations",
            "You're closer than yesterday to your goal"
        ]
        return tips.randomElement()
    }
    
    private func deleteHabit() {
        viewModel.viewContext.delete(habit)
        do {
            try viewModel.viewContext.save()
            dismiss()
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
}

// MARK: - Supporting Views
struct PremiumStatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.premiumTitle2)
                .foregroundColor(.premiumGray1)
            
            Text(title)
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

struct InsightRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(text)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
    }
}