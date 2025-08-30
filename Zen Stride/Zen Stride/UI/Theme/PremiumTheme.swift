import SwiftUI

// MARK: - Design Philosophy
// Dieter Rams: "Good design is as little design as possible"
// Apple: Clarity through subtle depth and purposeful motion
// Eames: Function with soul and warmth
// Starck: Sophisticated minimalism with character

// MARK: - Premium Color System
extension Color {
    // Primary Brand Colors - Sophisticated and Confident
    static let premiumIndigo = Color(red: 0.345, green: 0.337, blue: 0.839)      // #5856D6 - iOS indigo
    static let premiumBlue = Color(red: 0.0, green: 0.478, blue: 1.0)           // #007AFF - iOS blue
    static let premiumTeal = Color(red: 0.352, green: 0.796, blue: 0.823)       // #5AC8D2 - Refreshing teal
    
    // Accent Colors - Warm and Human
    static let premiumCoral = Color(red: 1.0, green: 0.584, blue: 0.459)        // #FF9575 - Warm coral
    static let premiumMint = Color(red: 0.0, green: 0.780, blue: 0.746)         // #00C7BE - Fresh mint
    static let premiumAmber = Color(red: 1.0, green: 0.624, blue: 0.039)        // #FF9F0A - Golden amber
    
    // Semantic Colors - Clear Communication
    static let premiumSuccess = Color(red: 0.204, green: 0.780, blue: 0.349)    // #34C759 - iOS green
    static let premiumWarning = Color(red: 1.0, green: 0.584, blue: 0.0)        // #FF9500 - iOS orange
    static let premiumError = Color(red: 1.0, green: 0.231, blue: 0.188)        // #FF3B30 - iOS red
    
    // Neutral Palette - Sophisticated Grays
    static let premiumBlack = Color(red: 0.0, green: 0.0, blue: 0.0)
    static let premiumGray1 = Color(red: 0.11, green: 0.11, blue: 0.118)        // #1C1C1E - Near black
    static let premiumGray2 = Color(red: 0.227, green: 0.227, blue: 0.235)      // #3A3A3C - Dark gray
    static let premiumGray3 = Color(red: 0.329, green: 0.329, blue: 0.345)      // #545458 - Medium gray
    static let premiumGray4 = Color(red: 0.557, green: 0.557, blue: 0.576)      // #8E8E93 - System gray
    static let premiumGray5 = Color(red: 0.776, green: 0.776, blue: 0.784)      // #C7C7CC - Light gray
    static let premiumGray6 = Color(red: 0.949, green: 0.949, blue: 0.969)      // #F2F2F7 - Background gray
    static let premiumWhite = Color(red: 1.0, green: 1.0, blue: 1.0)
    
    // Glass Effects
    static let glassBackground = Color.white.opacity(0.72)
    static let glassOverlay = Color.white.opacity(0.3)
    static let glassBorder = Color.white.opacity(0.6)
    
