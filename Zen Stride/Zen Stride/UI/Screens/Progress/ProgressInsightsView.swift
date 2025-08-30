import SwiftUI
import Charts

struct ProgressInsightsView: View {
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @State private var selectedTimeRange = 0
    
    let timeRanges = ["Week", "Month", "Year"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing28) {
                        // Header with key insight
                        insightHeader
                        
                        // Time selector
                        timeRangeSelector
                        
                        // Visual progress story
                        weeklyProgressView
                        
                        // Compound Progress Mirror - NEW!
                        compoundProgressMirror
                        
                        // Patterns & Insights
                        patternsSection
                        
                        // Streak Saver indicator
                        streakSaverSection
                        
                        // Milestones
                        milestonesSection
                    }
                    .padding(.horizontal, .spacing20)
                    .padding(.top, .spacing24)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Insight Header
    private var insightHeader: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("PROGRESS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            Text("Your Journey")
                .font(.premiumLargeTitle)
                .foregroundColor(.premiumGray1)
            
            // Key insight
            HStack(spacing: .spacing8) {
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.premiumMint)
                
                Text("You're 23% more consistent than last month")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
            }
            .padding(.spacing12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(Color.premiumMint.opacity(0.1))
            )
        }
    }
    
    // MARK: - Time Range Selector
    private var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<timeRanges.count, id: \.self) { index in
                Button {
                    withAnimation(.premiumSmooth) {
                        selectedTimeRange = index
                    }
                } label: {
                    Text(timeRanges[index])
                        .font(.premiumCallout)
                        .foregroundColor(selectedTimeRange == index ? .premiumIndigo : .premiumGray3)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, .spacing8)
                        .background(
                            selectedTimeRange == index ?
                            Color.premiumIndigo.opacity(0.1) : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: .radiusS))
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
    
    // MARK: - Weekly Progress
    private var weeklyProgressView: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("ACTIVITY")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Modern chart view
            chartView
            
            // Habit breakdown
            habitBreakdownView
            
            // Summary stats
            statsGrid
        }
    }
    
    // MARK: - Chart View
    private var chartView: some View {
        let weekData = dataStore.getWeeklyProgress()
        
        return VStack(alignment: .leading, spacing: .spacing12) {
            // Simple bar chart - cleaner and more readable
            Chart(weekData) { day in
                BarMark(
                    x: .value("Day", dayLabel(for: day.date)),
                    y: .value("Wins", day.wins)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.premiumIndigo, Color.premiumIndigo.opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYScale(domain: 0...10)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisValueLabel()
                        .font(.premiumCaption2)
                        .foregroundStyle(Color.premiumGray3)
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 2)) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.premiumGray6)
                    AxisValueLabel()
                        .font(.premiumCaption2)
                        .foregroundStyle(Color.premiumGray3)
                }
            }
            .padding(.spacing16)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowXS()
        }
    }
    
    // MARK: - Habit Breakdown
    private var habitBreakdownView: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("Habit Distribution")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray2)
            
            // Horizontal bar chart for habits
            VStack(spacing: .spacing8) {
                HabitBar(name: "Reading", value: 0.7, color: .premiumIndigo)
                HabitBar(name: "Exercise", value: 0.5, color: .premiumTeal)
                HabitBar(name: "Meditation", value: 0.3, color: .premiumMint)
                HabitBar(name: "Water", value: 0.9, color: .premiumBlue)
            }
            .padding(.spacing16)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowXS()
        }
    }
    
    // MARK: - Stats Grid
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: .spacing12) {
            ProgressStatCard(
                icon: "checkmark.circle.fill",
                value: "\(dataStore.todaysWins.count)",
                label: "Today",
                color: .premiumMint
            )
            
            ProgressStatCard(
                icon: "flame.fill",
                value: "\(dataStore.streakDays)",
                label: "Day Streak",
                color: .premiumCoral
            )
            
            ProgressStatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "+23%",
                label: "This Week",
                color: .premiumIndigo
            )
            
            ProgressStatCard(
                icon: "star.fill",
                value: "47",
                label: "Total Wins",
                color: .premiumAmber
            )
        }
    }
    
    // MARK: - Compound Progress Mirror
    private var compoundProgressMirror: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("YOUR FUTURE SELF")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Time travel visualization
            VStack(spacing: .spacing20) {
                // Today's pace
                HStack {
                    VStack(alignment: .leading, spacing: .spacing4) {
                        Text("Today")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                        Text("4 wins")
                            .font(.premiumHeadline)
                            .foregroundColor(.premiumGray1)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.premiumGray5)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: .spacing4) {
                        Text("In 1 Year")
                            .font(.premiumCaption1)
                            .foregroundColor(.premiumGray3)
                        Text("1,460 wins")
                            .font(.premiumHeadline)
                            .foregroundColor(.premiumIndigo)
                    }
                }
                
                // Visual projections
                VStack(spacing: .spacing12) {
                    FutureProjection(
                        icon: "book.fill",
                        current: "15 pages",
                        future: "18 books",
                        timeframe: "this year",
                        color: .premiumIndigo
                    )
                    
                    FutureProjection(
                        icon: "figure.run",
                        current: "20 min",
                        future: "121 hours",
                        timeframe: "this year",
                        color: .premiumTeal
                    )
                    
                    FutureProjection(
                        icon: "brain.head.profile",
                        current: "10 min",
                        future: "60 hours",
                        timeframe: "of mindfulness",
                        color: .premiumMint
                    )
                }
                
                // Motivational message
                Text("Small daily actions compound into life-changing results")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.top, .spacing8)
            }
            .padding(.spacing20)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white,
                                Color.premiumIndigo.opacity(0.02)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusL)
                    .stroke(Color.premiumIndigo.opacity(0.1), lineWidth: 1)
            )
            .premiumShadowS()
        }
    }
    
    // MARK: - Streak Saver Section
    private var streakSaverSection: some View {
        HStack(spacing: .spacing16) {
            Image(systemName: "shield.fill")
                .font(.system(size: 24))
                .foregroundColor(.premiumAmber)
            
            VStack(alignment: .leading, spacing: .spacing4) {
                Text("Streak Savers")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray1)
                
                Text("\(dataStore.streakSaverTokens) tokens remaining this month")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
            }
            
            Spacer()
            
            // Visual tokens
            HStack(spacing: .spacing4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(index < dataStore.streakSaverTokens ? Color.premiumAmber : Color.premiumGray5)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.premiumAmber.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: .radiusM)
                .stroke(Color.premiumAmber.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Patterns Section
    private var patternsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("PATTERNS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            VStack(spacing: .spacing12) {
                PatternCard(
                    icon: "sunrise.fill",
                    title: "Best Time",
                    value: "Morning",
                    description: "8-10 AM",
                    color: .premiumAmber
                )
                
                PatternCard(
                    icon: "star.fill",
                    title: "Top Habit",
                    value: "Reading",
                    description: "15 pages daily avg",
                    color: .premiumIndigo
                )
                
                PatternCard(
                    icon: "calendar",
                    title: "Most Active",
                    value: "Weekdays",
                    description: "Mon, Wed, Fri",
                    color: .premiumTeal
                )
            }
        }
    }
    
    // MARK: - Milestones
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("MILESTONES")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .spacing12) {
                    MilestoneCard(
                        icon: "book.fill",
                        title: "First Book",
                        subtitle: "Completed",
                        isAchieved: true
                    )
                    
                    MilestoneCard(
                        icon: "flame.fill",
                        title: "7 Day Streak",
                        subtitle: "Achieved!",
                        isAchieved: true
                    )
                    
                    MilestoneCard(
                        icon: "trophy.fill",
                        title: "30 Day Streak",
                        subtitle: "23 days to go",
                        isAchieved: false
                    )
                    
                    MilestoneCard(
                        icon: "star.fill",
                        title: "100 Wins",
                        subtitle: "78 completed",
                        isAchieved: false
                    )
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Pattern Card
struct PatternCard: View {
    let icon: String
    let title: String
    let value: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: .spacing4) {
                Text(title)
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                
                Text(value)
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray1)
            }
            
            Spacer()
            
            // Description
            Text(description)
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

