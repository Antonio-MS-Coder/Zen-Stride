import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    @State private var userName = ""
    
    var body: some View {
        ZStack {
            // Dynamic background
            LinearGradient(
                colors: backgroundColors(for: currentPage),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.premiumSlow, value: currentPage)
            
            VStack {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.premiumCallout)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.spacing20)
                }
                
                // Main content
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    PhilosophyPage()
                        .tag(1)
                    
                    HowItWorksPage()
                        .tag(2)
                    
                    PersonalizePage(userName: $userName)
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator and continue button
                VStack(spacing: .spacing24) {
                    // Page dots
                    HStack(spacing: .spacing8) {
                        ForEach(0..<4) { index in
                            Circle()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.premiumSmooth, value: currentPage)
                        }
                    }
                    
                    // Continue button
                    Button {
                        if currentPage < 3 {
                            withAnimation(.premiumSmooth) {
                                currentPage += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage == 3 ? "Get Started" : "Continue")
                            .font(.premiumHeadline)
                            .foregroundColor(currentPage == 3 ? .premiumIndigo : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, .spacing16)
                            .background(
                                RoundedRectangle(cornerRadius: .radiusM)
                                    .fill(currentPage == 3 ? Color.white : Color.white.opacity(0.2))
                            )
                    }
                }
                .padding(.horizontal, .spacing40)
                .padding(.bottom, .spacing40)
            }
        }
    }
    
    private func backgroundColors(for page: Int) -> [Color] {
        switch page {
        case 0: return [Color.premiumIndigo, Color.premiumBlue]
        case 1: return [Color.premiumTeal, Color.premiumMint]
        case 2: return [Color.premiumBlue, Color.premiumIndigo]
        case 3: return [Color.premiumIndigo, Color.premiumTeal]
        default: return [Color.premiumIndigo, Color.premiumBlue]
        }
    }
    
    private func completeOnboarding() {
        hapticFeedback(.medium)
        withAnimation(.premiumSmooth) {
            hasCompletedOnboarding = true
        }
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let impact = UIImpactFeedbackGenerator(style: style)
        impact.impactOccurred()
        #endif
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: .spacing32) {
            Spacer()
            
            // App icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.0 : 0)
            }
            
            VStack(spacing: .spacing16) {
                Text("Welcome to ZenStride")
                    .font(.premiumLargeTitle)
                    .foregroundColor(.white)
                
                Text("Your daily companion for\ncelebrating small wins")
                    .font(.premiumBody)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, .spacing40)
        .onAppear {
            withAnimation(.premiumBounce.delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Philosophy Page
struct PhilosophyPage: View {
    @State private var itemsAppeared = [false, false, false]
    
    var body: some View {
        VStack(spacing: .spacing32) {
            Spacer()
            
            Text("Small Steps,\nBig Impact")
                .font(.premiumLargeTitle)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: .spacing20) {
                PhilosophyItem(
                    icon: "drop.fill",
                    text: "Every drop fills the ocean",
                    isShowing: itemsAppeared[0]
                )
                
                PhilosophyItem(
                    icon: "leaf.fill",
                    text: "Tiny seeds grow mighty trees",
                    isShowing: itemsAppeared[1]
                )
                
                PhilosophyItem(
                    icon: "sparkles",
                    text: "Small wins compound daily",
                    isShowing: itemsAppeared[2]
                )
            }
            .padding(.horizontal, .spacing20)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, .spacing20)
        .onAppear {
            for index in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                    withAnimation(.premiumSpring) {
                        itemsAppeared[index] = true
                    }
                }
            }
        }
    }
}

struct PhilosophyItem: View {
    let icon: String
    let text: String
    let isShowing: Bool
    
    var body: some View {
        HStack(spacing: .spacing16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 32)
            
            Text(text)
                .font(.premiumHeadline)
                .foregroundColor(.white.opacity(0.95))
        }
        .opacity(isShowing ? 1 : 0)
        .offset(x: isShowing ? 0 : -20)
    }
}

// MARK: - How It Works Page
struct HowItWorksPage: View {
    @State private var stepsAppeared = [false, false, false]
    
    var body: some View {
        VStack(spacing: .spacing32) {
            Spacer()
            
            Text("How It Works")
                .font(.premiumLargeTitle)
                .foregroundColor(.white)
            
            VStack(spacing: .spacing24) {
                StepItem(
                    number: "1",
                    title: "Log Your Wins",
                    description: "Track small achievements throughout your day",
                    isShowing: stepsAppeared[0]
                )
                
                StepItem(
                    number: "2",
                    title: "Build Momentum",
                    description: "Watch your progress compound over time",
                    isShowing: stepsAppeared[1]
                )
                
                StepItem(
                    number: "3",
                    title: "Celebrate Growth",
                    description: "See how small steps lead to big changes",
                    isShowing: stepsAppeared[2]
                )
            }
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, .spacing32)
        .onAppear {
            for index in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                    withAnimation(.premiumSpring) {
                        stepsAppeared[index] = true
                    }
                }
            }
        }
    }
}

struct StepItem: View {
    let number: String
    let title: String
    let description: String
    let isShowing: Bool
    
    var body: some View {
        HStack(spacing: .spacing16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Text(number)
                    .font(.premiumTitle3)
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: .spacing4) {
                Text(title)
                    .font(.premiumHeadline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.premiumCaption1)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .opacity(isShowing ? 1 : 0)
        .offset(y: isShowing ? 0 : 20)
    }
}

// MARK: - Personalize Page
struct PersonalizePage: View {
    @Binding var userName: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: .spacing32) {
            Spacer()
            
            Text("Let's Personalize")
                .font(.premiumLargeTitle)
                .foregroundColor(.white)
            
            VStack(spacing: .spacing24) {
                Text("What should we call you?")
                    .font(.premiumHeadline)
                    .foregroundColor(.white.opacity(0.9))
                
                TextField("Your name", text: $userName)
                    .font(.premiumBody)
                    .foregroundColor(.premiumIndigo)
                    .padding(.spacing16)
                    .background(
                        RoundedRectangle(cornerRadius: .radiusM)
                            .fill(Color.white)
                    )
                    .focused($isFocused)
                
                Text("You can always change this later")
                    .font(.premiumCaption1)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, .spacing20)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, .spacing20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isFocused = true
            }
        }
    }
}