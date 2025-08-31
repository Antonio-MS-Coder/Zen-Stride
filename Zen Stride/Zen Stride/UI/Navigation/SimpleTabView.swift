import SwiftUI

// MARK: - Main Tab View
struct SimpleTabView: View {
    @State private var selectedTab = 0
    @State private var showingQuickLog = false
    @State private var showingProfile = false
    @State private var showingWelcome = false
    @StateObject private var dataStore = ZenStrideDataStore()
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    
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
            
            // Profile button in top-right corner with mascot
            VStack {
                HStack {
                    Spacer()
                    Button {
                        showingProfile = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 44, height: 44)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            
                            Image("Zen_Stride_Neutral")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
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
        .sheet(isPresented: $showingWelcome) {
            WelcomeView()
        }
        .onAppear {
            if !hasSeenWelcome {
                showingWelcome = true
            }
        }
    }
}

// MARK: - Habit Model
enum TrackingType: String, Codable {
    case check = "check"     // Binary: done or not done
    case count = "count"     // Multiple times: 3/8 glasses
    case goal = "goal"       // Long-term cumulative: 3.5kg of 10kg
}

enum TargetPeriod: String, Codable {
    case daily = "daily"
    case weekly = "weekly"
    case total = "total"     // For long-term goals
}

struct HabitModel: Identifiable {
    let id: UUID
    let name: String
    var icon: String
    var frequency: String?
    var unit: String?
    var isActive: Bool
    var trackingType: TrackingType
    var targetValue: Double?     // Target for count/goal types
    var targetPeriod: TargetPeriod
    var colorHex: String?        // Store custom color as hex
    
    init(id: UUID = UUID(), 
         name: String, 
         icon: String, 
         frequency: String? = nil, 
         unit: String? = nil, 
         isActive: Bool = true,
         trackingType: TrackingType = .check,
         targetValue: Double? = nil,
         targetPeriod: TargetPeriod = .daily,
         colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.frequency = frequency
        self.unit = unit
        self.isActive = isActive
        self.trackingType = trackingType
        self.targetValue = targetValue
        self.targetPeriod = targetPeriod
        self.colorHex = colorHex
    }
    
    // MARK: - Smart Increment Logic
    /// Returns a reasonable increment value for quick logging based on unit type
    var quickIncrementValue: Double {
        guard trackingType == .count else { return 1 }
        
        switch unit?.lowercased() {
        case "minutes", "min":
            // For exercise/meditation: 5-15 min increments make sense
            return targetValue != nil && targetValue! <= 15 ? 5 : 15
        case "hours", "hr":
            return 0.5
        case "pages":
            // For reading: 5-10 page increments
            return targetValue != nil && targetValue! <= 10 ? 5 : 10
        case "glasses", "cups":
            // For water: 1-2 glass increments
            return 2
        case "steps":
            // For steps: reasonable chunk of daily target
            return targetValue != nil ? max(1000, targetValue! * 0.25) : 2500
        case "words":
            // For writing: 100-250 word increments
            return targetValue != nil && targetValue! <= 200 ? 100 : 250
        case "kilometers", "km", "miles":
            // For distance: 0.5-1 km increments
            return 0.5
        default:
            // Generic: use 25% of target or reasonable default
            if let target = targetValue, target > 4 {
                return max(1, target * 0.25)
            }
            return 1
        }
    }
    
    /// Returns quick action options for this habit
    var quickActionOptions: [Double] {
        guard trackingType == .count else { return [1] }
        
        let baseOptions: [Double]
        
        switch unit?.lowercased() {
        case "minutes", "min":
            baseOptions = [5, 10, 15, 30]
        case "hours", "hr":
            baseOptions = [0.5, 1, 1.5, 2]
        case "pages":
            baseOptions = [5, 10, 15, 20]
        case "glasses", "cups":
            baseOptions = [1, 2, 3, 4]
        case "steps":
            baseOptions = [1000, 2500, 5000, 7500]
        case "words":
            baseOptions = [100, 250, 500, 1000]
        default:
            if let target = targetValue, target > 1 {
                let quarter = target * 0.25
                let half = target * 0.5
                let threeQuarter = target * 0.75
                baseOptions = [quarter, half, threeQuarter, target]
            } else {
                baseOptions = [1, 2, 3, 5]
            }
        }
        
        return baseOptions.map { $0.truncatingRemainder(dividingBy: 1) == 0 ? $0 : $0 }
    }
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