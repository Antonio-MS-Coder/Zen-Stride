import SwiftUI

struct ElegantCelebrationView: View {
    @Binding var isShowing: Bool
    let message: String
    let achievement: String?
    
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0
    @State private var rotation: Double = -30
    @State private var particleOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Subtle backdrop
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .opacity(opacity)
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: .zen24) {
                // Icon with animation
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.zenPrimary.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(scale * 1.2)
                        .opacity(opacity * 0.6)
                    
                    // Main icon
                    Image(systemName: achievement ?? "star.fill")
                        .font(.system(size: 64, weight: .medium))
                        .foregroundColor(.zenPrimary)
                        .scaleEffect(scale)
                        .rotationEffect(.degrees(rotation))
                }
                
                // Message
                VStack(spacing: .zen8) {
                    Text("Well done!")
                        .font(.zenTitle)
                        .foregroundColor(.zenTextPrimary)
                    
                    Text(message)
                        .font(.zenBody)
                        .foregroundColor(.zenTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .scaleEffect(scale)
                
                // Continue button
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                        .font(.zenButton)
                        .foregroundColor(.white)
                        .padding(.horizontal, .zen32)
                        .padding(.vertical, .zen12)
                        .background(
                            RoundedRectangle(cornerRadius: .zenRadiusSmall)
                                .fill(Color.zenPrimary)
                        )
                }
                .scaleEffect(scale)
            }
            .padding(.zen32)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusLarge)
                    .fill(Color.zenSurface)
                    .zenShadowLarge()
            )
            .scaleEffect(scale)
            .opacity(opacity)
            
            // Subtle particles
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.zenPrimary.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .offset(x: particleX(for: index), y: particleY(for: index))
                    .opacity(opacity * 0.7)
                    .animation(
                        .easeOut(duration: 1.2)
                        .delay(Double(index) * 0.1),
                        value: particleOffset
                    )
            }
        }
        .onAppear {
            showAnimation()
        }
    }
    
    private func showAnimation() {
        withAnimation(.zenBounce) {
            scale = 1.0
            opacity = 1.0
            rotation = 0
        }
        
        withAnimation(.easeOut(duration: 1.2)) {
            particleOffset = 150
        }
        
        // Haptic feedback
        #if canImport(UIKit)
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
        #endif
    }
    
    private func dismiss() {
        withAnimation(.zenSmooth) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isShowing = false
        }
    }
    
    private func particleX(for index: Int) -> CGFloat {
        let angle = Double(index) * 60
        return CGFloat(cos(angle * .pi / 180)) * particleOffset
    }
    
    private func particleY(for index: Int) -> CGFloat {
        let angle = Double(index) * 60
        return CGFloat(sin(angle * .pi / 180)) * particleOffset
    }
}

// MARK: - Micro Celebration (inline)
struct MicroCelebration: View {
    @State private var scale: CGFloat = 1
    @State private var opacity: Double = 1
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.zenPrimary)
                .frame(width: 50, height: 50)
                .scaleEffect(scale)
                .opacity(opacity)
            
            Image(systemName: "checkmark")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                scale = 2.5
                opacity = 0
            }
        }
    }
}

// MARK: - Success Toast
struct SuccessToast: View {
    let message: String
    @Binding var isShowing: Bool
    @State private var offset: CGFloat = -100
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: .zen12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.zenSuccess)
            
            Text(message)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
            
            Spacer()
        }
        .padding(.zen16)
        .background(
            RoundedRectangle(cornerRadius: .zenRadiusSmall)
                .fill(Color.zenSurface)
                .zenShadowMedium()
        )
        .offset(y: offset)
        .opacity(opacity)
        .onAppear {
            withAnimation(.zenSpring) {
                offset = 0
                opacity = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.zenSmooth) {
                    offset = -100
                    opacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isShowing = false
                }
            }
        }
    }
}