import SwiftUI
import CoreData

struct MinimalHabitDetailView: View {
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .notion24) {
                    // Header
                    VStack(alignment: .leading, spacing: .notion8) {
                        HStack {
                            Image(systemName: habit.iconName ?? "circle")
                                .font(.system(size: 24))
                                .foregroundColor(.notionAccent)
                            
                            Text(habit.name ?? "")
                                .font(.notionTitle)
                                .foregroundColor(.notionText)
                        }
                        
                        Text("Created \(formattedDate(habit.createdDate ?? Date()))")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextTertiary)
                    }
                    .padding(.horizontal, .notion16)
                    
                    Divider()
                        .foregroundColor(.notionDivider)
                    
                    // Details Section
                    VStack(alignment: .leading, spacing: .notion16) {
                        detailRow(label: "Target", value: "\(Int(habit.targetValue)) \(habit.targetUnit ?? "")")
                        detailRow(label: "Frequency", value: habit.frequency ?? "daily")
                        detailRow(label: "Category", value: habit.category ?? "General")
                        
                        if habit.reminderTime != nil {
                            detailRow(label: "Reminder", value: formattedTime(habit.reminderTime!))
                        }
                    }
                    .padding(.horizontal, .notion16)
                    
                    // Stats Section
                    Divider()
                        .foregroundColor(.notionDivider)
                        .padding(.vertical, .notion8)
                    
                    VStack(alignment: .leading, spacing: .notion16) {
                        Text("Statistics")
                            .font(.notionSubheading)
                            .foregroundColor(.notionText)
                        
                        HStack(spacing: .notion16) {
                            statCard(label: "Current Streak", value: getCurrentStreak())
                            statCard(label: "Total Completed", value: getTotalCompleted())
                        }
                        
                        HStack(spacing: .notion16) {
                            statCard(label: "Success Rate", value: getSuccessRate())
                            statCard(label: "Best Streak", value: getBestStreak())
                        }
                    }
                    .padding(.horizontal, .notion16)
                    
                    // Actions
                    Divider()
                        .foregroundColor(.notionDivider)
                        .padding(.vertical, .notion8)
                    
                    VStack(spacing: .notion12) {
                        Button(action: { showingDeleteAlert = true }) {
                            HStack {
                                Image(systemName: "trash")
                                    .font(.notionBody)
                                Text("Delete Habit")
                                    .font(.notionBody)
                            }
                            .foregroundColor(.notionError)
                            .frame(maxWidth: .infinity)
                            .padding(.notion12)
                            .overlay(
                                RoundedRectangle(cornerRadius: .notionCornerSmall)
                                    .stroke(Color.notionError.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, .notion16)
                    
                    Spacer(minLength: .notion32)
                }
                .padding(.vertical, .notion16)
            }
            .background(Color.notionBackground)
            .navigationTitle("Habit Details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.notionAccent)
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteHabit()
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
    
    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.notionBody)
                .foregroundColor(.notionTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(.notionBody)
                .foregroundColor(.notionText)
        }
    }
    
    private func statCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: .notion4) {
            Text(label)
                .font(.notionCaption)
                .foregroundColor(.notionTextTertiary)
            
            Text(value)
                .font(.notionHeading)
                .foregroundColor(.notionText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.notion12)
        .notionCard()
    }
    
    private func getCurrentStreak() -> String {
        if let streaks = habit.streaks as? Set<Streak>,
           let activeStreak = streaks.first(where: { $0.isActive }) {
            return "\(activeStreak.currentLength) days"
        }
        return "0 days"
    }
    
    private func getTotalCompleted() -> String {
        if let progresses = habit.progresses as? Set<Progress> {
            let completed = progresses.filter { $0.isComplete }.count
            return "\(completed)"
        }
        return "0"
    }
    
    private func getSuccessRate() -> String {
        if let progresses = habit.progresses as? Set<Progress>, !progresses.isEmpty {
            let completed = progresses.filter { $0.isComplete }.count
            let rate = (Double(completed) / Double(progresses.count)) * 100
            return "\(Int(rate))%"
        }
        return "0%"
    }
    
    private func getBestStreak() -> String {
        if let streaks = habit.streaks as? Set<Streak> {
            let best = streaks.map { $0.longestLength }.max() ?? 0
            return "\(best) days"
        }
        return "0 days"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func deleteHabit() {
        viewContext.delete(habit)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting habit: \(error)")
        }
    }
}