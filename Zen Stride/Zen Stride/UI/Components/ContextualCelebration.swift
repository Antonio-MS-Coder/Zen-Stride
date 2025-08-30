import SwiftUI

// MARK: - Contextual Celebration System
struct ContextualCelebration {
    static func getCelebration(for habitName: String, value: String, previousValues: [String] = []) -> CelebrationData {
        let hour = Calendar.current.component(.hour, from: Date())
        let dayOfWeek = Calendar.current.component(.weekday, from: Date())
        let isFirstToday = checkIfFirstLogToday()
        let consecutiveDays = getConsecutiveDays(for: habitName)
        let numericValue = Double(value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
        let averageValue = calculateAverageValue(for: habitName, from: previousValues)
        
        // First log of the day - special encouragement
        if isFirstToday {
            return CelebrationData(
                title: "Perfect start!",
                subtitle: "Setting the tone for today",
                icon: "sunrise.fill",
                colors: [.premiumAmber, .premiumCoral],
                hapticStyle: .medium,
                particleCount: 8
            )
        }
        
        // Streak achievements
        if consecutiveDays >= 7 {
            return CelebrationData(
                title: "Week warrior!",
                subtitle: "\(consecutiveDays) days strong",
                icon: "flame.fill",
                colors: [.premiumCoral, .premiumAmber],
                hapticStyle: .heavy,
                particleCount: 12
            )
        } else if consecutiveDays >= 3 {
            return CelebrationData(
                title: "On fire!",
                subtitle: "\(consecutiveDays) day streak",
                icon: "flame",
                colors: [.premiumIndigo, .premiumTeal],
                hapticStyle: .medium,
                particleCount: 10
            )
        }
        
        // Time-based celebrations
        if hour < 9 {
            return CelebrationData(
                title: "Early bird!",
                subtitle: "Morning momentum",
                icon: "sun.max.fill",
                colors: [.premiumAmber, .premiumMint],
                hapticStyle: .light,
                particleCount: 6
            )
        } else if hour > 21 {
            return CelebrationData(
                title: "Night warrior!",
                subtitle: "Dedication after dark",
                icon: "moon.stars.fill",
                colors: [.premiumIndigo, .premiumBlue],
                hapticStyle: .medium,
                particleCount: 8
            )
        }
        
        // Weekend celebrations
        if dayOfWeek == 1 || dayOfWeek == 7 {
            return CelebrationData(
                title: "Weekend win!",
                subtitle: "No days off",
                icon: "star.fill",
                colors: [.premiumTeal, .premiumMint],
                hapticStyle: .medium,
                particleCount: 8
            )
        }
        
        // Personal best
        if numericValue > averageValue * 1.2 && averageValue > 0 {
            return CelebrationData(
                title: "Personal best!",
                subtitle: "You're pushing boundaries",
                icon: "trophy.fill",
                colors: [.premiumAmber, .premiumCoral],
                hapticStyle: .heavy,
                particleCount: 15
            )
        }
        
        // Default celebration with variety
        let defaultCelebrations = [
            CelebrationData(
                title: "Nice win!",
                subtitle: "Every step counts",
                icon: "checkmark.circle.fill",
                colors: [.premiumIndigo, .premiumBlue],
                hapticStyle: .light,
                particleCount: 5
            ),
            CelebrationData(
                title: "Keep going!",
                subtitle: "Building momentum",
                icon: "arrow.up.circle.fill",
                colors: [.premiumTeal, .premiumMint],
                hapticStyle: .light,
                particleCount: 5
            ),
            CelebrationData(
                title: "Well done!",
                subtitle: "Progress in motion",
                icon: "hand.thumbsup.fill",
                colors: [.premiumBlue, .premiumIndigo],
                hapticStyle: .light,
                particleCount: 5
            )
        ]
        
        return defaultCelebrations.randomElement() ?? defaultCelebrations[0]
    }
    
    private static func checkIfFirstLogToday() -> Bool {
        // This would check UserDefaults or Core Data for today's logs
        // Simplified for demo
        return false
    }
    
    private static func getConsecutiveDays(for habitName: String) -> Int {
        // This would check the streak from Core Data
        // Simplified for demo
        return Int.random(in: 0...10)
    }
    
    private static func calculateAverageValue(for habitName: String, from previousValues: [String]) -> Double {
        // Calculate average from previous values
        // Simplified for demo
        return 10.0
    }
}

// MARK: - Celebration Data Model
struct CelebrationData {
    let title: String
    let subtitle: String
    let icon: String
    let colors: [Color]
    let hapticStyle: UIImpactFeedbackGenerator.FeedbackStyle
    let particleCount: Int
}

// MARK: - Enhanced Celebration View
struct EnhancedCelebrationView: View {
    let celebration: CelebrationData
    @State private var show = false
    @State private var particles: [Particle] = []
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .opacity(show ? 1 : 0)
            
