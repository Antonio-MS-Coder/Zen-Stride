import SwiftUI

struct ThemeSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var appTheme = "system"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Theme options
                        VStack(alignment: .leading, spacing: 16) {
                            Text("APPEARANCE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                ThemeOption(
                                    title: "System",
                                    description: "Match device settings",
                                    icon: "iphone",
                                    isSelected: appTheme == "system",
                                    action: { appTheme = "system" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ThemeOption(
                                    title: "Light",
                                    description: "Always light mode",
                                    icon: "sun.max.fill",
                                    isSelected: appTheme == "light",
                                    action: { appTheme = "light" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ThemeOption(
                                    title: "Dark",
                                    description: "Always dark mode",
                                    icon: "moon.fill",
                                    isSelected: appTheme == "dark",
                                    action: { appTheme = "dark" }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Preview
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREVIEW")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            HStack(spacing: 16) {
                                // Light preview
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.white)
                                            .frame(width: 160, height: 200)
                                            .shadow(color: .black.opacity(0.1), radius: 4)
                                        
                                        VStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.premiumIndigo.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            VStack(spacing: 4) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.premiumGray4)
                                                    .frame(width: 80, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.premiumGray5)
                                                    .frame(width: 60, height: 8)
                                            }
                                        }
                                    }
                                    
                                    Text("Light")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.premiumGray2)
                                }
                                
                                // Dark preview
                                VStack(spacing: 8) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.premiumGray1)
                                            .frame(width: 160, height: 200)
                                        
                                        VStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.premiumIndigo)
                                                .frame(width: 60, height: 60)
                                            
                                            VStack(spacing: 4) {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.premiumGray3)
                                                    .frame(width: 80, height: 8)
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color.premiumGray4)
                                                    .frame(width: 60, height: 8)
                                            }
                                        }
                                    }
                                    
                                    Text("Dark")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.premiumGray2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(colorScheme)
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

struct ThemeOption: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.premiumGray1)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.premiumGray3)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.premiumIndigo)
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}