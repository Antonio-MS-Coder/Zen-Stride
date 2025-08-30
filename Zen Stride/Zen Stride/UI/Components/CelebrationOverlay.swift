import SwiftUI

// MARK: - Particle View Helper
struct ParticleView: View {
    let index: Int
    let scale: CGFloat
    let color: Color
    
    private var offset: CGSize {
        let angle = CGFloat(index) * .pi / 4
        let distance: CGFloat = 60
        return CGSize(
            width: cos(angle) * distance * scale,
            height: sin(angle) * distance * scale
        )
    }
    
    var body: some View {
        Circle()
            .fill(color.opacity(0.3))
            .frame(width: 8, height: 8)
            .scaleEffect(scale)
            .offset(offset)
    }
}

struct CelebrationOverlay: View {
    let win: MicroWin
    @State private var particleScale = 0.0
    @State private var textScale = 0.0
    @State private var checkScale = 0.0
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            backgroundView
            celebrationCard
        }
        .onAppear {
            animateCelebration()
        }
    }
    
    private var backgroundView: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .opacity(opacity)
    }
    
    private var celebrationCard: some View {
        VStack(spacing: .spacing24) {
            checkmarkWithParticles
            winDetails
        }
        .padding(.spacing40)
        .background(
            RoundedRectangle(cornerRadius: .radius2XL)
                .fill(.ultraThinMaterial)
        )
        .scaleEffect(textScale * 0.9 + 0.1)
    }
    
    private var checkmarkWithParticles: some View {
        ZStack {
            // Simplified particle effects
            particleEffects
            
            // Main circle
            Circle()
                .fill(win.color)
                .frame(width: 100, height: 100)
                .scaleEffect(checkScale)
            
            // Icon
            Image(systemName: "checkmark")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(checkScale)
        }
    }
    
    private var particleEffects: some View {
        ForEach(0..<8, id: \.self) { index in
            ParticleView(
                index: index,
                scale: particleScale,
                color: win.color
            )
        }
    }
    
    private var winDetails: some View {
        VStack(spacing: .spacing8) {
            Text("Nice Win!")
                .font(.premiumTitle2)
                .foregroundColor(.premiumGray1)
            
            HStack(spacing: .spacing8) {
                Image(systemName: win.icon)
                    .font(.system(size: 20))
                    .foregroundColor(win.color)
                
                Text("\(win.value) \(win.unit) of \(win.habitName)")
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray2)
            }
        }
        .scaleEffect(textScale)
        .opacity(textScale)
    }
    
    private func animateCelebration() {
        withAnimation(.easeOut(duration: 0.2)) {
            opacity = 1.0
        }
        
        withAnimation(.premiumBounce.delay(0.1)) {
            checkScale = 1.0
        }
        
        withAnimation(.premiumSpring.delay(0.2)) {
            textScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            particleScale = 1.5
        }
        
        // Auto dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 0.0
                textScale = 0.8
            }
        }
    }
}

// MARK: - Streak Celebration
struct StreakCelebrationView: View {
    let streakDays: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: .spacing12) {
            // Flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: 24))
                .foregroundColor(.premiumCoral)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            VStack(alignment: .leading, spacing: .spacing4) {
                Text("\(streakDays) Day Streak!")
                    .font(.premiumHeadline)
                    .foregroundColor(.premiumGray1)
                
                Text("Keep the momentum going")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
            }
            
            Spacer()
        }
        .padding(.spacing16)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.premiumCoral.opacity(0.1),
                            Color.premiumAmber.opacity(0.05)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: .radiusL)
                .stroke(Color.premiumCoral.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Milestone Badge
struct MilestoneBadge: View {
    let milestone: String
    let icon: String
    let color: Color
    @State private var isShowing = false
    
    var body: some View {
        VStack(spacing: .spacing8) {
            ZStack {
                // Glow effect
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)
                    .scaleEffect(isShowing ? 1.5 : 0)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(isShowing ? 1.0 : 0)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .scaleEffect(isShowing ? 1.0 : 0)
            }
            
            Text(milestone)
                .font(.premiumCallout)
                .foregroundColor(.premiumGray1)
                .opacity(isShowing ? 1 : 0)
        }
        .onAppear {
            withAnimation(.premiumBounce.delay(0.2)) {
                isShowing = true
            }
        }
    }
}