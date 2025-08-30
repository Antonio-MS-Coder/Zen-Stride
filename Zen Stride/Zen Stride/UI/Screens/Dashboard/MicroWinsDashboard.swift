import SwiftUI
import Charts

struct MicroWinsDashboard: View {
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @State private var todaysMicroWins: [MicroWin] = []
    @State private var selectedHabit: Habit?
    @State private var showingQuickLog = false
    @State private var showingWisdom = false
    @State private var currentWisdom = ""
    @State private var wisdomWin: MicroWin?
    
    // Animation states
    @State private var progressAnimations: [UUID: Double] = [:]
    @State private var streakFlame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Subtle, calming background
                backgroundGradient
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing28) {
                        // Minimal header with today's focus
                        todaysFocusHeader
                        
                        // Focus mode indicator
                        if dataStore.focusMode {
                            focusModeIndicator
                        }
                        
                        // Momentum indicator
                        momentumWaveIndicator
                        
                        // Today's micro-wins - the star of the show
                        todaysMicroWinsSection
                        
                        // Visual progress story (not numbers)
                        progressStorySection
                        
                        // Compounding impact visualization
                        compoundingImpactSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, .spacing20)
                    .padding(.top, .spacing24)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Top right + button
                topRightAddButton,
                alignment: .topTrailing
            )
            .sheet(isPresented: $showingQuickLog) {
                QuickLogView(onComplete: handleNewWin)
                    .environmentObject(dataStore)
            }
            .overlay(
                // Wisdom moment overlay
                wisdomMomentOverlay
            )
        }
        .onAppear {
            loadTodaysWins()
            animateProgress()
        }
    }
    
    // MARK: - Today's Focus Header
    private var todaysFocusHeader: some View {
        VStack(alignment: .leading, spacing: .spacing8) {
            Text(getCurrentGreeting())
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            HStack(alignment: .lastTextBaseline) {
                Text("Today's")
                    .font(.premiumTitle1)
                    .foregroundColor(.premiumGray1)
                
                Text("Small Wins")
                    .font(.premiumTitle1)
                    .foregroundColor(.premiumIndigo)
            }
            
            // Subtle motivation based on time of day
            Text(getMotivationalMessage())
                .font(.premiumCallout)
                .foregroundColor(.premiumGray3)
                .padding(.top, .spacing4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Today's Micro Wins
    private var todaysMicroWinsSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            if todaysMicroWins.isEmpty {
                // Inviting empty state
                EmptyWinsCard(onTap: { showingQuickLog = true })
                    .transition(.scale.combined(with: .opacity))
            } else {
                // Beautiful grid of today's wins
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: .spacing12) {
                    ForEach(todaysMicroWins) { win in
                        MicroWinCard(win: win)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Story Section
    private var progressStorySection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("YOUR JOURNEY")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Visual story cards instead of charts
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: .spacing12) {
                    WeekProgressCard()
                    StreakCard(days: 7)
                    MomentumCard(trend: .increasing)
                }
            }
        }
    }
    
    // MARK: - Compounding Impact
    private var compoundingImpactSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("COMPOUNDING IMPACT")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            CompoundingVisualization()
        }
    }
    
    // MARK: - Focus Mode Indicator
    private var focusModeIndicator: some View {
        HStack(spacing: .spacing12) {
            Image(systemName: "target")
                .font(.system(size: 16))
                .foregroundColor(.premiumCoral)
            
            Text("Focus Mode: \(dataStore.focusedHabit ?? "Active")")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray2)
            
            Spacer()
            
            Button {
                dataStore.toggleFocusMode()
            } label: {
                Text("Exit")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumCoral)
            }
        }
        .padding(.spacing12)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.premiumCoral.opacity(0.1))
        )
    }
    
    // MARK: - Momentum Wave Indicator
    private var momentumWaveIndicator: some View {
        let momentum = dataStore.getMomentumScore()
        let isOptimalTime = momentum > 3.0
        
        return VStack(spacing: .spacing8) {
            HStack(spacing: .spacing8) {
                Image(systemName: isOptimalTime ? "waveform.path.ecg" : "waveform.path")
                    .font(.system(size: 14))
                    .foregroundColor(isOptimalTime ? .premiumMint : .premiumGray3)
                
                Text(isOptimalTime ? "Perfect timing! Your energy is peaking" : "Building momentum...")
                    .font(.premiumCaption1)
                    .foregroundColor(isOptimalTime ? .premiumMint : .premiumGray3)
            }
            
            // Visual wave
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height: CGFloat = 20
                    let wavelength = width / 4
                    let amplitude = height / 2 * (isOptimalTime ? 1.0 : 0.3)
                    
                    path.move(to: CGPoint(x: 0, y: height / 2))
                    
                    for x in stride(from: 0, through: width, by: 1) {
                        let relativeX = x / wavelength
                        let y = height / 2 + amplitude * sin(relativeX * .pi * 2)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            isOptimalTime ? Color.premiumMint : Color.premiumGray5,
                            isOptimalTime ? Color.premiumTeal : Color.premiumGray6
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 2
                )
            }
            .frame(height: 20)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: momentum)
        }
        .padding(.spacing12)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
    
    // MARK: - Wisdom Moment Overlay
    private var wisdomMomentOverlay: some View {
        Group {
            if showingWisdom {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.premiumSmooth) {
                                showingWisdom = false
                            }
                        }
                    
                    VStack(spacing: .spacing20) {
                        // Success icon
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.premiumAmber)
                            .symbolEffect(.pulse)
                        
                        // Wisdom text
                        Text(currentWisdom)
                            .font(.premiumHeadline)
                            .foregroundColor(.premiumGray1)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, .spacing24)
                        
                        // Continue button
                        Button {
                            withAnimation(.premiumSmooth) {
                                showingWisdom = false
                            }
                        } label: {
                            Text("Nice!")
                                .font(.premiumCallout)
                                .foregroundColor(.white)
                                .padding(.horizontal, .spacing32)
                                .padding(.vertical, .spacing12)
                                .background(
                                    Capsule()
                                        .fill(Color.premiumIndigo)
                                )
                        }
                    }
                    .padding(.spacing32)
                    .background(
                        RoundedRectangle(cornerRadius: .radiusXL)
                            .fill(Color.white)
                    )
                    .premiumShadowL()
                    .padding(.horizontal, .spacing40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
    }
    
    // MARK: - Top Right Add Button
    private var topRightAddButton: some View {
        HStack(spacing: .spacing12) {
            // Focus mode toggle
            Button {
                showFocusModeMenu()
            } label: {
                Image(systemName: dataStore.focusMode ? "target" : "circle.grid.3x3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(dataStore.focusMode ? .premiumCoral : .premiumGray3)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .premiumShadowXS()
            }
            
            // Add button
            Button {
                showingQuickLog = true
                hapticFeedback(.light)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.premiumIndigo)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
                    .premiumShadowS()
            }
        }
        .padding(.top, 60)
        .padding(.trailing, .spacing20)
    }
    
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color.premiumGray6,
                Color.premiumGray6.opacity(0.8)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Helper Methods
    private func getCurrentGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "GOOD MORNING"
        case 12..<17: return "GOOD AFTERNOON"
        case 17..<22: return "GOOD EVENING"
        default: return "GOOD NIGHT"
        }
    }
    
    private func getMotivationalMessage() -> String {
        let count = todaysMicroWins.count
        switch count {
        case 0: return "Ready to start? Every journey begins with a single step."
        case 1...2: return "Great start! Keep the momentum going."
        case 3...5: return "You're on fire! Look at all you've accomplished."
        default: return "Incredible day! You're unstoppable."
        }
    }
    
    private func loadTodaysWins() {
        // Load from Core Data or use dataStore
        todaysMicroWins = dataStore.todaysWins.isEmpty ? MicroWin.sampleWins : dataStore.todaysWins
    }
    
    private func handleNewWin(_ win: MicroWin) {
        withAnimation(.premiumBounce) {
            todaysMicroWins.append(win)
            dataStore.addWin(win)
        }
        
        // Show wisdom moment
        currentWisdom = dataStore.getWisdomMoment(for: win)
        wisdomWin = win
        withAnimation(.premiumSmooth.delay(0.3)) {
            showingWisdom = true
        }
        
        // Subtle haptic feedback
        hapticFeedback(.medium)
    }
    
    private func showFocusModeMenu() {
        // This would show a menu to select which habit to focus on
        // For now, just toggle focus mode
        if dataStore.focusMode {
            dataStore.toggleFocusMode()
        } else {
            // Pick first habit for demo
            dataStore.toggleFocusMode(for: "Reading")
        }
        hapticFeedback(.light)
    }
    
    
    private func animateProgress() {
        withAnimation(.premiumSpring.delay(0.5)) {
            streakFlame = true
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Micro Win Model
struct MicroWin: Identifiable {
    let id = UUID()
    let habitName: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let timestamp: Date
    
    static let sampleWins = [
        MicroWin(habitName: "Reading", value: "15", unit: "pages", icon: "book.fill", color: .premiumIndigo, timestamp: Date()),
        MicroWin(habitName: "Exercise", value: "20", unit: "minutes", icon: "figure.run", color: .premiumTeal, timestamp: Date()),
        MicroWin(habitName: "Water", value: "3", unit: "glasses", icon: "drop.fill", color: .premiumBlue, timestamp: Date()),
        MicroWin(habitName: "Meditation", value: "10", unit: "minutes", icon: "brain.head.profile", color: .premiumMint, timestamp: Date())
    ]
}

// MARK: - Micro Win Card
struct MicroWinCard: View {
    let win: MicroWin
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: .spacing12) {
            // Icon with subtle animation
            ZStack {
                Circle()
                    .fill(win.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: win.icon)
                    .font(.system(size: 22))
                    .foregroundColor(win.color)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            // Achievement text
            VStack(spacing: .spacing4) {
                HStack(spacing: .spacing4) {
                    Text(win.value)
                        .font(.premiumTitle3)
                        .foregroundColor(.premiumGray1)
                    
                    Text(win.unit)
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray3)
                }
                
                Text(win.habitName)
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing20)
        .padding(.horizontal, .spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .overlay(
            // Subtle completion indicator with animation
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.premiumMint)
                .scaleEffect(isAnimating ? 1.0 : 0)
                .offset(x: -8, y: -8),
            alignment: .topTrailing
        )
        .premiumShadowXS()
        .onAppear {
            withAnimation(.premiumBounce.delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Empty Wins Card
struct EmptyWinsCard: View {
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 32))
                    .foregroundColor(.premiumIndigo.opacity(0.6))
                
                Text("Log your first win of the day")
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray2)
                
                Text("Every small step counts")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing32)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundColor(.premiumGray5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Week Progress Card
struct WeekProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            Text("This Week")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
            
            // Mini bar chart
            HStack(alignment: .bottom, spacing: .spacing4) {
                ForEach(0..<7) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            day < 5 ? 
                            Color.premiumIndigo : 
                            Color.premiumGray5
                        )
                        .frame(width: 12, height: CGFloat.random(in: 20...40))
                }
            }
            .frame(height: 40)
            
            Text("5 active days")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
        }
        .padding(.spacing16)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let days: Int
    @State private var flameAnimation = false
    
    var body: some View {
        VStack(spacing: .spacing12) {
            Image(systemName: "flame.fill")
                .font(.system(size: 28))
                .foregroundColor(.premiumCoral)
                .scaleEffect(flameAnimation ? 1.1 : 1.0)
                .animation(
                    .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: flameAnimation
                )
            
            Text("\(days)")
                .font(.premiumTitle1)
                .foregroundColor(.premiumGray1)
            
            Text("day streak")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing16)
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
        .onAppear {
            flameAnimation = true
        }
    }
}

