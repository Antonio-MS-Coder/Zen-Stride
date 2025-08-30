import SwiftUI

// MARK: - Notion-Inspired Minimal Color Palette
extension Color {
    // Core Colors
    static let notionBlack = Color(red: 0.09, green: 0.09, blue: 0.11)      // #171719
    static let notionGray900 = Color(red: 0.14, green: 0.14, blue: 0.16)    // #242528
    static let notionGray700 = Color(red: 0.33, green: 0.33, blue: 0.36)    // #55555A
    static let notionGray600 = Color(red: 0.45, green: 0.45, blue: 0.48)    // #737479
    static let notionGray400 = Color(red: 0.68, green: 0.68, blue: 0.71)    // #AEAEB3
    static let notionGray200 = Color(red: 0.91, green: 0.91, blue: 0.92)    // #E8E8EB
    static let notionGray100 = Color(red: 0.96, green: 0.96, blue: 0.97)    // #F5F5F7
    static let notionGray50 = Color(red: 0.98, green: 0.98, blue: 0.99)     // #FAFAFA
    static let notionWhite = Color.white
    
    // Single Accent Color
    static let notionAccent = Color(red: 0.22, green: 0.59, blue: 0.98)     // #3781FA
    static let notionAccentLight = Color(red: 0.22, green: 0.59, blue: 0.98).opacity(0.1)
    
    // Semantic Colors
    static let notionSuccess = Color(red: 0.27, green: 0.73, blue: 0.44)    // #45B85C
    static let notionWarning = Color(red: 0.95, green: 0.77, blue: 0.06)    // #F3C40F
    static let notionError = Color(red: 0.91, green: 0.34, blue: 0.34)      // #E85757
    
    // Backgrounds
    static let notionBackground = notionWhite
    static let notionSurface = notionWhite
    static let notionBorder = notionGray200
    static let notionDivider = notionGray100
    
    // Text Colors
    static let notionText = notionBlack
    static let notionTextSecondary = notionGray600
    static let notionTextTertiary = notionGray400
}

// MARK: - Typography System
extension Font {
    // Notion-style typography - clean, readable, no decoration
    static let notionLargeTitle = Font.system(size: 32, weight: .bold, design: .default)
    static let notionTitle = Font.system(size: 24, weight: .semibold, design: .default)
    static let notionHeading = Font.system(size: 20, weight: .semibold, design: .default)
    static let notionSubheading = Font.system(size: 16, weight: .medium, design: .default)
    static let notionBody = Font.system(size: 15, weight: .regular, design: .default)
    static let notionCallout = Font.system(size: 14, weight: .regular, design: .default)
    static let notionCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let notionFootnote = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Spacing System (8pt Grid)
extension CGFloat {
    static let notion4: CGFloat = 4
    static let notion8: CGFloat = 8
    static let notion12: CGFloat = 12
    static let notion16: CGFloat = 16
    static let notion20: CGFloat = 20
    static let notion24: CGFloat = 24
    static let notion32: CGFloat = 32
    static let notion48: CGFloat = 48
    static let notion64: CGFloat = 64
}

// MARK: - Corner Radius
extension CGFloat {
    static let notionCornerSmall: CGFloat = 4
    static let notionCornerMedium: CGFloat = 6
    static let notionCornerLarge: CGFloat = 8
    static let notionCornerXL: CGFloat = 12
    static let notionCornerFull: CGFloat = 999
}

// MARK: - Animation Durations (Minimal)
extension Animation {
    static let notionQuick = Animation.easeInOut(duration: 0.15)
    static let notionDefault = Animation.easeInOut(duration: 0.2)
    static let notionSlow = Animation.easeInOut(duration: 0.3)
}

// MARK: - Minimal Card Modifier
struct NotionCard: ViewModifier {
    var padding: CGFloat = .notion16
    var showBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.notionBackground)
            .overlay(
                showBorder ? 
                RoundedRectangle(cornerRadius: .notionCornerMedium)
                    .stroke(Color.notionBorder, lineWidth: 1) : nil
            )
    }
}

// MARK: - Minimal Button Style
struct NotionButtonStyle: ButtonStyle {
    var isPrimary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.notionBody)
            .foregroundColor(isPrimary ? .white : .notionText)
            .padding(.horizontal, .notion16)
            .padding(.vertical, .notion8)
            .background(
                RoundedRectangle(cornerRadius: .notionCornerSmall)
                    .fill(isPrimary ? Color.notionAccent : Color.notionGray100)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.notionQuick, value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func notionCard(padding: CGFloat = .notion16, showBorder: Bool = true) -> some View {
        self.modifier(NotionCard(padding: padding, showBorder: showBorder))
    }
    
    func notionDivider() -> some View {
        self.overlay(
            Rectangle()
                .fill(Color.notionDivider)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    func notionSection() -> some View {
        self
            .padding(.vertical, .notion8)
            .padding(.horizontal, .notion16)
    }
}

// MARK: - Minimal Checkbox
struct NotionCheckbox: View {
    let isChecked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .font(.system(size: 20))
                .foregroundColor(isChecked ? .notionAccent : .notionGray400)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Minimal Progress Bar
struct NotionProgressBar: View {
    let progress: Double
    var height: CGFloat = 4
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.notionGray100)
                    .frame(height: height)
                
                Rectangle()
                    .fill(Color.notionAccent)
                    .frame(width: geometry.size.width * min(progress, 1.0), height: height)
                    .animation(.notionDefault, value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Simple Toast Notification
struct NotionToast: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, info
        
        var color: Color {
            switch self {
            case .success: return .notionSuccess
            case .error: return .notionError
            case .info: return .notionAccent
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: .notion8) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.notionBody)
            
            Text(message)
                .font(.notionBody)
                .foregroundColor(.notionText)
            
            Spacer()
        }
        .padding(.notion12)
        .background(Color.notionWhite)
        .overlay(
            RoundedRectangle(cornerRadius: .notionCornerSmall)
                .stroke(Color.notionBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}