    // Dynamic Backgrounds
    static func dynamicGradient(for timeOfDay: TimeOfDay) -> LinearGradient {
        switch timeOfDay {
        case .morning:
            return LinearGradient(
                colors: [
                    Color(red: 0.996, green: 0.961, blue: 0.902).opacity(0.6),
                    Color(red: 0.988, green: 0.914, blue: 0.820).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .afternoon:
            return LinearGradient(
                colors: [
                    Color(red: 0.949, green: 0.969, blue: 1.0).opacity(0.5),
                    Color(red: 0.878, green: 0.945, blue: 1.0).opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .evening:
            return LinearGradient(
                colors: [
                    Color(red: 0.937, green: 0.867, blue: 0.973).opacity(0.5),
                    Color(red: 0.816, green: 0.847, blue: 0.984).opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .night:
            return LinearGradient(
                colors: [
                    Color(red: 0.741, green: 0.788, blue: 0.914).opacity(0.4),
                    Color(red: 0.604, green: 0.643, blue: 0.867).opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Premium Typography
extension Font {
    // Display Typography
    static let premiumLargeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let premiumTitle1 = Font.system(.title, design: .rounded).weight(.semibold)
    static let premiumTitle2 = Font.system(.title2, design: .rounded).weight(.semibold)
    static let premiumTitle3 = Font.system(.title3, design: .rounded).weight(.medium)
    
    // Body Typography
    static let premiumHeadline = Font.system(.headline, design: .default).weight(.semibold)
    static let premiumSubheadline = Font.system(.subheadline, design: .default).weight(.medium)
    static let premiumBody = Font.system(.body, design: .default)
    static let premiumCallout = Font.system(.callout, design: .default)
    static let premiumFootnote = Font.system(.footnote, design: .default)
    static let premiumCaption1 = Font.system(.caption, design: .default)
    static let premiumCaption2 = Font.system(.caption2, design: .default)
    
    // Special Purpose
    static let premiumMonospaced = Font.system(.body, design: .monospaced)
    static let premiumNumber = Font.system(size: 48, weight: .light, design: .rounded)
    static let premiumQuote = Font.system(.title3, design: .serif).italic()
}

// MARK: - Refined Spacing System (4pt Grid)
extension CGFloat {
    static let spacing2: CGFloat = 2
    static let spacing4: CGFloat = 4
    static let spacing6: CGFloat = 6
    static let spacing8: CGFloat = 8
    static let spacing10: CGFloat = 10
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    static let spacing28: CGFloat = 28
    static let spacing32: CGFloat = 32
    static let spacing40: CGFloat = 40
    static let spacing48: CGFloat = 48
    static let spacing56: CGFloat = 56
    static let spacing64: CGFloat = 64
    static let spacing72: CGFloat = 72
    static let spacing80: CGFloat = 80
}

// MARK: - Corner Radius System
extension CGFloat {
    static let radiusXS: CGFloat = 4
    static let radiusS: CGFloat = 8
    static let radiusM: CGFloat = 12
    static let radiusL: CGFloat = 16
    static let radiusXL: CGFloat = 20
    static let radius2XL: CGFloat = 28
    static let radiusFull: CGFloat = 999
}

// MARK: - Premium Shadows
extension View {
    func premiumShadowXS() -> some View {
        self.shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    }
    
    func premiumShadowS() -> some View {
        self.shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
    
    func premiumShadowM() -> some View {
        self.shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
    
    func premiumShadowL() -> some View {
        self.shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 8)
    }
    
    func premiumShadowXL() -> some View {
        self.shadow(color: Color.black.opacity(0.12), radius: 28, x: 0, y: 12)
    }
    
    func premiumGlow(_ color: Color, intensity: Double = 0.3) -> some View {
        self
            .shadow(color: color.opacity(intensity * 0.6), radius: 8, x: 0, y: 0)
            .shadow(color: color.opacity(intensity * 0.3), radius: 16, x: 0, y: 0)
    }
}

// MARK: - Animation Curves
extension Animation {
    static let premiumSpring = Animation.spring(response: 0.38, dampingFraction: 0.82, blendDuration: 0)
    static let premiumBounce = Animation.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0)
    static let premiumSmooth = Animation.easeInOut(duration: 0.35)
    static let premiumQuick = Animation.easeOut(duration: 0.25)
    static let premiumSlow = Animation.easeInOut(duration: 0.6)
    
    static func premiumSpring(delay: Double) -> Animation {
        Animation.spring(response: 0.38, dampingFraction: 0.82, blendDuration: 0).delay(delay)
    }
}

// MARK: - Glass Card Component
struct PremiumGlassCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    var isInteractive: Bool = false
    var isPressed: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: .radiusL)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: .radiusL)
                        .fill(Color.glassBackground)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusL)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
            .premiumShadowM()
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.premiumQuick, value: isPressed)
    }
}

// MARK: - Premium Button Styles
struct PremiumPrimaryButton: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.premiumHeadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing16)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [Color.premiumIndigo, Color.premiumBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.premiumGray4
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: .radiusM))
            .premiumShadowM()
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.premiumQuick, value: configuration.isPressed)
    }
}

struct PremiumSecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.premiumHeadline)
            .foregroundColor(.premiumIndigo)
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing16)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusM)
                            .stroke(Color.premiumIndigo.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.premiumQuick, value: configuration.isPressed)
    }
}

