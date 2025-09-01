import SwiftUI
import UIKit
import Photos

// MARK: - Achievement Level
enum AchievementLevel {
    case legendary  // 100%
    case epic      // 75-99%
    case great     // 50-74%
    case good      // 25-49%
    case starting  // 0-24%
    
    var title: String {
        switch self {
        case .legendary: return "UNSTOPPABLE FORCE"
        case .epic: return "CRUSHING IT"
        case .great: return "ON FIRE"
        case .good: return "BUILDING MOMENTUM"
        case .starting: return "JOURNEY BEGINS"
        }
    }
    
    var icon: String {
        switch self {
        case .legendary: return "crown.fill"
        case .epic: return "star.fill"
        case .great: return "flame.fill"
        case .good: return "checkmark.circle.fill"
        case .starting: return "arrow.up.circle.fill"
        }
    }
    
    var gradient: [Color] {
        switch self {
        case .legendary: return [.yellow, .orange, .pink]
        case .epic: return [.purple, .pink, .orange]
        case .great: return [.orange, .red]
        case .good: return [.blue, .purple]
        case .starting: return [.gray, .blue]
        }
    }
    
    var mascotMood: MascotMood {
        switch self {
        case .legendary, .epic: return .celebrating
        case .great: return .heart
        case .good: return .waving
        case .starting: return .neutral
        }
    }
}

struct ShareProgressViewEnhanced: View {
    let habit: HabitModel
    let wins: [MicroWin]
    let selectedVisualization: Int
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedFormat = 0 // 0: Story, 1: Square
    @State private var selectedTheme = 0 // 0: Light, 1: Dark
    @State private var includeStreak = true
    @State private var isGenerating = false
    @State private var saveInProgress = false
    @State private var showingSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var showActualSize = false
    @State private var generationError: String?
    @State private var showFullPreview = false
    
    private var formats: [(name: String, hint: String)] {
        [
            ("Story (9:16)", "Instagram Stories, TikTok, Snapchat"),
            ("Square (1:1)", "Instagram Posts, Twitter, Facebook")
        ]
    }
    
