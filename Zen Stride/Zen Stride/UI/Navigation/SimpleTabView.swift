import SwiftUI

// MARK: - Main Tab View
struct SimpleTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickLog = false
    @State private var showingProfile = false
    @StateObject private var dataStore = ZenStrideDataStore()
    
    var body: some View {
        ZStack {
            // Main content with two tabs
            TabView(selection: $selectedTab) {
                // Log Wins - Main interaction point
                LogWinsView(showingQuickLog: $showingQuickLog)
                    .tag(0)
                    .tabItem {
                        Label("Log", systemImage: "plus.circle.fill")
                    }
                    .environmentObject(dataStore)
                
                // Progress - Visual tracking
                ProgressOverviewView()
                    .tag(1)
                    .tabItem {
                        Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .environmentObject(dataStore)
            }
            .accentColor(.premiumIndigo)
            
            // Profile button in top-right corner
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingProfile = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.premiumGray3)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingQuickLog) {
            QuickLogView { win in
                dataStore.addWin(win)
            }
            .environmentObject(dataStore)
        }
        .sheet(isPresented: $showingProfile) {
            ProfileManagementView()
                .environmentObject(dataStore)
        }
    }
}

// MARK: - Habit Model
struct HabitModel: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var frequency: String?
    var unit: String?
    var isActive: Bool = true
}

// MARK: - MicroWin Model
struct MicroWin: Identifiable, Equatable {
    let id: UUID
    let habitName: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let timestamp: Date
    
    init(id: UUID = UUID(), habitName: String, value: String, unit: String, icon: String, color: Color, timestamp: Date) {
        self.id = id
        self.habitName = habitName
        self.value = value
        self.unit = unit
        self.icon = icon
        self.color = color
        self.timestamp = timestamp
    }
    
    static func == (lhs: MicroWin, rhs: MicroWin) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    SimpleTabView()
}