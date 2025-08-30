import SwiftUI

// MARK: - Design Philosophy
// Inspired by Dieter Rams' principles: "Less, but better"
// Apple's human interface: Clarity, Deference, Depth
// Eames' warmth and humanity in functional design
// Starck's elegant minimalism with personality

// MARK: - Color System
extension Color {
    // Primary Palette - Warm and Human
    static let zenPrimary = Color(red: 0.31, green: 0.42, blue: 0.98)      // Confident blue
    static let zenSecondary = Color(red: 0.98, green: 0.58, blue: 0.36)    // Warm coral
    static let zenTertiary = Color(red: 0.40, green: 0.78, blue: 0.64)     // Fresh mint
    
    // Success States - Encouraging and Positive
    static let zenSuccess = Color(red: 0.35, green: 0.84, blue: 0.38)      // Vibrant green
    static let zenWarning = Color(red: 1.0, green: 0.80, blue: 0.0)        // Warm yellow
    static let zenError = Color(red: 0.98, green: 0.42, blue: 0.42)        // Soft red
    
    // Neutral Palette - Sophisticated Grays
    static let zenCharcoal = Color(red: 0.11, green: 0.11, blue: 0.12)     // Rich black
    static let zenSlate = Color(red: 0.26, green: 0.28, blue: 0.31)        // Deep gray
    static let zenStone = Color(red: 0.46, green: 0.48, blue: 0.52)        // Medium gray
    static let zenMist = Color(red: 0.64, green: 0.66, blue: 0.70)         // Light gray
    static let zenCloud = Color(red: 0.93, green: 0.94, blue: 0.95)        // Soft gray
    static let zenPearl = Color(red: 0.98, green: 0.98, blue: 0.98)        // Near white
    
    // Semantic Colors
    static let zenBackground = zenPearl
    static let zenSurface = Color.white
    static let zenTextPrimary = zenCharcoal
    static let zenTextSecondary = zenStone
    static let zenTextTertiary = zenMist
    static let zenDivider = zenCloud.opacity(0.6)
    
    // Time-based Backgrounds (Morning/Evening)
    static let zenMorning = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.98, blue: 0.94),
            Color(red: 1.0, green: 0.96, blue: 0.89)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let zenEvening = LinearGradient(
        colors: [
            Color(red: 0.94, green: 0.94, blue: 0.98),
            Color(red: 0.91, green: 0.91, blue: 0.96)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography System
extension Font {
    // Clean, readable, with personality
    static let zenHero = Font.system(size: 34, weight: .bold, design: .rounded)
    static let zenTitle = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let zenHeadline = Font.system(size: 22, weight: .semibold, design: .default)
    static let zenSubheadline = Font.system(size: 17, weight: .medium, design: .default)
    static let zenBody = Font.system(size: 16, weight: .regular, design: .default)
    static let zenCallout = Font.system(size: 15, weight: .regular, design: .default)
    static let zenCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let zenFootnote = Font.system(size: 12, weight: .regular, design: .default)
    
    // Special Purpose
    static let zenNumber = Font.system(size: 48, weight: .light, design: .rounded)
    static let zenButton = Font.system(size: 16, weight: .medium, design: .rounded)
}

// MARK: - Spacing System (8pt Grid)
extension CGFloat {
    static let zen2: CGFloat = 2
    static let zen4: CGFloat = 4
    static let zen8: CGFloat = 8
    static let zen12: CGFloat = 12
    static let zen16: CGFloat = 16
    static let zen20: CGFloat = 20
    static let zen24: CGFloat = 24
    static let zen32: CGFloat = 32
    static let zen40: CGFloat = 40
    static let zen48: CGFloat = 48
    static let zen64: CGFloat = 64
    static let zen80: CGFloat = 80
}

// MARK: - Corner Radius
extension CGFloat {
    static let zenRadiusSmall: CGFloat = 8
    static let zenRadiusMedium: CGFloat = 12
    static let zenRadiusLarge: CGFloat = 16
    static let zenRadiusXL: CGFloat = 24
    static let zenRadiusCircle: CGFloat = 999
}

// MARK: - Shadows (Subtle Depth)
extension View {
    func zenShadowSmall() -> some View {
        self.shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    func zenShadowMedium() -> some View {
        self.shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    func zenShadowLarge() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }
    
    func zenShadowColored(_ color: Color) -> some View {
        self.shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Animation System
extension Animation {
    static let zenSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let zenBounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let zenSmooth = Animation.easeInOut(duration: 0.3)
    static let zenQuick = Animation.easeOut(duration: 0.2)
    static let zenGentle = Animation.easeInOut(duration: 0.4)
}

// MARK: - Elegant Card Component
struct ZenCard: ViewModifier {
    var isInteractive: Bool = false
    var isSelected: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(Color.zenSurface)
            .clipShape(RoundedRectangle(cornerRadius: .zenRadiusMedium))
            .overlay(
                RoundedRectangle(cornerRadius: .zenRadiusMedium)
                    .stroke(isSelected ? Color.zenPrimary : Color.clear, lineWidth: 2)
            )
            .zenShadowSmall()
            .scaleEffect(isInteractive && isSelected ? 1.02 : 1.0)
            .animation(.zenSpring, value: isSelected)
    }
}

// MARK: - Primary Button Style
struct ZenPrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.zenButton)
            .foregroundColor(.white)
            .padding(.horizontal, .zen24)
            .padding(.vertical, .zen12)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusSmall)
                    .fill(isEnabled ? Color.zenPrimary : Color.zenMist)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.zenQuick, value: configuration.isPressed)
    }
}

// MARK: - Secondary Button Style
struct ZenSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.zenButton)
            .foregroundColor(.zenPrimary)
            .padding(.horizontal, .zen20)
            .padding(.vertical, .zen12)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusSmall)
                    .stroke(Color.zenPrimary, lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.zenQuick, value: configuration.isPressed)
    }
}

// MARK: - Floating Action Button
struct ZenFloatingButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Color.zenPrimary)
                )
                .zenShadowMedium()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Progress Ring
struct ZenProgressRing: View {
    let progress: Double
    let size: CGFloat
    var lineWidth: CGFloat = 4
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.zenCloud, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [Color.zenPrimary, Color.zenSecondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.zenSpring, value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Celebration Haptic
extension View {
    func zenCelebration() -> some View {
        self.onAppear {
            #if canImport(UIKit)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let notification = UINotificationFeedbackGenerator()
                notification.notificationOccurred(.success)
            }
            #endif
        }
    }
}

// MARK: - View Extensions
extension View {
    func zenCard(isInteractive: Bool = false, isSelected: Bool = false) -> some View {
        self.modifier(ZenCard(isInteractive: isInteractive, isSelected: isSelected))
    }
    
    func zenHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onAppear {
            #if canImport(UIKit)
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.impactOccurred()
            #endif
        }
    }
}

// MARK: - Elegant Checkbox
struct ZenCheckbox: View {
    @Binding var isChecked: Bool
    var size: CGFloat = 24
    
    var body: some View {
        Button {
            withAnimation(.zenBounce) {
                isChecked.toggle()
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isChecked ? Color.zenPrimary : Color.zenMist, lineWidth: 2)
                    .frame(width: size, height: size)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.6, weight: .bold))
                        .foregroundColor(.zenPrimary)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isChecked) { oldValue, newValue in
            if newValue {
                #if canImport(UIKit)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                #endif
            }
        }
    }
}