    private var themes: [String] {
        return ["Light", "Dark"]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ThemeManager.shared.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Preview with improved scaling
                        enhancedPreviewSection
                        
                        // Customization with better UX
                        enhancedCustomizationSection
                        
                        // Save button only
                        saveToPhotosButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
                
                // Full size preview overlay
                if showFullPreview {
                    fullSizePreviewOverlay
                }
            }
            .navigationTitle("Share Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Share Status", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveAlertMessage)
            }
            .alert("Generation Error", isPresented: .constant(generationError != nil)) {
                Button("Try Again") {
                    generationError = nil
                }
                Button("Cancel", role: .cancel) {
                    generationError = nil
                }
            } message: {
                Text(generationError ?? "")
            }
        }
    }
    
    // MARK: - Enhanced Preview Section
    private var enhancedPreviewSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("PREVIEW")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .tracking(1)
                
                Spacer()
                
                // Preview control
                Button {
                    showFullPreview = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 12))
                        Text("Full View")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.premiumIndigo)
                }
                .accessibilityLabel("View full size preview")
            }
            
            // Preview container with fixed height and proportional width
            let previewHeight: CGFloat = 360
            let storyWidth = previewHeight * 9/16  // 202.5
            let squareWidth = previewHeight  // 360
            
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(UIColor.systemGray6),
                                Color(UIColor.systemGray5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: selectedFormat == 0 ? storyWidth : squareWidth, height: previewHeight)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // Content preview - scale to fit the fixed window
                Group {
                    if selectedFormat == 0 {
                        EnhancedStoryCard(
                            habit: habit,
                            wins: wins,
                            includeStreak: includeStreak,
                            theme: selectedTheme
                        )
                        .frame(width: 1080, height: 1920)
                        .scaleEffect(previewHeight / 1920)
                    } else {
                        EnhancedSquareCard(
                            habit: habit,
                            wins: wins,
                            includeStreak: includeStreak,
                            theme: selectedTheme
                        )
                        .frame(width: 1080, height: 1080)
                        .scaleEffect(previewHeight / 1080)
                    }
                }
                .frame(width: selectedFormat == 0 ? storyWidth : squareWidth, height: previewHeight)
                .clipped()
                .cornerRadius(16)
            }
            .frame(height: previewHeight + 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedFormat)
            .accessibilityLabel("Progress card preview showing \(Int(calculateProgress() * 100))% completion")
        }
    }
    
    // MARK: - Enhanced Customization Section
    private var enhancedCustomizationSection: some View {
        VStack(spacing: 20) {
            // Format selector with platform hints
            VStack(alignment: .leading, spacing: 8) {
                Text("FORMAT")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .tracking(1)
                
                VStack(spacing: 0) {
                    ForEach(0..<formats.count, id: \.self) { index in
                        Button {
                            selectedFormat = index
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(formats[index].name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(selectedFormat == index ? .premiumIndigo : ThemeManager.shared.primaryText)
                                    
                                    Text(formats[index].hint)
                                        .font(.system(size: 11))
                                        .foregroundColor(ThemeManager.shared.tertiaryText)
                                }
                                
                                Spacer()
                                
                                if selectedFormat == index {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.premiumIndigo)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                selectedFormat == index ?
                                Color.premiumIndigo.opacity(0.1) : Color.clear
                            )
                        }
                        
                        if index < formats.count - 1 {
                            Divider()
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ThemeManager.shared.secondaryBackground.opacity(0.5))
                )
            }
            
            // Theme selector with icons
            VStack(alignment: .leading, spacing: 8) {
                Text("THEME")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .tracking(1)
                
                HStack(spacing: 12) {
                    ForEach(0..<themes.count, id: \.self) { index in
                        Button {
                            selectedTheme = index
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: index == 0 ? "sun.max.fill" : "moon.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(selectedTheme == index ? .white : ThemeManager.shared.primaryText)
                                
                                Text(themes[index])
                                    .font(.system(size: 10))
                                    .foregroundColor(selectedTheme == index ? .white : ThemeManager.shared.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTheme == index ? Color.premiumIndigo : ThemeManager.shared.secondaryBackground.opacity(0.5))
                            )
                        }
                    }
                }
            }
            
            // Options with accessibility improvements
            VStack(spacing: 16) {
                Toggle("Include Streak", isOn: $includeStreak)
                    .tint(.premiumIndigo)
                    .accessibilityHint("Shows your current habit streak in the shared image")
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(ThemeManager.shared.secondaryBackground.opacity(0.5))
            )
        }
    }
    
    // MARK: - Save Button
    private var saveToPhotosButton: some View {
        Button {
            saveToPhotosEnhanced()
        } label: {
            HStack {
                if saveInProgress {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save to Photos")
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.premiumIndigo)
            )
        }
        .disabled(saveInProgress)
    }
    
    // MARK: - Full Size Preview Overlay
    private var fullSizePreviewOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .onTapGesture {
                    showFullPreview = false
                }
            
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showFullPreview = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .padding()
                }
                
                Spacer()
                
                Group {
                    if selectedFormat == 0 {
                        EnhancedStoryCard(
                            habit: habit,
                            wins: wins,
                            includeStreak: includeStreak,
                            theme: selectedTheme
                        )
                        .frame(width: 540, height: 960)
                    } else {
                        EnhancedSquareCard(
                            habit: habit,
                            wins: wins,
                            includeStreak: includeStreak,
                            theme: selectedTheme
                        )
                        .frame(width: 540, height: 540)
                    }
                }
                .cornerRadius(20)
                .shadow(radius: 20)
                
                Spacer()
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: showFullPreview)
    }
    
    // MARK: - Helper Functions
    private func calculateProgress() -> CGFloat {
        // For check type habits, show completion percentage for the week
        if habit.trackingType == .check {
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentWins = wins.filter { $0.timestamp > weekAgo }
            let daysWithWins = Set(recentWins.map { calendar.startOfDay(for: $0.timestamp) }).count
            return CGFloat(daysWithWins) / 7.0
        }
        
        // For numeric habits, try today first, then most recent day
        guard let target = habit.targetValue else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        if !todayWins.isEmpty {
            let total = todayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            return min(CGFloat(total / target), 1.0)
        } else if !wins.isEmpty {
            // If no wins today, show the most recent day's progress
            let sortedWins = wins.sorted { $0.timestamp > $1.timestamp }
            if let mostRecentDate = sortedWins.first?.timestamp {
                let dayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: mostRecentDate) }
                let total = dayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                return min(CGFloat(total / target), 1.0)
            }
        }
        
        return 0
    }
    
    
    
    
    
    private func saveToPhotosEnhanced() {
        saveInProgress = true
        
        let renderer = ImageRenderer(
            content: Group {
                if selectedFormat == 0 {
                    EnhancedStoryCard(
                        habit: habit,
                        wins: wins,
                        includeStreak: includeStreak,
                        theme: selectedTheme
                    )
                    .frame(width: 1080, height: 1920)
                } else {
                    EnhancedSquareCard(
                        habit: habit,
                        wins: wins,
                        includeStreak: includeStreak,
                        theme: selectedTheme
                    )
                    .frame(width: 1080, height: 1080)
                }
            }
        )
        
        renderer.scale = 1.0
        
        if let image = renderer.uiImage {
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        
                        // Haptic feedback
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        saveAlertMessage = "✓ Progress card saved to Photos!"
                        showingSaveAlert = true
                        saveInProgress = false
                        
                    case .denied, .restricted:
                        saveAlertMessage = "Please enable photo library access in Settings to save images."
                        showingSaveAlert = true
                        saveInProgress = false
                        
                    case .notDetermined:
                        saveInProgress = false
                        
                    @unknown default:
                        saveInProgress = false
                    }
                }
            }
        } else {
            saveInProgress = false
            saveAlertMessage = "Failed to generate image. Please try again."
            showingSaveAlert = true
        }
    }
}