// MARK: - Milestone Card
// MARK: - Habit Bar
struct HabitBar: View {
    let name: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing12) {
            Text(name)
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray2)
                .frame(width: 80, alignment: .leading)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.premiumGray6)
                        .frame(height: 8)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
            
            Text("\(Int(value * 100))%")
                .font(.premiumCaption2)
                .foregroundColor(.premiumGray3)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

// MARK: - Progress Stat Card
struct ProgressStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: .spacing8) {
            HStack(spacing: .spacing4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.premiumTitle3)
                    .foregroundColor(.premiumGray1)
            }
            
            Text(label)
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity)
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

struct MilestoneCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let isAchieved: Bool
    
    var body: some View {
        VStack(spacing: .spacing12) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        isAchieved ?
                        LinearGradient(
                            colors: [Color.premiumIndigo, Color.premiumTeal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.premiumGray5],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Text
            VStack(spacing: .spacing4) {
                Text(title)
                    .font(.premiumCallout)
                    .foregroundColor(isAchieved ? .premiumGray1 : .premiumGray3)
                
                Text(subtitle)
                    .font(.premiumCaption2)
                    .foregroundColor(isAchieved ? .premiumMint : .premiumGray3)
            }
        }
        .frame(width: 120)
        .padding(.vertical, .spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .overlay(
            isAchieved ?
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20))
                .foregroundColor(.premiumMint)
                .offset(x: -8, y: -8) : nil,
            alignment: .topTrailing
        )
        .premiumShadowXS()
    }
}

// MARK: - Future Projection Component
struct FutureProjection: View {
    let icon: String
    let current: String
    let future: String
    let timeframe: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .spacing16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32)
            
            // Current
            Text(current)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray2)
                .frame(width: 80, alignment: .leading)
            
            // Progress indicator
            Image(systemName: "arrow.right")
                .font(.system(size: 12))
                .foregroundColor(.premiumGray5)
            
            // Future
            VStack(alignment: .leading, spacing: 0) {
                Text(future)
                    .font(.premiumHeadline)
                    .foregroundColor(color)
                Text(timeframe)
                    .font(.premiumCaption2)
                    .foregroundColor(.premiumGray3)
            }
            
            Spacer()
        }
        .padding(.vertical, .spacing8)
    }
}