// MARK: - Momentum Card
struct MomentumCard: View {
    enum Trend { case increasing, stable, decreasing }
    let trend: Trend
    
    var body: some View {
        VStack(spacing: .spacing12) {
            Image(systemName: trend == .increasing ? "arrow.up.forward" : "arrow.forward")
                .font(.system(size: 24))
                .foregroundColor(trend == .increasing ? .premiumMint : .premiumGray3)
            
            Text("Momentum")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
            
            Text(trend == .increasing ? "Building" : "Steady")
                .font(.premiumCaption1)
                .foregroundColor(trend == .increasing ? .premiumMint : .premiumGray3)
        }
        .padding(.spacing16)
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

// MARK: - Compounding Visualization
struct CompoundingVisualization: View {
    @State private var animateGrowth = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            // Today vs Year projection
            HStack(spacing: .spacing24) {
                VStack(alignment: .leading, spacing: .spacing8) {
                    Text("Today")
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumGray3)
                    
                    Text("15 pages")
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray1)
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.premiumGray5)
                
                VStack(alignment: .leading, spacing: .spacing8) {
                    Text("This Year")
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumGray3)
                    
                    Text("18 books")
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumIndigo)
                }
            }
            
            // Visual growth representation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.premiumGray6)
                    
                    // Growth bar
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.premiumIndigo, Color.premiumTeal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animateGrowth ? geometry.size.width : 0)
                        .animation(.easeOut(duration: 2), value: animateGrowth)
                }
            }
            .frame(height: 12)
            .onAppear {
                animateGrowth = true
            }
            
            Text("Small daily wins compound into extraordinary results")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray3)
                .italic()
        }
        .padding(.spacing20)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.white)
        )
        .premiumShadowXS()
    }
}

// MARK: - Subtle Success Indicator
struct SuccessCheckmark: View {
    @State private var scale: CGFloat = 0
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 60))
            .foregroundColor(.premiumMint)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.premiumBounce) {
                    scale = 1.0
                }
                
                // Auto-dismiss after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.premiumQuick) {
                        scale = 0
                    }
                }
            }
    }
}