import SwiftUI

struct HabitIconView: View {
    let icon: String
    let size: CGFloat
    let color: Color
    var isComplete: Bool = false
    
    // Map mascot codes to their image names
    private let mascotMap: [String: String] = [
        "mascot:neutral": "Zen_Stride_Neutral",
        "mascot:celebrating": "Zen_Stride_Celebrating",
        "mascot:meditating": "Zen_Stride_Meditation",
        "mascot:reading": "Zen_Stride_Leyendo",
        "mascot:running": "Zen_Stride_Running",
        "mascot:sleeping": "Zen_Stride_Sleep",
        "mascot:waving": "Zen_Stride_Waving",
        "mascot:thinking": "Zen_Stride_Thinking",
        "mascot:heart": "Zen_Stride_Heart",
        "mascot:trophy": "Zen_Stride_Trophy"
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