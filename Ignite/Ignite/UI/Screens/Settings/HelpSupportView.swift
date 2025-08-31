import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App info
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundColor(.premiumIndigo)
                            
                            Text("Ignite")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.premiumGray1)
                            
                            Text("Version 1.0.0")
                                .font(.system(size: 14))
                                .foregroundColor(.premiumGray3)
                            
                            Text("Build Momentum. Keep the Fire Alive.")
                                .font(.system(size: 16))
                                .foregroundColor(.premiumGray2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 8)
                        
                        // FAQ sections
                        VStack(alignment: .leading, spacing: 16) {
                            Text("FREQUENTLY ASKED QUESTIONS")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                FAQItem(
                                    question: "What are the different tracking types?",
                                    answer: "• Check: Simple yes/no completion\n• Count: Track multiple times with a target\n• Goal: Long-term cumulative progress",
                                    isExpanded: expandedSection == "types",
                                    action: {
                                        withAnimation {
                                            expandedSection = expandedSection == "types" ? nil : "types"
                                        }
                                    }
                                )
                                
                                Divider()
                                
                                FAQItem(
                                    question: "How do I log a win?",
                                    answer: "Tap any habit card on the main screen to quickly log progress. For count habits, tap multiple times or use the input field for custom values.",
                                    isExpanded: expandedSection == "logging",
                                    action: {
                                        withAnimation {
                                            expandedSection = expandedSection == "logging" ? nil : "logging"
                                        }
                                    }
                                )
                                
                                Divider()
                                
                                FAQItem(
                                    question: "Can I customize habit colors?",
                                    answer: "Yes! When creating or editing a habit, you can choose from 8 different colors to personalize your tracking experience.",
                                    isExpanded: expandedSection == "colors",
                                    action: {
                                        withAnimation {
                                            expandedSection = expandedSection == "colors" ? nil : "colors"
                                        }
                                    }
                                )
                                
                                Divider()
                                
                                FAQItem(
                                    question: "How do streaks work?",
                                    answer: "Complete your daily habits consistently to build streaks. Your current streak shows consecutive days of completion.",
                                    isExpanded: expandedSection == "streaks",
                                    action: {
                                        withAnimation {
                                            expandedSection = expandedSection == "streaks" ? nil : "streaks"
                                        }
                                    }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Contact section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("CONTACT")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                ContactRow(
                                    icon: "envelope",
                                    title: "Email Support",
                                    subtitle: "create@antoniomurrieta.com",
                                    action: {
                                        if let url = URL(string: "mailto:create@antoniomurrieta.com") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ContactRow(
                                    icon: "link",
                                    title: "Website",
                                    subtitle: "antoniomurrieta.com/support",
                                    action: {
                                        if let url = URL(string: "https://antoniomurrieta.com/support") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ContactRow(
                                    icon: "star",
                                    title: "Rate on App Store",
                                    subtitle: "Share your feedback",
                                    action: {
                                        // App Store review action
                                    }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Credits
                        VStack(spacing: 8) {
                            Text("Made with ❤️ for habit builders")
                                .font(.system(size: 13))
                                .foregroundColor(.premiumGray3)
                            
                            Text("© 2025 Ignite")
                                .font(.system(size: 12))
                                .foregroundColor(.premiumGray4)
                        }
                        .padding(.top, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FAQItem: View {
    let question: String
    let answer: String
    let isExpanded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(question)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.premiumGray1)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray3)
                }
                .padding(16)
                
                if isExpanded {
                    Text(answer)
                        .font(.system(size: 14))
                        .foregroundColor(.premiumGray2)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContactRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.premiumIndigo)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.premiumGray1)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.premiumGray3)
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundColor(.premiumGray4)
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}