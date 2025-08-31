import SwiftUI

struct WinCelebrationView: View {
    let habit: HabitModel
    let isGoalComplete: Bool
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var confettiOpacity: Double = 0
    
    var body: some View {
        if isShowing {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissCelebration()
                    }
                
                VStack(spacing: 24) {
                    // Mascot with appropriate mood
                    MascotView(
                        mood: isGoalComplete ? .celebrating : mascotMoodForHabit,
                        size: 150,
                        showAnimation: false
                    )
                    .scaleEffect(scale)
                    .opacity(opacity)
                    
                    VStack(spacing: 12) {
                        Text(celebrationMessage)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.premiumGray1)
                        
                        Text(motivationalQuote)
                            .font(.system(size: 16))
                            .foregroundColor(.premiumGray3)
                            .multilineTextAlignment(.center)
                    }
                    .opacity(opacity)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 20)
                )
                .scaleEffect(scale)
                
                // Confetti particles for goal completion
                if isGoalComplete {
                    ConfettiView()
                        .opacity(confettiOpacity)
                }
            }
            .onAppear {
                showCelebration()
            }
        }
    }
    
    private var mascotMoodForHabit: MascotMood {
        MascotMood.forHabit(name: habit.name, icon: habit.icon)
    }
    
    private var celebrationMessage: String {
        if isGoalComplete {
            return "Goal Complete! 🎉"
        }
        
        let messages = [
            "Great job!",
            "Keep it up!",
            "You're amazing!",
            "Well done!",
            "Fantastic!",
            "Crushing it!"
        ]
        return messages.randomElement() ?? "Great job!"
    }
    
    private var motivationalQuote: String {
        if isGoalComplete {
            return "You've reached your \(habit.name) goal!"
        }
        
        let quotes = [
            "Every win counts",
            "Progress, not perfection",
            "You're building great habits",
            "Consistency is key",
            "Small steps, big results"
        ]
        return quotes.randomElement() ?? "Keep going!"
    }
    
    private func showCelebration() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1.0
            opacity = 1.0
        }
        
        if isGoalComplete {
            withAnimation(.easeIn(duration: 0.3)) {
                confettiOpacity = 1.0
            }
        }
        
        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dismissCelebration()
        }
    }
    
    private func dismissCelebration() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
            confettiOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles()
            }
        }
    }
    
    private func createParticles(in size: CGSize) {
        particles = (0..<30).map { _ in
            ConfettiParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                color: [.premiumIndigo, .premiumTeal, .purple, .yellow, .orange].randomElement()!,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0
            )
        }
    }
    
    private func animateParticles() {
        for i in particles.indices {
            withAnimation(
                .easeOut(duration: Double.random(in: 1.5...2.5))
                .delay(Double.random(in: 0...0.5))
            ) {
                particles[i].position.y += 800
                particles[i].position.x += CGFloat.random(in: -100...100)
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}