            // Celebration card
            VStack(spacing: .spacing20) {
                // Icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: celebration.colors.map { $0.opacity(0.2) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(show ? 1 : 0.5)
                    
                    Image(systemName: celebration.icon)
                        .font(.system(size: 48))
                        .foregroundColor(celebration.colors.first)
                        .scaleEffect(show ? 1 : 0.5)
                        .rotationEffect(.degrees(show ? 0 : -45))
                }
                
                VStack(spacing: .spacing8) {
                    Text(celebration.title)
                        .font(.premiumTitle2)
                        .foregroundColor(.premiumGray1)
                    
                    Text(celebration.subtitle)
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray2)
                }
                .opacity(show ? 1 : 0)
                .offset(y: show ? 0 : 20)
            }
            .padding(.spacing32)
            .background(
                RoundedRectangle(cornerRadius: .radiusXL)
                    .fill(Color.white)
                    .shadow(color: celebration.colors.first?.opacity(0.3) ?? .clear, radius: 20, x: 0, y: 10)
            )
            .scaleEffect(show ? 1 : 0.8)
            .opacity(show ? 1 : 0)
            
            // Particle effects
            ForEach(particles) { particle in
                ParticleView(particle: particle, colors: celebration.colors)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: show)
        .onAppear {
            show = true
            generateParticles()
            triggerHaptic()
            
            // Auto dismiss after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    show = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isPresented = false
                }
            }
        }
    }
    
    private func generateParticles() {
        particles = (0..<celebration.particleCount).map { _ in
            Particle(
                x: CGFloat.random(in: -100...100),
                y: CGFloat.random(in: -100...100),
                scale: CGFloat.random(in: 0.5...1.5),
                delay: Double.random(in: 0...0.5)
            )
        }
    }
    
    private func triggerHaptic() {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: celebration.hapticStyle)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Particle System
struct Particle: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
    let delay: Double
}

struct ParticleView: View {
    let particle: Particle
    let colors: [Color]
    @State private var opacity: Double = 1
    @State private var offsetY: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 8 * particle.scale, height: 8 * particle.scale)
            .opacity(opacity)
            .offset(x: particle.x, y: particle.y + offsetY)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5).delay(particle.delay)) {
                    opacity = 0
                    offsetY = -100
                }
            }
    }
}

// MARK: - Milestone Celebration
struct MilestoneCelebration {
    static func checkForMilestone(progress: Double) -> MilestoneData? {
        switch progress {
        case 0.25:
            return MilestoneData(
                title: "Quarter way!",
                message: "You've started something special",
                icon: "star.leadinghalf.filled",
                color: .premiumIndigo,
                animation: .spring(response: 0.5, dampingFraction: 0.6)
            )
        case 0.5:
            return MilestoneData(
                title: "Halfway hero!",
                message: "The hardest part is behind you",
                icon: "star.fill",
                color: .premiumTeal,
                animation: .spring(response: 0.6, dampingFraction: 0.7)
            )
        case 0.75:
            return MilestoneData(
                title: "Final stretch!",
                message: "You can see the finish line",
                icon: "flag.checkered",
                color: .premiumMint,
                animation: .spring(response: 0.7, dampingFraction: 0.8)
            )
        case 0.9:
            return MilestoneData(
                title: "So close!",
                message: "Just a little more",
                icon: "sparkles",
                color: .premiumCoral,
                animation: .spring(response: 0.8, dampingFraction: 0.9)
            )
        case 1.0:
            return MilestoneData(
                title: "Goal achieved!",
                message: "You did it! Time to celebrate!",
                icon: "trophy.fill",
                color: .premiumAmber,
                animation: .spring(response: 1.0, dampingFraction: 0.5)
            )
        default:
            return nil
        }
    }
}

struct MilestoneData {
    let title: String
    let message: String
    let icon: String
    let color: Color
    let animation: Animation
}