// MARK: - Enhanced Story Card
struct EnhancedStoryCard: View {
    let habit: HabitModel
    let wins: [MicroWin]
    let includeStreak: Bool
    let theme: Int
    
    private var achievementLevel: AchievementLevel {
        let progress = calculateProgress()
        if progress >= 1.0 { return .legendary }
        if progress >= 0.75 { return .epic }
        if progress >= 0.5 { return .great }
        if progress >= 0.25 { return .good }
        return .starting
    }
    
    private var backgroundColor: Color {
        theme == 0 ? Color.white : Color.black
    }
    
    private var textColor: Color {
        theme == 0 ? Color.black : Color.white
    }
    
    var body: some View {
        ZStack {
            // Background - pure white for light mode
            if theme == 0 {
                Color.white
            } else {
                LinearGradient(
                    colors: [backgroundColor, habit.color.opacity(0.3), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            
            // Achievement glow effect for high levels
            if achievementLevel == .legendary || achievementLevel == .epic {
                RadialGradient(
                    colors: [
                        habit.color.opacity(theme == 0 ? 0.1 : 0.3),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
                .blendMode(theme == 0 ? .normal : .plusLighter)
            }
            
            VStack(spacing: 0) {
                // Top section with achievement and habit only
                VStack(spacing: 20) {
                    Text(achievementLevel.title)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(habit.color)
                        .shadow(color: habit.color.opacity(0.3), radius: 10)
                    
                    Text(habit.name)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .minimumScaleFactor(0.5)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 120)
                
                Spacer()
                
                // Main progress visualization - centered
                if !includeStreak {
                    Spacer()
                }
                
                progressVisualization
                    .scaleEffect(1.35)
                
                if includeStreak {
                    Spacer()
                    
                    // Stats section
                    statsSection
                        .padding(.bottom, 60)
                    
                    Spacer()
                } else {
                    Spacer()
                    Spacer()
                }
                
                // Bottom section with mascot and branding
                VStack(spacing: 30) {
                    // Mascot with tagline
                    VStack(spacing: 20) {
                        MascotView(mood: achievementLevel.mascotMood, size: 220)
                            .shadow(radius: 15)
                        
                        Text("Build better habits, one day at a time")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(textColor.opacity(theme == 0 ? 0.8 : 0.7))
                    }
                    
                    // Bottom branding
                    Text("IGNITE")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.opacity(theme == 0 ? 0.9 : 0.8))
                        .tracking(3)
                        .padding(.bottom, 80)
                }
            }
        }
    }
    
    // Removed headerSection - now integrated into main body
    
    private var progressVisualization: some View {
        ZStack {
            // Outer glow
            Circle()
                .stroke(
                    LinearGradient(
                        colors: achievementLevel.gradient.map { $0.opacity(0.3) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 35
                )
                .frame(width: 360, height: 360)
                .blur(radius: 22)
            
            // Progress circle
            ZStack {
                Circle()
                    .stroke(theme == 0 ? Color.gray.opacity(0.15) : Color.white.opacity(0.1), lineWidth: 28)
                    .frame(width: 320, height: 320)
                
                Circle()
                    .trim(from: 0, to: calculateProgress())
                    .stroke(
                        LinearGradient(
                            colors: achievementLevel.gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 28, lineCap: .round)
                    )
                    .frame(width: 320, height: 320)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: habit.color, radius: 12)
                
                VStack(spacing: 10) {
                    // Achievement icon
                    Image(systemName: achievementLevel.icon)
                        .font(.system(size: 46))
                        .foregroundColor(habit.color)
                    
                    Text("\(Int(calculateProgress() * 100))%")
                        .font(.system(size: achievementLevel == .legendary ? 82 : 72, weight: .bold, design: .rounded))
                        .foregroundColor(textColor)
                    
                    if habit.trackingType == .check {
                        Text("of 7 days this week")
                            .font(.system(size: 20))
                            .foregroundColor(textColor.opacity(0.7))
                    } else if let targetValue = habit.targetValue {
                        Text("of \(Int(targetValue)) \(habit.unit ?? "")")
                            .font(.system(size: 20))
                            .foregroundColor(textColor.opacity(0.7))
                    }
                }
            }
        }
    }
    
    private var statsSection: some View {
        HStack(spacing: 30) {
            StatCardEnhanced(
                value: "\(calculateStreak())",
                label: "Day Streak",
                icon: "flame.fill",
                color: .orange,
                isHighlighted: calculateStreak() >= 7,
                theme: theme
            )
            
            StatCardEnhanced(
                value: "\(wins.count)",
                label: "Total Wins",
                icon: "trophy.fill",
                color: .yellow,
                isHighlighted: wins.count >= 30,
                theme: theme
            )
            
            StatCardEnhanced(
                value: String(format: "%.1f", calculateDailyAverage()),
                label: "Daily Avg",
                icon: "chart.line.uptrend.xyaxis",
                color: habit.color,
                isHighlighted: false,
                theme: theme
            )
        }
        .padding(.horizontal, 80)
    }
    
    
    private func calculateProgress() -> CGFloat {
        // For check type habits, show completion percentage for the week
        if habit.trackingType == .check {
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentWins = wins.filter { $0.timestamp > weekAgo }
            let daysWithWins = Set(recentWins.map { calendar.startOfDay(for: $0.timestamp) }).count
            return CGFloat(daysWithWins) / 7.0
        }
        
        // For numeric habits, try today first, then most recent day
        guard let target = habit.targetValue else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        if !todayWins.isEmpty {
            let total = todayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            return min(CGFloat(total / target), 1.0)
        } else if !wins.isEmpty {
            // If no wins today, show the most recent day's progress
            let sortedWins = wins.sorted { $0.timestamp > $1.timestamp }
            if let mostRecentDate = sortedWins.first?.timestamp {
                let dayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: mostRecentDate) }
                let total = dayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                return min(CGFloat(total / target), 1.0)
            }
        }
        
        return 0
    }
    
    private func calculateStreak() -> Int {
        guard !wins.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDates = Set(wins.map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDates = Array(uniqueDates).sorted(by: >)
        
        guard let mostRecent = sortedDates.first,
              calendar.isDateInToday(mostRecent) || calendar.isDateInYesterday(mostRecent) else {
            return 0
        }
        
        var streak = 0
        var currentDate = calendar.isDateInToday(mostRecent) ? mostRecent : calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateDailyAverage() -> Double {
        guard !wins.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(wins.map { calendar.startOfDay(for: $0.timestamp) }).count
        let totalValue = wins.reduce(0) { $0 + (Double($1.value) ?? 1) }
        return totalValue / Double(max(uniqueDays, 1))
    }
}

// MARK: - Enhanced Square Card
struct EnhancedSquareCard: View {
    let habit: HabitModel
    let wins: [MicroWin]
    let includeStreak: Bool
    let theme: Int
    
    private var achievementLevel: AchievementLevel {
        let progress = calculateProgress()
        if progress >= 1.0 { return .legendary }
        if progress >= 0.75 { return .epic }
        if progress >= 0.5 { return .great }
        if progress >= 0.25 { return .good }
        return .starting
    }
    
    private var backgroundColor: Color {
        theme == 0 ? Color.white : Color.black
    }
    
    private var textColor: Color {
        theme == 0 ? Color.black : Color.white
    }
    
    var body: some View {
        ZStack {
            // Background with better contrast
            LinearGradient(
                colors: theme == 0 ?
                    [Color.white, Color.white] :
                    [backgroundColor, habit.color.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 0) {
                // Remove header - no longer needed
                // We'll keep IGNITE only at the bottom
                
                // Habit title with achievement - moved up with top padding
                VStack(spacing: 8) {
                    Text(achievementLevel.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(habit.color)
                        .tracking(1.2)
                    
                    Text(habit.name)
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(textColor)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)
                .padding(.bottom, 20)
                
                // Circular progress meter - centered when no streak
                if !includeStreak {
                    Spacer()
                }
                
                circularProgressMeter
                    .padding(.bottom, includeStreak ? 20 : 0)
                
                if includeStreak {
                    // Data visualization (weekly bars or calendar)
                    Group {
                        if achievementLevel == .legendary || achievementLevel == .epic {
                            weeklyBarsCompact
                        } else {
                            calendarHeatmapCompact
                        }
                    }
                    .padding(.bottom, 15)
                    
                    // Stats row
                    compactStatsRow
                        .padding(.bottom, 15)
                } else {
                    Spacer()
                }
                
                Spacer(minLength: 5)
                
                // Larger mascot with tagline
                VStack(spacing: 10) {
                    MascotView(mood: achievementLevel.mascotMood, size: 140)
                    
                    Text("Build better habits, one day at a time")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(textColor.opacity(0.7))
                    
                    // Bottom branding
                    Text("IGNITE")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(textColor.opacity(0.85))
                        .tracking(2)
                }
                .padding(.bottom, 20)
            }
            .padding(25)
        }
    }
    
    
    private var circularProgressMeter: some View {
        ZStack {
            Circle()
                .stroke(
                    theme == 0 ? Color.gray.opacity(0.15) : Color.white.opacity(0.1),
                    lineWidth: 12
                )
                .frame(width: 140, height: 140)
            
            Circle()
                .trim(from: 0, to: calculateProgress())
                .stroke(
                    LinearGradient(
                        colors: achievementLevel.gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .shadow(color: habit.color.opacity(0.5), radius: 5)
            
            VStack(spacing: 2) {
                Text("\(Int(calculateProgress() * 100))%")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                
                if habit.trackingType == .check {
                    let daysCompleted = Int(calculateProgress() * 7)
                    Text("\(daysCompleted)/7 days")
                        .font(.system(size: 11))
                        .foregroundColor(textColor.opacity(0.6))
                } else if let targetValue = habit.targetValue {
                    Text("\(Int(calculateProgress() * targetValue))/\(Int(targetValue))")
                        .font(.system(size: 11))
                        .foregroundColor(textColor.opacity(0.6))
                }
            }
        }
    }
    
    private var weeklyBarsCompact: some View {
        HStack(spacing: 6) {
            ForEach(0..<7, id: \.self) { dayIndex in
                let value = getValueForDay(dayIndex)
                VStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: value > 0 ? [habit.color.opacity(0.8), habit.color] : [Color.gray.opacity(0.2)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: max(CGFloat(value) * 8, value > 0 ? 4 : 2))
                        .frame(maxHeight: 50)
                    
                    Text(getDayLabel(dayIndex))
                        .font(.system(size: 9))
                        .foregroundColor(textColor.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 15)
    }
    
    private var calendarHeatmapCompact: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
            ForEach(0..<28, id: \.self) { index in
                let value = getHeatmapValue(for: index)
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        value > 0 ?
                        habit.color.opacity(max(0.3, min(1.0, value))) :
                        (theme == 0 ? Color.gray.opacity(0.1) : Color.white.opacity(0.05))
                    )
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(.horizontal, 30)
    }
    
    private var compactStatsRow: some View {
        HStack(spacing: 20) {
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    Text("\(calculateStreak())")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }
                Text("Streak")
                    .font(.system(size: 9))
                    .foregroundColor(textColor.opacity(0.6))
            }
            
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("\(wins.count)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }
                Text("Total")
                    .font(.system(size: 9))
                    .foregroundColor(textColor.opacity(0.6))
            }
            
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 12))
                        .foregroundColor(habit.color)
                    Text(String(format: "%.1f", calculateDailyAverage()))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(textColor)
                }
                Text("Daily")
                    .font(.system(size: 9))
                    .foregroundColor(textColor.opacity(0.6))
            }
        }
    }
    
    
    // Helper functions
    private func calculateProgress() -> CGFloat {
        // For check type habits, show completion percentage for the week
        if habit.trackingType == .check {
            let calendar = Calendar.current
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let recentWins = wins.filter { $0.timestamp > weekAgo }
            let daysWithWins = Set(recentWins.map { calendar.startOfDay(for: $0.timestamp) }).count
            return CGFloat(daysWithWins) / 7.0
        }
        
        // For numeric habits, try today first, then most recent day
        guard let target = habit.targetValue else { return 0 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let todayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: today) }
        
        if !todayWins.isEmpty {
            let total = todayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
            return min(CGFloat(total / target), 1.0)
        } else if !wins.isEmpty {
            // If no wins today, show the most recent day's progress
            let sortedWins = wins.sorted { $0.timestamp > $1.timestamp }
            if let mostRecentDate = sortedWins.first?.timestamp {
                let dayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: mostRecentDate) }
                let total = dayWins.reduce(0) { $0 + (Double($1.value) ?? 0) }
                return min(CGFloat(total / target), 1.0)
            }
        }
        
        return 0
    }
    
    private func calculateStreak() -> Int {
        guard !wins.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDates = Set(wins.map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDates = Array(uniqueDates).sorted(by: >)
        
        guard let mostRecent = sortedDates.first,
              calendar.isDateInToday(mostRecent) || calendar.isDateInYesterday(mostRecent) else {
            return 0
        }
        
        var streak = 0
        var currentDate = calendar.isDateInToday(mostRecent) ? mostRecent : calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    private func calculateDailyAverage() -> Double {
        guard !wins.isEmpty else { return 0 }
        let calendar = Calendar.current
        let uniqueDays = Set(wins.map { calendar.startOfDay(for: $0.timestamp) }).count
        let totalValue = wins.reduce(0) { $0 + (Double($1.value) ?? 1) }
        return totalValue / Double(max(uniqueDays, 1))
    }
    
    private func getValueForDay(_ dayIndex: Int) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let date = calendar.date(byAdding: .day, value: -(6 - dayIndex), to: today)!
        let dayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
        return dayWins.reduce(0) { $0 + (Double($1.value) ?? 1) }
    }
    
    private func getDayLabel(_ dayIndex: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        let calendar = Calendar.current
        let today = Date()
        let date = calendar.date(byAdding: .day, value: -(6 - dayIndex), to: today)!
        let weekday = calendar.component(.weekday, from: date) - 1
        return days[weekday]
    }
    
    private func getHeatmapValue(for index: Int) -> Double {
        let calendar = Calendar.current
        let today = Date()
        let date = calendar.date(byAdding: .day, value: -(27 - index), to: today)!
        let dayWins = wins.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
        let value = dayWins.reduce(0) { $0 + (Double($1.value) ?? 1) }
        return value / 10.0 // Normalize for heatmap
    }
}

// MARK: - Enhanced Stat Card
struct StatCardEnhanced: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let isHighlighted: Bool
    let theme: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: isHighlighted ? 32 : 28, weight: .bold, design: .rounded))
                .foregroundColor(theme == 0 ? .black : .white)
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
            
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(theme == 0 ? .gray : .gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isHighlighted ?
                    color.opacity(0.15) :
                    (theme == 0 ? Color.gray.opacity(0.1) : Color.white.opacity(0.1))
                )
                .overlay(
                    isHighlighted ?
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(0.3), lineWidth: 1.5) :
                    nil
                )
        )
    }
}