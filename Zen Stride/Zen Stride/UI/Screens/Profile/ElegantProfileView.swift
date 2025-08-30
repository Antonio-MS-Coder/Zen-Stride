import SwiftUI
import CoreData

struct ElegantProfileView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingSettings = false
    @State private var showingAchievements = false
    @State private var showingEditProfile = false
    
    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: .zen24) {
                    // Profile Header
                    profileHeader
                    
                    // Stats Overview
                    statsOverview
                    
                    // Achievements Preview
                    achievementsPreview
                    
                    // Menu Options
                    menuSection
                }
                .padding(.horizontal, .zen20)
                .padding(.vertical, .zen16)
            }
            .background(Color.zenBackground)
            .navigationTitle("Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.zenTextSecondary)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAchievements) {
            AchievementsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
    
    // MARK: - Components
    
    private var profileHeader: some View {
        VStack(spacing: .zen16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.zenPrimary, Color.zenSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(viewModel.userInitials)
                    .font(.zenTitle)
                    .foregroundColor(.white)
            }
            
            // Name and Level
            VStack(spacing: .zen8) {
                Text(viewModel.userName)
                    .font(.zenHeadline)
                    .foregroundColor(.zenTextPrimary)
                
                HStack(spacing: .zen8) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.zenTertiary)
                    
                    Text("Level \(viewModel.userLevel)")
                        .font(.zenCaption)
                        .foregroundColor(.zenTextSecondary)
                    
                    Text("•")
                        .foregroundColor(.zenTextTertiary)
                    
                    Text("\(viewModel.totalPoints) points")
                        .font(.zenCaption)
                        .foregroundColor(.zenTextSecondary)
                }
            }
            
            // Progress to Next Level
            VStack(spacing: .zen8) {
                HStack {
                    Text("Level \(viewModel.userLevel)")
                        .font(.zenFootnote)
                        .foregroundColor(.zenTextTertiary)
                    
                    Spacer()
                    
                    Text("Level \(viewModel.userLevel + 1)")
                        .font(.zenFootnote)
                        .foregroundColor(.zenTextTertiary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.zenCloud)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.zenPrimary, Color.zenSecondary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.progressToNextLevel)
                    }
                }
                .frame(height: 8)
                
                Text("\(viewModel.pointsToNextLevel) points to next level")
                    .font(.zenFootnote)
                    .foregroundColor(.zenTextTertiary)
            }
            
            // Edit Profile Button
            Button {
                showingEditProfile = true
            } label: {
                Text("Edit Profile")
                    .font(.zenCaption)
                    .foregroundColor(.zenPrimary)
                    .padding(.horizontal, .zen16)
                    .padding(.vertical, .zen8)
                    .background(
                        RoundedRectangle(cornerRadius: .zenRadiusSmall)
                            .stroke(Color.zenPrimary, lineWidth: 1)
                    )
            }
        }
        .padding(.zen24)
        .zenCard()
    }
    
    private var statsOverview: some View {
        VStack(spacing: .zen16) {
            Text("Statistics")
                .font(.zenSubheadline)
                .foregroundColor(.zenTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: .zen12) {
                StatCard(
                    icon: "calendar",
                    value: "\(viewModel.totalDays)",
                    label: "Days Active",
                    color: .zenPrimary
                )
                
                StatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.totalCompletions)",
                    label: "Completions",
                    color: .zenSuccess
                )
                
                StatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.longestStreak)",
                    label: "Best Streak",
                    color: .zenSecondary
                )
                
                StatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(viewModel.successRate)%",
                    label: "Success Rate",
                    color: .zenTertiary
                )
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var achievementsPreview: some View {
        VStack(spacing: .zen16) {
            HStack {
                Text("Recent Achievements")
                    .font(.zenSubheadline)
                    .foregroundColor(.zenTextPrimary)
                
                Spacer()
                
                Button {
                    showingAchievements = true
                } label: {
                    Text("View All")
                        .font(.zenCaption)
                        .foregroundColor(.zenPrimary)
                }
            }
            
            if viewModel.recentAchievements.isEmpty {
                Text("Complete habits to unlock achievements")
                    .font(.zenBody)
                    .foregroundColor(.zenTextTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, .zen32)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .zen12) {
                        ForEach(viewModel.recentAchievements) { achievement in
                            AchievementBadge(achievement: achievement)
                        }
                    }
                }
            }
        }
        .padding(.zen20)
        .zenCard()
    }
    
    private var menuSection: some View {
        VStack(spacing: 0) {
            ProfileMenuRow(
                icon: "bell.fill",
                title: "Notifications",
                subtitle: viewModel.notificationsEnabled ? "On" : "Off",
                color: .zenPrimary
            ) {
                // Handle notifications
            }
            
            Divider().padding(.leading, 56)
            
            ProfileMenuRow(
                icon: "moon.fill",
                title: "Focus Mode",
                subtitle: "Set quiet hours",
                color: .zenSecondary
            ) {
                // Handle focus mode
            }
            
            Divider().padding(.leading, 56)
            
            ProfileMenuRow(
                icon: "square.and.arrow.up",
                title: "Export Data",
                subtitle: "Download your progress",
                color: .zenTertiary
            ) {
                viewModel.exportData()
            }
            
            Divider().padding(.leading, 56)
            
            ProfileMenuRow(
                icon: "questionmark.circle.fill",
                title: "Help & Support",
                subtitle: "Get assistance",
                color: .zenStone
            ) {
                // Handle support
            }
        }
        .zenCard()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: .zen12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.zenTitle)
                .foregroundColor(.zenTextPrimary)
            
            Text(label)
                .font(.zenFootnote)
                .foregroundColor(.zenTextTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .zen20)
        .background(color.opacity(0.05))
        .cornerRadius(.zenRadiusMedium)
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: .zen8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.zenPrimary, Color.zenSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.iconName ?? "star.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            Text(achievement.name ?? "")
                .font(.zenFootnote)
                .foregroundColor(.zenTextPrimary)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: .zen16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: .zen4) {
                    Text(title)
                        .font(.zenBody)
                        .foregroundColor(.zenTextPrimary)
                    
                    Text(subtitle)
                        .font(.zenFootnote)
                        .foregroundColor(.zenTextTertiary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.zenTextTertiary)
            }
            .padding(.vertical, .zen16)
            .padding(.horizontal, .zen16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - View Models

class ProfileViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    private let habitService: HabitService
    
    @Published var userName = "Friend"
    @Published var userInitials = "YG"
    @Published var userLevel = 1
    @Published var totalPoints = 0
    @Published var progressToNextLevel: Double = 0
    @Published var pointsToNextLevel = 0
    @Published var totalDays = 0
    @Published var totalCompletions = 0
    @Published var longestStreak = 0
    @Published var successRate = 0
    @Published var recentAchievements: [Achievement] = []
    @Published var notificationsEnabled = true
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        self.habitService = HabitService(context: context)
        loadData()
    }
    
    func loadData() {
        // Load user data
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let user = try? viewContext.fetch(request).first {
            userName = user.name ?? "Friend"
            userInitials = String(userName.prefix(2)).uppercased()
            userLevel = Int(user.currentLevel)
            totalPoints = Int(user.totalPoints)
            
            // Calculate progress to next level
            let pointsForCurrentLevel = (userLevel - 1) * 100
            let pointsForNextLevel = userLevel * 100
            let pointsInCurrentLevel = totalPoints - pointsForCurrentLevel
            progressToNextLevel = Double(pointsInCurrentLevel) / 100.0
            pointsToNextLevel = pointsForNextLevel - totalPoints
            
            // Calculate days active
            if let joinDate = user.joinedDate {
                totalDays = Calendar.current.dateComponents([.day], from: joinDate, to: Date()).day ?? 0
            }
            
            notificationsEnabled = user.notificationsEnabled
        }
        
        // Load statistics
        habitService.fetchHabits()
        habitService.fetchStreaks()
        
        // Total completions
        let progressRequest: NSFetchRequest<Progress> = Progress.fetchRequest()
        progressRequest.predicate = NSPredicate(format: "isComplete == true")
        totalCompletions = (try? viewContext.count(for: progressRequest)) ?? 0
        
        // Longest streak
        longestStreak = habitService.streaks
            .map { Int($0.longestLength) }
            .max() ?? 0
        
        // Success rate
        let totalPossible = habitService.habits.count * totalDays
        successRate = totalPossible > 0 ? Int((Double(totalCompletions) / Double(totalPossible)) * 100) : 0
        
        // Recent achievements
        let achievementRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        achievementRequest.predicate = NSPredicate(format: "isUnlocked == true")
        achievementRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Achievement.unlockedDate, ascending: false)]
        achievementRequest.fetchLimit = 5
        recentAchievements = (try? viewContext.fetch(achievementRequest)) ?? []
    }
    
    func exportData() {
        // Implement data export functionality
        print("Exporting data...")
    }
    
    func updateProfile(name: String) {
        let request: NSFetchRequest<User> = User.fetchRequest()
        if let user = try? viewContext.fetch(request).first {
            user.name = name
            try? viewContext.save()
            loadData()
        }
    }
}

// MARK: - Additional Views

struct SettingsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Settings")
                .navigationTitle("Settings")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
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

struct AchievementsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Text("Achievements")
                .navigationTitle("Achievements")
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
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

struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
            }
            .navigationTitle("Edit Profile")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.updateProfile(name: name)
                        dismiss()
                    }
                }
            }
            .onAppear {
                name = viewModel.userName
            }
        }
    }
}