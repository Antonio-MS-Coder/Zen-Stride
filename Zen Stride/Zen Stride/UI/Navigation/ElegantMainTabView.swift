import SwiftUI

struct ElegantMainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main Content
            TabView(selection: $selectedTab) {
                // Dashboard
                CompassionateDashboardView(viewModel: ElegantDashboardViewModel(context: viewContext))
                    .tag(0)
                
                // Progress
                ElegantProgressView(context: viewContext)
                    .tag(1)
                
                // Profile
                ElegantProfileView(context: viewContext)
                    .tag(2)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue != previousTab {
                    #if canImport(UIKit)
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    #endif
                    previousTab = newValue
                }
            }
            
            // Custom Tab Bar
            HStack(spacing: 0) {
                TabBarItem(
                    icon: "leaf.fill",
                    title: "Today",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                TabBarItem(
                    icon: "chart.bar.fill",
                    title: "Journey",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                TabBarItem(
                    icon: "heart.fill",
                    title: "You",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
            }
            .padding(.horizontal, .zen20)
            .padding(.top, .zen12)
            .padding(.bottom, .zen24)
            .background(
                Color.zenSurface
                    .ignoresSafeArea()
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .zenPrimary : .zenTextTertiary)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(title)
                    .font(.zenFootnote)
                    .foregroundColor(isSelected ? .zenPrimary : .zenTextTertiary)
            }
            .frame(maxWidth: .infinity)
            .animation(.zenSpring, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Placeholder Views

struct ElegantProgressViewPlaceholder: View {
    @State private var selectedTimeRange = 0
    private let timeRanges = ["Week", "Month", "Year"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: .zen24) {
                    // Time Range Selector
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(0..<timeRanges.count, id: \.self) { index in
                            Text(timeRanges[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Progress Charts Placeholder
                    VStack(alignment: .leading, spacing: .zen16) {
                        Text("Weekly Overview")
                            .font(.zenSubheadline)
                            .foregroundColor(.zenTextPrimary)
                        
                        // Mock chart
                        HStack(alignment: .bottom, spacing: .zen8) {
                            ForEach(0..<7) { day in
                                VStack {
                                    Spacer()
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color.zenPrimary, Color.zenSecondary],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .frame(height: CGFloat.random(in: 40...120))
                                    
                                    Text(["S", "M", "T", "W", "T", "F", "S"][day])
                                        .font(.zenFootnote)
                                        .foregroundColor(.zenTextTertiary)
                                }
                            }
                        }
                        .frame(height: 150)
                        .padding(.horizontal)
                    }
                    .padding()
                    .zenCard()
                    .padding(.horizontal)
                    
                    // Stats
                    VStack(alignment: .leading, spacing: .zen16) {
                        Text("Statistics")
                            .font(.zenSubheadline)
                            .foregroundColor(.zenTextPrimary)
                        
                        VStack(spacing: .zen12) {
                            ElegantStatRow(label: "Total Completions", value: "47")
                            Divider()
                            ElegantStatRow(label: "Best Streak", value: "12 days")
                            Divider()
                            ElegantStatRow(label: "Success Rate", value: "82%")
                        }
                    }
                    .padding()
                    .zenCard()
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.zenBackground)
            .navigationTitle("Progress")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

struct ElegantProfileViewPlaceholder: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: .zen24) {
                    // Profile Header
                    VStack(spacing: .zen16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.zenPrimary, Color.zenSecondary],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Text("YG")
                                .font(.zenTitle)
                                .foregroundColor(.white)
                        }
                        
                        Text("Your Growth")
                            .font(.zenHeadline)
                            .foregroundColor(.zenTextPrimary)
                        
                        HStack(spacing: .zen32) {
                            VStack {
                                Text("12")
                                    .font(.zenTitle)
                                    .foregroundColor(.zenTextPrimary)
                                Text("Level")
                                    .font(.zenCaption)
                                    .foregroundColor(.zenTextSecondary)
                            }
                            
                            VStack {
                                Text("47")
                                    .font(.zenTitle)
                                    .foregroundColor(.zenTextPrimary)
                                Text("Habits")
                                    .font(.zenCaption)
                                    .foregroundColor(.zenTextSecondary)
                            }
                            
                            VStack {
                                Text("82%")
                                    .font(.zenTitle)
                                    .foregroundColor(.zenTextPrimary)
                                Text("Success")
                                    .font(.zenCaption)
                                    .foregroundColor(.zenTextSecondary)
                            }
                        }
                    }
                    .padding()
                    .zenCard()
                    .padding(.horizontal)
                    
                    // Menu Options
                    VStack(spacing: 0) {
                        MenuRow(icon: "bell.fill", title: "Notifications", color: .zenPrimary)
                        Divider().padding(.leading, 56)
                        MenuRow(icon: "chart.bar.fill", title: "Analytics", color: .zenSecondary)
                        Divider().padding(.leading, 56)
                        MenuRow(icon: "trophy.fill", title: "Achievements", color: .zenTertiary)
                        Divider().padding(.leading, 56)
                        MenuRow(icon: "gearshape.fill", title: "Settings", color: .zenStone)
                    }
                    .zenCard()
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color.zenBackground)
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
        }
    }
}

struct ElegantStatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.zenBody)
                .foregroundColor(.zenTextSecondary)
            Spacer()
            Text(value)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
        }
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: .zen16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.zenBody)
                .foregroundColor(.zenTextPrimary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.zenTextTertiary)
        }
        .padding(.vertical, .zen16)
        .padding(.horizontal, .zen16)
        .contentShape(Rectangle())
        .onTapGesture {
            #if canImport(UIKit)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
        }
    }
}