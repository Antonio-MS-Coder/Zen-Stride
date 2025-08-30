import SwiftUI

struct ElegantOnboardingView: View {
    @State private var currentPage = 0
    @State private var userName = ""
    @State private var selectedCategories: Set<String> = []
    @State private var dailyGoal = 3
    @Binding var hasCompletedOnboarding: Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    let categories = [
        ("Health", "heart.fill", Color.zenError),
        ("Learning", "book.fill", Color.zenPrimary),
        ("Fitness", "figure.run", Color.zenSecondary),
        ("Mindfulness", "brain.head.profile", Color.zenSuccess),
        ("Productivity", "chart.line.uptrend.xyaxis", Color.zenTertiary),
        ("Creativity", "paintbrush.fill", Color.purple)
    ]
    
    var body: some View {
        ZStack {
            Color.zenBackground
                .ignoresSafeArea()
            
            VStack {
                // Progress Indicator
                HStack(spacing: .zen8) {
                    ForEach(0..<4) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= currentPage ? Color.zenPrimary : Color.zenCloud)
                            .frame(height: 4)
                    }
                }
                .padding(.horizontal, .zen32)
                .padding(.top, .zen24)
                
                // Page Content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    namePage.tag(1)
                    categoriesPage.tag(2)
                    goalPage.tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: .zen16) {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation(.zenSmooth) {
                                currentPage -= 1
                            }
                        }
                        .buttonStyle(ZenSecondaryButton())
                    }
                    
                    Spacer()
                    
                    Button(currentPage == 3 ? "Get Started" : "Continue") {
                        if currentPage == 3 {
                            completeOnboarding()
                        } else {
                            withAnimation(.zenSmooth) {
                                currentPage += 1
                            }
                        }
                    }
                    .buttonStyle(ZenPrimaryButton())
                    .disabled(!isCurrentPageValid)
                }
                .padding(.horizontal, .zen32)
                .padding(.bottom, .zen32)
            }
        }
    }
    
    // MARK: - Pages
    
    private var welcomePage: some View {
        VStack(spacing: .zen32) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.zenPrimary)
                .padding(.bottom, .zen24)
            
            VStack(spacing: .zen16) {
                Text("Welcome to ZenStride")
                    .font(.zenHero)
                    .foregroundColor(.zenTextPrimary)
                
                Text("Your everyday success companion")
                    .font(.zenCallout)
                    .foregroundColor(.zenTextSecondary)
            }
            
            VStack(alignment: .leading, spacing: .zen16) {
                ElegantFeatureRow(icon: "checkmark.circle", text: "Build lasting habits")
                ElegantFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Track your progress")
                ElegantFeatureRow(icon: "star.fill", text: "Celebrate small wins")
            }
            .padding(.zen24)
            .zenCard()
            
            Spacer()
        }
        .padding(.horizontal, .zen24)
    }
    
    private var namePage: some View {
        VStack(spacing: .zen32) {
            Spacer()
            
            Image(systemName: "person.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.zenPrimary)
                .padding(.bottom, .zen24)
            
            VStack(spacing: .zen16) {
                Text("What should we call you?")
                    .font(.zenTitle)
                    .foregroundColor(.zenTextPrimary)
                
                Text("Let's personalize your experience")
                    .font(.zenCallout)
                    .foregroundColor(.zenTextSecondary)
            }
            
            TextField("Your name", text: $userName)
                .font(.zenBody)
                .padding(.zen16)
                .background(Color.zenCloud)
                .cornerRadius(.zenRadiusSmall)
                .padding(.horizontal, .zen24)
            
            Spacer()
        }
        .padding(.horizontal, .zen24)
    }
    
    private var categoriesPage: some View {
        VStack(spacing: .zen32) {
            Spacer()
            
            VStack(spacing: .zen16) {
                Text("What matters to you?")
                    .font(.zenTitle)
                    .foregroundColor(.zenTextPrimary)
                
                Text("Select areas you want to focus on")
                    .font(.zenCallout)
                    .foregroundColor(.zenTextSecondary)
            }
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .zen16) {
                ForEach(categories, id: \.0) { category in
                    ElegantCategoryCard(
                        name: category.0,
                        icon: category.1,
                        color: category.2,
                        isSelected: selectedCategories.contains(category.0)
                    ) {
                        toggleCategory(category.0)
                    }
                }
            }
            .padding(.horizontal, .zen24)
            
            Spacer()
        }
    }
    
    private var goalPage: some View {
        VStack(spacing: .zen32) {
            Spacer()
            
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.zenPrimary)
                .padding(.bottom, .zen24)
            
            VStack(spacing: .zen16) {
                Text("Set your daily goal")
                    .font(.zenTitle)
                    .foregroundColor(.zenTextPrimary)
                
                Text("How many habits do you want to complete each day?")
                    .font(.zenCallout)
                    .foregroundColor(.zenTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: .zen24) {
                HStack(spacing: .zen32) {
                    Button {
                        if dailyGoal > 1 {
                            dailyGoal -= 1
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(dailyGoal > 1 ? .zenPrimary : .zenMist)
                    }
                    .disabled(dailyGoal <= 1)
                    
                    VStack(spacing: .zen8) {
                        Text("\(dailyGoal)")
                            .font(.zenNumber)
                            .foregroundColor(.zenTextPrimary)
                        
                        Text("habits per day")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                    }
                    
                    Button {
                        if dailyGoal < 10 {
                            dailyGoal += 1
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(dailyGoal < 10 ? .zenPrimary : .zenMist)
                    }
                    .disabled(dailyGoal >= 10)
                }
                
                Text("Start small and build momentum")
                    .font(.zenCaption)
                    .foregroundColor(.zenTextSecondary)
            }
            .padding(.zen24)
            .zenCard()
            .padding(.horizontal, .zen24)
            
            Spacer()
        }
    }
    
    // MARK: - Helpers
    
    private var isCurrentPageValid: Bool {
        switch currentPage {
        case 1: return !userName.isEmpty
        case 2: return !selectedCategories.isEmpty
        default: return true
        }
    }
    
    private func toggleCategory(_ category: String) {
        withAnimation(.zenQuick) {
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
            } else {
                selectedCategories.insert(category)
            }
        }
    }
    
    private func completeOnboarding() {
        // Save user preferences
        let user = User(context: viewContext)
        user.name = userName
        user.dailyGoal = Int32(dailyGoal)
        user.joinedDate = Date()
        user.currentLevel = 1
        user.totalPoints = 0
        
        // Save context
        do {
            try viewContext.save()
            withAnimation {
                hasCompletedOnboarding = true
            }
        } catch {
            print("Error saving onboarding data: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct ElegantFeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: .zen16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.zenPrimary)
                .frame(width: 30)
            
            Text(text)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
            
            Spacer()
        }
    }
}

struct ElegantCategoryCard: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .zen8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : color)
                
                Text(name)
                    .font(.zenCaption)
                    .foregroundColor(isSelected ? .white : .zenTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.zen16)
            .background(
                RoundedRectangle(cornerRadius: .zenRadiusMedium)
                    .fill(isSelected ? color : Color.zenCloud)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .zenRadiusMedium)
                    .stroke(isSelected ? Color.clear : Color.zenDivider, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.zenSpring, value: isSelected)
    }
}