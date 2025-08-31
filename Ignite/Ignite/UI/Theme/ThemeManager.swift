import SwiftUI

// MARK: - Theme Colors
extension Color {
    // Dynamic colors that adapt to light/dark mode
    static let dynamicBackground = Color("DynamicBackground")
    static let dynamicCard = Color("DynamicCard")
    static let dynamicText = Color("DynamicText")
    static let dynamicTextSecondary = Color("DynamicTextSecondary")
    static let dynamicTextTertiary = Color("DynamicTextTertiary")
    static let dynamicDivider = Color("DynamicDivider")
    static let dynamicOverlay = Color("DynamicOverlay")
    
    // Create adaptive versions of our premium colors
    static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("appTheme") var appTheme: String = "system" {
        didSet {
            updateColorScheme()
        }
    }
    
    @Published var currentColorScheme: ColorScheme?
    
    private init() {
        updateColorScheme()
    }
    
    private func updateColorScheme() {
        switch appTheme {
        case "light":
            currentColorScheme = .light
        case "dark":
            currentColorScheme = .dark
        default:
            currentColorScheme = nil
        }
    }
    
    // Background colors
    var backgroundColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0) : // Dark background
                UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)   // Light background (premiumGray6)
        })
    }
    
    var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0) :  // Dark card
                UIColor.white                                               // Light card
        })
    }
    
    var secondaryBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1.0) :  // Dark secondary
                UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)    // Light secondary
        })
    }
    
    // Text colors
    var primaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0) :  // Dark mode text
                UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)    // Light mode text (premiumGray1)
        })
    }
    
    var secondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.7, green: 0.7, blue: 0.72, alpha: 1.0) :   // Dark mode secondary
                UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)      // Light mode secondary (premiumGray3)
        })
    }
    
    var tertiaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.5, green: 0.5, blue: 0.52, alpha: 1.0) :   // Dark mode tertiary
                UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)      // Light mode tertiary (premiumGray4)
        })
    }
    
    // Divider and border colors
    var dividerColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1.0) : // Dark divider
                UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)      // Light divider
        })
    }
    
    // Shadow colors
    var shadowColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor.black.withAlphaComponent(0.3) :
                UIColor.black.withAlphaComponent(0.05)
        })
    }
}

// MARK: - View Extensions for Dark Mode
extension View {
    func dynamicBackground() -> some View {
        self.background(ThemeManager.shared.backgroundColor)
    }
    
    func dynamicCard() -> some View {
        self.background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ThemeManager.shared.cardBackground)
                .shadow(color: ThemeManager.shared.shadowColor, radius: 4, x: 0, y: 2)
        )
    }
    
    func adaptiveColorScheme() -> some View {
        self.preferredColorScheme(ThemeManager.shared.currentColorScheme)
    }
}

// MARK: - Adaptive Color Extensions
extension Color {
    // Create adaptive versions of our premium colors that work in dark mode
    static var adaptivePremiumIndigo: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.45, green: 0.44, blue: 0.94, alpha: 1.0) : // Brighter in dark mode
                UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1.0)   // Original
        })
    }
    
    static var adaptivePremiumTeal: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.1, green: 0.88, blue: 0.85, alpha: 1.0) :  // Brighter in dark mode
                UIColor(red: 0.0, green: 0.78, blue: 0.75, alpha: 1.0)    // Original
        })
    }
    
    static var adaptivePremiumMint: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 0.1, green: 0.88, blue: 0.75, alpha: 1.0) :  // Brighter in dark mode
                UIColor(red: 0.0, green: 0.78, blue: 0.65, alpha: 1.0)    // Original
        })
    }
    
    static var adaptivePremiumCoral: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.52, blue: 0.52, alpha: 1.0) :  // Brighter in dark mode
                UIColor(red: 1.0, green: 0.42, blue: 0.42, alpha: 1.0)    // Original
        })
    }
    
    static var adaptivePremiumAmber: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ?
                UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0) :   // Brighter in dark mode
                UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)      // Original
        })
    }
}