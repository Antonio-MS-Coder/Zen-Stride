import SwiftUI

// MARK: - Main Tab View
struct SimpleTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickLog = false
    @State private var showingProfile = false
    @State private var habits: [Habit] = []
    @State private var wins: [MicroWin] = []
    @StateObject private var dataStore = ZenStrideDataStore()
    
    var body: some View {
        ZStack {
            // Main content with two tabs
            TabView(selection: $selectedTab) {
                // Log Wins - Main interaction point
                LogWinsView(habits: $habits, wins: $wins, showingQuickLog: $showingQuickLog)
                    .tag(0)
                    .tabItem {
                        Label("Log", systemImage: "plus.circle.fill")
                    }
                    .environmentObject(dataStore)
                
                // Progress - Visual tracking
                ProgressOverviewView(habits: $habits, wins: $wins)
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
                wins.append(win)
                dataStore.addWin(win)
            }
        }
        .sheet(isPresented: $showingProfile) {
            ProfileManagementView(habits: $habits)
                .environmentObject(dataStore)
        }
    }
}

// MARK: - Habit Model
struct Habit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var frequency: String?
    var unit: String?
    var isActive: Bool = true
}

// MARK: - MicroWin Model
struct MicroWin: Identifiable {
    let id = UUID()
    let habitName: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    let timestamp: Date
}

#Preview {
    SimpleTabView()
}