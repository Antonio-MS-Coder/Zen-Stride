import SwiftUI

struct MinimalOnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentStep = 0
    @State private var userName = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: .notion8) {
                ForEach(0..<3) { index in
                    Rectangle()
                        .fill(index <= currentStep ? Color.notionAccent : Color.notionGray200)
                        .frame(height: 2)
                        .animation(.notionDefault, value: currentStep)
                }
            }
            .padding(.horizontal, .notion24)
            .padding(.top, .notion48)
            
            // Content
            Group {
                switch currentStep {
                case 0:
                    welcomeStep
                case 1:
                    nameStep
                case 2:
                    getStartedStep
                default:
                    welcomeStep
                }
            }
            .transition(.opacity)
            .animation(.notionDefault, value: currentStep)
            
            Spacer()
            
            // Navigation
            navigationButtons
                .padding(.horizontal, .notion24)
                .padding(.bottom, .notion48)
        }
        .background(Color.notionBackground)
    }
    
    private var welcomeStep: some View {
        VStack(spacing: .notion32) {
            Spacer()
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.notionAccent)
            
            VStack(spacing: .notion12) {
                Text("Welcome to ZenStride")
                    .font(.notionTitle)
                    .foregroundColor(.notionText)
                
                Text("Build better habits, one day at a time")
                    .font(.notionBody)
                    .foregroundColor(.notionTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, .notion32)
    }
    
    private var nameStep: some View {
        VStack(spacing: .notion32) {
            Spacer()
            
            VStack(spacing: .notion24) {
                Text("What's your name?")
                    .font(.notionTitle)
                    .foregroundColor(.notionText)
                
                TextField("Enter your name", text: $userName)
                    .font(.notionBody)
                    .multilineTextAlignment(.center)
                    .padding(.notion12)
                    .background(Color.notionGray50)
                    .overlay(
                        RoundedRectangle(cornerRadius: .notionCornerSmall)
                            .stroke(Color.notionBorder, lineWidth: 1)
                    )
                    .frame(maxWidth: 300)
            }
            
            Spacer()
        }
        .padding(.horizontal, .notion32)
    }
    
    private var getStartedStep: some View {
        VStack(spacing: .notion32) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundColor(.notionAccent)
            
            VStack(spacing: .notion12) {
                Text("You're all set!")
                    .font(.notionTitle)
                    .foregroundColor(.notionText)
                
                Text("Let's start building your first habit")
                    .font(.notionBody)
                    .foregroundColor(.notionTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, .notion32)
    }
    
    private var navigationButtons: some View {
        HStack {
            if currentStep > 0 {
                Button("Back") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .font(.notionBody)
                .foregroundColor(.notionTextSecondary)
            }
            
            Spacer()
            
            Button(action: nextAction) {
                Text(currentStep == 2 ? "Get Started" : "Continue")
                    .font(.notionBody)
                    .foregroundColor(.white)
                    .padding(.horizontal, .notion24)
                    .padding(.vertical, .notion12)
                    .background(
                        Color.notionAccent
                            .opacity(isStepValid ? 1 : 0.5)
                    )
                    .cornerRadius(.notionCornerSmall)
            }
            .disabled(!isStepValid)
        }
    }
    
    private var isStepValid: Bool {
        switch currentStep {
        case 1:
            return !userName.isEmpty
        default:
            return true
        }
    }
    
    private func nextAction() {
        if currentStep < 2 {
            withAnimation {
                currentStep += 1
            }
        } else {
            completeOnboarding()
        }
    }
    
    private func completeOnboarding() {
        let user = PersistenceController.shared.createOrGetUser()
        user.name = userName.isEmpty ? "User" : userName
        user.hasCompletedOnboarding = true
        
        PersistenceController.shared.save()
        
        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}