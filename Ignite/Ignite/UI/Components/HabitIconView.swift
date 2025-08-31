import SwiftUI

struct HabitIconView: View {
    let icon: String
    let size: CGFloat
    let color: Color
    var isComplete: Bool = false
    
    // Map mascot codes to their image names
    private let mascotMap: [String: String] = [
        "mascot:neutral": "Ignite_Neutral",
        "mascot:celebrating": "Ignite_Celebrating",
        "mascot:meditating": "Ignite_Meditation",
        "mascot:reading": "Ignite_Leyendo",
        "mascot:running": "Ignite_Running",
        "mascot:sleeping": "Ignite_Sleep",
        "mascot:waving": "Ignite_Waving",
        "mascot:thinking": "Ignite_Thinking",
        "mascot:heart": "Ignite_Heart",
        "mascot:trophy": "Ignite_Trophy"
    ]
    
    var body: some View {
        if icon.hasPrefix("mascot:") {
            // Display mascot image
            if let mascotImage = mascotMap[icon] {
                Image(mascotImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 1.3, height: size * 1.3) // Slightly larger for mascots
                    .opacity(isComplete ? 1.0 : 0.85) // More vibrant even when not complete
            }
        } else {
            // Display SF Symbol with vibrant colors
            Image(systemName: icon)
                .font(.system(size: size))
                .foregroundColor(color) // Always use the vibrant color
        }
    }
}