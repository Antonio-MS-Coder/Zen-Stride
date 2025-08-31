import SwiftUI
import UniformTypeIdentifiers

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var dataStore: ZenStrideDataStore
    @State private var exportType = "all"
    @State private var dateRange = "all"
    @State private var showingShareSheet = false
    @State private var csvURL: URL?
    @State private var exportStats = (habits: 0, wins: 0)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Export type
                        VStack(alignment: .leading, spacing: 16) {
                            Text("EXPORT TYPE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                ExportOption(
                                    title: "All Data",
                                    description: "Habits and all logged wins",
                                    icon: "square.and.arrow.up",
                                    isSelected: exportType == "all",
                                    action: { exportType = "all" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ExportOption(
                                    title: "Habits Only",
                                    description: "Just your habit configurations",
                                    icon: "list.bullet",
                                    isSelected: exportType == "habits",
                                    action: { exportType = "habits" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                ExportOption(
                                    title: "Wins Only",
                                    description: "All your logged progress",
                                    icon: "checkmark.circle",
                                    isSelected: exportType == "wins",
                                    action: { exportType = "wins" }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Date range
                        VStack(alignment: .leading, spacing: 16) {
                            Text("DATE RANGE")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                DateRangeOption(
                                    title: "All Time",
                                    icon: "infinity",
                                    isSelected: dateRange == "all",
                                    action: { dateRange = "all" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                DateRangeOption(
                                    title: "Last 30 Days",
                                    icon: "calendar",
                                    isSelected: dateRange == "30days",
                                    action: { dateRange = "30days" }
                                )
                                
                                Divider()
                                    .padding(.leading, 56)
                                
                                DateRangeOption(
                                    title: "Last 7 Days",
                                    icon: "calendar.badge.clock",
                                    isSelected: dateRange == "7days",
                                    action: { dateRange = "7days" }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Export preview
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREVIEW")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.premiumGray3)
                                .tracking(1)
                            
                            HStack(spacing: 16) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 32))
                                    .foregroundColor(.premiumIndigo)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("zenStride_export.csv")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.premiumGray1)
                                    
                                    Text("\(exportStats.habits) habits • \(exportStats.wins) wins")
                                        .font(.system(size: 13))
                                        .foregroundColor(.premiumGray3)
                                }
                                
                                Spacer()
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                        }
                        
                        // Export button
                        Button {
                            exportData()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Data")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.premiumIndigo)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                updateExportStats()
            }
            .onChange(of: exportType) { _, _ in
                updateExportStats()
            }
            .onChange(of: dateRange) { _, _ in
                updateExportStats()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = csvURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }
    
    private func updateExportStats() {
        exportStats.habits = dataStore.habits.count
        exportStats.wins = dataStore.wins.count
    }
    
    private func exportData() {
        let fileName = "zenStride_export_\(Date().timeIntervalSince1970).csv"
        let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        var csvString = ""
        
        // Export habits
        if exportType == "all" || exportType == "habits" {
            csvString += "HABITS\n"
            csvString += "Name,Icon,Type,Target,Unit,Color\n"
            for habit in dataStore.habits {
                let target = habit.targetValue.map { String(Int($0)) } ?? ""
                csvString += "\"\(habit.name)\",\"\(habit.icon)\",\"\(habit.trackingType.rawValue)\",\"\(target)\",\"\(habit.unit ?? "")\",\"\(habit.colorHex ?? "")\"\n"
            }
            csvString += "\n"
        }
        
        // Export wins
        if exportType == "all" || exportType == "wins" {
            csvString += "WINS\n"
            csvString += "Date,Habit,Value,Unit\n"
            
            let wins = filterWinsByDateRange()
            for win in wins {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                let dateString = formatter.string(from: win.timestamp)
                csvString += "\"\(dateString)\",\"\(win.habitName)\",\"\(win.value)\",\"\(win.unit)\"\n"
            }
        }
        
        do {
            try csvString.write(to: path, atomically: true, encoding: .utf8)
            csvURL = path
            showingShareSheet = true
        } catch {
            print("Failed to export: \(error)")
        }
    }
    
    private func filterWinsByDateRange() -> [MicroWin] {
        let now = Date()
        let calendar = Calendar.current
        
        switch dateRange {
        case "7days":
            let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
            return dataStore.wins.filter { $0.timestamp >= sevenDaysAgo }
        case "30days":
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: now) ?? now
            return dataStore.wins.filter { $0.timestamp >= thirtyDaysAgo }
        default:
            return dataStore.wins
        }
    }
}

struct ExportOption: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.premiumGray1)
                    
                    Text(description)
                        .font(.system(size: 13))
                        .foregroundColor(.premiumGray3)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.premiumIndigo)
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DateRangeOption: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .premiumIndigo : .premiumGray3)
                    .frame(width: 24, height: 24)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.premiumGray1)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.premiumIndigo)
                }
            }
            .padding(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}