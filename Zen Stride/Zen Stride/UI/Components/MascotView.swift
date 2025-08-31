import SwiftUI

enum MascotMood: String, CaseIterable {
    case neutral = "Zen_Stride_Neutral"
    case celebrating = "Zen_Stride_Celebrating"
    case meditating = "Zen_Stride_Meditation"
    case reading = "Zen_Stride_Leyendo"
    case running = "Zen_Stride_Running"
    case sleeping = "Zen_Stride_Sleep"
    case sad = "Zen_Stride_Sad"
    case waving = "Zen_Stride_Waving"
    case thinking = "Zen_Stride_Thinking"
    case heart = "Zen_Stride_Heart"
    case trophy = "Zen_Stride_Trophy"
    
    // Smart mood selection based on context
    static func forHabit(name: String, icon: String) -> MascotMood {
        let lowerName = name.lowercased()
        let lowerIcon = icon.lowercased()
        
        // Check for meditation/mindfulness
        if lowerName.contains("meditat") || lowerName.contains("mindful") || 
           lowerName.contains("breath") || lowerIcon.contains("brain") {
            return .meditating
        }
        
        // Check for reading/learning
        if lowerName.contains("read") || lowerName.contains("book") || 
           lowerName.contains("study") || lowerIcon.contains("book") {
            return .reading
        }
        
        // Check for exercise/running
        if lowerName.contains("run") || lowerName.contains("walk") || 
           lowerName.contains("exercise") || lowerName.contains("workout") ||
           lowerIcon.contains("figure") || lowerIcon.contains("sportscourt") {
            return .running
        }
        
        // Check for sleep
        if lowerName.contains("sleep") || lowerName.contains("bed") || 
           lowerIcon.contains("bed") || lowerIcon.contains("moon") {
            return .sleeping
        }
        
        return .neutral
    }
}

struct MascotView: View {
    let mood: MascotMood
    var size: CGFloat = 120
    var showAnimation: Bool = true
    
    @State private var isAnimating = false
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        Image(mood.rawValue)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .offset(y: showAnimation ? floatOffset : 0)
            .onAppear {
                if showAnimation {
                    startFloatingAnimation()
                }
            }
    }
    
    private func startFloatingAnimation() {
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            floatOffset = -8
        }
    }
}

// MARK: - Mascot with Message
struct MascotWithMessage: View {
    let mood: MascotMood
    let message: String
    var size: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 16) {
            MascotView(mood: mood, size: size)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.premiumGray2)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Celebration Mascot
struct CelebrationMascot: View {
    @State private var scale: CGFloat = 0.1
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0
    
    var body: some View {
        MascotView(mood: .celebrating, size: 150, showAnimation: false)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                withAnimation(.easeOut(duration: 0.5)) {
                    rotation = 360
                }
                
                // Auto dismiss after celebration
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        opacity = 0
                        scale = 0.8
                    }
                }
            }
    }
}