struct PremiumTertiaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.premiumCallout)
            .foregroundColor(.premiumIndigo)
            .padding(.horizontal, .spacing16)
            .padding(.vertical, .spacing8)
            .background(
                configuration.isPressed ? Color.premiumGray6 : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: .radiusS))
            .animation(.premiumQuick, value: configuration.isPressed)
    }
}

// MARK: - Premium Progress Ring
struct PremiumProgressRing: View {
    let progress: Double
    let size: CGFloat
    var lineWidth: CGFloat = 4
    var showPercentage: Bool = false
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.premiumGray6, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(
                    LinearGradient(
                        colors: [Color.premiumIndigo, Color.premiumTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.premiumSpring, value: animatedProgress)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray2)
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { _, newValue in
            animatedProgress = newValue
        }
    }
}

// MARK: - Premium Toggle
struct PremiumToggle: View {
    @Binding var isOn: Bool
    var color: Color = .premiumIndigo
    
    var body: some View {
        Button {
            withAnimation(.premiumSpring) {
                isOn.toggle()
            }
        } label: {
            ZStack {
                Capsule()
                    .fill(isOn ? color : Color.premiumGray5)
                    .frame(width: 51, height: 31)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 27, height: 27)
                    .offset(x: isOn ? 10 : -10)
                    .premiumShadowS()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Checkbox
struct PremiumCheckbox: View {
    @Binding var isChecked: Bool
    var size: CGFloat = 28
    var color: Color = .premiumIndigo
    
    var body: some View {
        Button {
            withAnimation(.premiumBounce) {
                isChecked.toggle()
                
                #if canImport(UIKit)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                #endif
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isChecked ? color : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isChecked ? color : Color.premiumGray4, lineWidth: 2)
                    )
                    .frame(width: size, height: size)
                
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.55, weight: .bold))
                        .foregroundColor(.white)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Premium Floating Action Button
struct PremiumFloatingActionButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.premiumIndigo, Color.premiumBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(isPressed ? 90 : 0))
            }
            .frame(width: 60, height: 60)
            .premiumShadowL()
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .animation(.premiumBounce, value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

// MARK: - View Extensions
extension View {
    func premiumGlassCard(isInteractive: Bool = false, isPressed: Bool = false) -> some View {
        self.modifier(PremiumGlassCard(isInteractive: isInteractive, isPressed: isPressed))
    }
    
    func premiumHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onAppear {
            #if canImport(UIKit)
            let impact = UIImpactFeedbackGenerator(style: style)
            impact.prepare()
            impact.impactOccurred()
            #endif
        }
    }
    
    func premiumParallax(magnitude: CGFloat = 10) -> some View {
        self.modifier(ParallaxEffect(magnitude: magnitude))
    }
}

// MARK: - Parallax Effect
struct ParallaxEffect: ViewModifier {
    let magnitude: CGFloat
    @State private var offset = CGSize.zero
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset.width, y: offset.height)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    offset = CGSize(width: magnitude, height: magnitude)
                }
            }
    }
}

// MARK: - Time of Day Enum
enum TimeOfDay {
    case morning
    case afternoon
    case evening
    case night
    
    init() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            self = .morning
        case 12..<17:
            self = .afternoon
        case 17..<21:
            self = .evening
        default:
            self = .night
        }
    }
}

// MARK: - Premium Segment Control
struct PremiumSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<options.count, id: \.self) { index in
                Button {
                    withAnimation(.premiumSpring) {
                        selection = index
                    }
                } label: {
                    Text(options[index])
                        .font(.premiumCallout)
                        .foregroundColor(selection == index ? .white : .premiumGray3)
                        .padding(.vertical, .spacing8)
                        .frame(maxWidth: .infinity)
                        .background(
                            selection == index ?
                            AnyView(
                                RoundedRectangle(cornerRadius: .radiusS)
                                    .fill(Color.premiumIndigo)
                                    .matchedGeometryEffect(id: "selection", in: animation)
                            ) : AnyView(Color.clear)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: .radiusM)
                .fill(Color.premiumGray6)
        )
    }
}