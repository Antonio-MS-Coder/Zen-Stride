import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("userName") private var userName = ""
    @State private var currentPage = 0
    @State private var nameInput = ""
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.premiumTeal.opacity(0.1), Color.premiumIndigo.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack {
                // Page content
                TabView(selection: $currentPage) {
                    welcomePage
                        .tag(0)
                    
                    howItWorksPage
                        .tag(1)
                    
                    nameInputPage
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Navigation
                HStack(spacing: 16) {
                    // Page indicators
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(currentPage == index ? Color.premiumIndigo : Color.premiumGray4)
                                .frame(width: 8, height: 8)
                        }
                    }
                    
                    Spacer()
                    
                    // Next/Done button
                    Button {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage == 2 ? "Start Journey" : "Next")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.premiumIndigo)
                            )
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Welcome Page
    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            MascotView(mood: .neutral, size: 200)
            
            VStack(spacing: 16) {
                Text("Welcome to Ignite")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.premiumGray1)
                
                Text("Build Momentum. Keep the Fire Alive.")
                    .font(.system(size: 18))
                    .foregroundColor(.premiumGray3)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - How It Works Page
    private var howItWorksPage: some View {
        VStack(spacing: 40) {
            Spacer()
            
            MascotView(mood: .celebrating, size: 150)
            
            VStack(spacing: 24) {
                FeatureRow(
                    icon: "checkmark.circle.fill",
                    title: "Track Your Wins",
                    description: "Log daily accomplishments with a single tap"
                )
                
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "See Your Progress",
                    description: "Watch your habits grow over time"
                )
                
                FeatureRow(
                    icon: "sparkles",
                    title: "Stay Motivated",
                    description: "Celebrate every small victory"
                )
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    // MARK: - Name Input Page
    private var nameInputPage: some View {
        VStack(spacing: 32) {
            Spacer()
            
            MascotView(mood: .meditating, size: 150)
            
            VStack(spacing: 24) {
                Text("What should I call you?")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.premiumGray1)
                
                TextField("Your name", text: $nameInput)
                    .font(.system(size: 18))
                    .foregroundColor(.primary)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.secondarySystemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.premiumIndigo.opacity(0.3), lineWidth: 1)
                    )
                
                Text("You can change this anytime in settings")
                    .font(.system(size: 14))
                    .foregroundColor(.premiumGray4)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 32)
    }
    
    private func completeOnboarding() {
        userName = nameInput.isEmpty ? "Friend" : nameInput
        hasSeenWelcome = true
        dismiss()
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.premiumIndigo)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.premiumGray1)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.premiumGray3)
            }
            
            Spacer()
        }
    }
}