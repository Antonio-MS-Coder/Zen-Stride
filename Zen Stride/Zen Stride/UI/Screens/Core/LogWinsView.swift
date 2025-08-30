import SwiftUI

struct LogWinsView: View {
    @Binding var habits: [Habit]
    @Binding var wins: [MicroWin]
    @Binding var showingQuickLog: Bool
    @State private var todaysWins: [MicroWin] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                // Clean background
                LinearGradient(
                    colors: [Color.premiumGray6, Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Welcome header
                        headerSection
                        
                        // Quick action buttons
                        if !habits.isEmpty {
                            quickActionsSection
                        }
                        
                        // Today's wins
                        if !todaysWins.isEmpty {
                            todaysWinsSection
                        }
                        
                        // Empty state
                        if habits.isEmpty && wins.isEmpty {
                            emptyStateView
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 100)
                }
                
                // Floating log button
                floatingActionButton
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            updateTodaysWins()
        }
        .onChange(of: wins) { _ in
            updateTodaysWins()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(getTimeBasedGreeting())
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.premiumGray1)
            
            Text("What did you accomplish?")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK LOG")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.premiumGray3)
                .tracking(1)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(habits.prefix(4)) { habit in
                    QuickActionCard(habit: habit) {
                        logQuickWin(for: habit)
                    }
                }
            }
        }
    }
    
    // MARK: - Today's Wins
    private var todaysWinsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S WINS")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.premiumGray3)
                    .tracking(1)
                
                Spacer()
                
                Text("\(todaysWins.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.premiumIndigo)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.premiumIndigo.opacity(0.1))
                    )
            }
            
            VStack(spacing: 8) {
                ForEach(todaysWins.reversed()) { win in
                    WinCard(win: win)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(.premiumGray4)
            
            VStack(spacing: 8) {
                Text("Start your journey")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.premiumGray2)
                
                Text("Log your first win to begin")
                    .font(.system(size: 16))
                    .foregroundColor(.premiumGray3)
            }
            
            Button {
                showingQuickLog = true
            } label: {
                Text("Log First Win")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(Color.premiumIndigo)
                    )
            }
        }
        .padding(.top, 60)
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingQuickLog = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.premiumIndigo)
                            .frame(width: 60, height: 60)
                            .shadow(color: .premiumIndigo.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 90)
            }
        }
    }
    
    // MARK: - Helpers
    private func updateTodaysWins() {
        let calendar = Calendar.current
        let today = Date()
        todaysWins = wins.filter { win in
            calendar.isDate(win.timestamp, inSameDayAs: today)
        }
    }
    
    private func getTimeBasedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }
    
    private func logQuickWin(for habit: Habit) {
        let win = MicroWin(
            habitName: habit.name,
            value: "1",
            unit: habit.unit ?? "time",
            icon: habit.icon,
            color: habit.color,
            timestamp: Date()
        )
        wins.append(win)
        
        // Trigger celebration
        withAnimation(.spring()) {
            // Add celebration animation here
        }
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let habit: Habit
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(habit.color.opacity(0.1))
                        .frame(height: 80)
                    
                    Image(systemName: habit.icon)
                        .font(.system(size: 32))
                        .foregroundColor(habit.color)
                }
                
                Text(habit.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.premiumGray1)
                    .lineLimit(1)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Win Card
struct WinCard: View {
    let win: MicroWin
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(win.color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: win.icon)
                    .font(.system(size: 20))
                    .foregroundColor(win.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(win.habitName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.premiumGray1)
                
                HStack(spacing: 4) {
                    Text(win.value)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray2)
                    
                    Text(win.unit)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                    
                    Text("•")
                        .foregroundColor(.premiumGray4)
                    
                    Text(timeAgo(from: win.timestamp))
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                }
            }
            
            Spacer()
            
            // Celebration sparkle
            Image(systemName: "sparkle")
                .font(.system(size: 14))
                .foregroundColor(.premiumAmber)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
    
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Habit Model Extension
extension Habit {
    var color: Color {
        switch icon {
        case "book.fill": return .premiumIndigo
        case "figure.run": return .premiumTeal
        case "drop.fill": return .premiumBlue
        case "brain.head.profile": return .premiumMint
        case "pencil": return .premiumCoral
        case "figure.walk": return .premiumAmber
        default: return .premiumIndigo
        }
    }
}