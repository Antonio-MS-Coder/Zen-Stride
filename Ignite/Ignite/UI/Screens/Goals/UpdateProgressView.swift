import SwiftUI

struct UpdateProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goal: Goal
    @Binding var goals: [Goal]
    
    @State private var newValue = ""
    @State private var note = ""
    @State private var showingHistory = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: .spacing32) {
                        // Current status
                        currentStatusSection
                        
                        // Update input
                        updateInputSection
                        
                        // Visual progress
                        visualProgressSection
                        
                        // Recent updates
                        if !goal.updates.isEmpty {
                            recentUpdatesSection
                        }
                    }
                    .padding(.spacing20)
                    .padding(.top, .spacing20)
                }
            }
            .navigationTitle("Update Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveUpdate()
                    }
                    .disabled(newValue.isEmpty)
                }
            }
        }
        .onAppear {
            // Pre-fill with suggested value
            newValue = goal.formattedValue(goal.currentValue)
        }
    }
    
    // MARK: - Current Status
    private var currentStatusSection: some View {
        VStack(spacing: .spacing20) {
            // Goal name and icon
            VStack(spacing: .spacing12) {
                Image(systemName: goal.type.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.premiumIndigo)
                
                Text(goal.name)
                    .font(.premiumTitle2)
                    .foregroundColor(.premiumGray1)
                    .multilineTextAlignment(.center)
            }
            
            // Current progress
            VStack(spacing: .spacing8) {
                Text("Current Progress")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                
                Text(goal.formattedProgress)
                    .font(.premiumTitle1)
                    .foregroundColor(.premiumGray1)
                
                Text("\(goal.progressPercentage)% Complete")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
            }
            
            // Motivational message
            Text(goal.motivationalMessage)
                .font(.premiumCallout)
                .foregroundColor(.premiumIndigo)
                .multilineTextAlignment(.center)
                .padding(.horizontal, .spacing20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .spacing24)
        .background(
            RoundedRectangle(cornerRadius: .radiusXL)
                .fill(Color.white)
        )
        .premiumShadowS()
    }
    
    // MARK: - Update Input
    private var updateInputSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("NEW UPDATE")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Value input
            VStack(alignment: .leading, spacing: .spacing8) {
                Text("Current \(goal.unit)")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                HStack {
                    TextField("\(goal.formattedValue(goal.currentValue))", text: $newValue)
                        .font(.system(size: 32, weight: .semibold, design: .rounded))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                    
                    Text(goal.unit)
                        .font(.premiumHeadline)
                        .foregroundColor(.premiumGray3)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .fill(Color.white)
                )
                
                // Quick adjustment buttons
                if goal.type == .quantitative {
                    HStack(spacing: .spacing8) {
                        QuickAdjustButton(value: -1, currentValue: $newValue, goal: goal)
                        QuickAdjustButton(value: -0.5, currentValue: $newValue, goal: goal)
                        Spacer()
                        QuickAdjustButton(value: 0.5, currentValue: $newValue, goal: goal)
                        QuickAdjustButton(value: 1, currentValue: $newValue, goal: goal)
                    }
                }
            }
            
            // Note input
            VStack(alignment: .leading, spacing: .spacing8) {
                Text("Note (optional)")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                TextField("How's it going?", text: $note, axis: .vertical)
                    .font(.premiumCallout)
                    .lineLimit(3...6)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: .radiusM)
                            .fill(Color.white)
                    )
            }
        }
    }
    
    // MARK: - Visual Progress
    private var visualProgressSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("PROGRESS VISUALIZATION")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            VStack(spacing: .spacing16) {
                // Before/After comparison
                HStack(spacing: .spacing24) {
                    ProgressMetric(
                        label: "Start",
                        value: goal.formattedValue(goal.startValue),
                        unit: goal.unit,
                        color: .premiumGray3
                    )
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.premiumGray5)
                    
                    ProgressMetric(
                        label: "Current",
                        value: newValue.isEmpty ? goal.formattedValue(goal.currentValue) : newValue,
                        unit: goal.unit,
                        color: .premiumIndigo
                    )
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 20))
                        .foregroundColor(.premiumGray5)
                    
                    ProgressMetric(
                        label: "Target",
                        value: goal.formattedValue(goal.targetValue),
                        unit: goal.unit,
                        color: .premiumMint
                    )
                }
                .frame(maxWidth: .infinity)
                
                // Progress bar preview
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.premiumGray6)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [Color.premiumIndigo, Color.premiumTeal],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * calculatedProgress)
                            .animation(.premiumSpring, value: calculatedProgress)
                    }
                }
                .frame(height: 12)
            }
            .padding(.spacing20)
            .background(
                RoundedRectangle(cornerRadius: .radiusL)
                    .fill(Color.white)
            )
            .premiumShadowXS()
        }
    }
    
    // MARK: - Recent Updates
    private var recentUpdatesSection: some View {
        VStack(alignment: .leading, spacing: .spacing12) {
            HStack {
                Text("RECENT UPDATES")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                Button {
                    showingHistory = true
                } label: {
                    Text("See all")
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumIndigo)
                }
            }
            
            VStack(spacing: .spacing8) {
                ForEach(goal.updates.suffix(3).reversed(), id: \.date) { update in
                    UpdateHistoryRow(update: update, unit: goal.unit)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private var calculatedProgress: Double {
        guard let value = Double(newValue) else { return goal.progress }
        
        let startValue = goal.startValue
        let targetValue = goal.targetValue
        
        guard targetValue != startValue else { return 0 }
        
        if startValue > targetValue {
            let totalChange = startValue - targetValue
            let currentChange = startValue - value
            return max(0, min(1, currentChange / totalChange))
        } else {
            let totalChange = targetValue - startValue
            let currentChange = value - startValue
            return max(0, min(1, currentChange / totalChange))
        }
    }
    
    private func saveUpdate() {
        guard let value = Double(newValue) else { return }
        
        let update = GoalUpdate(
            date: Date(),
            value: value,
            note: note.isEmpty ? nil : note
        )
        
        // Create new goal with updated values
        var updatedGoal = goal
        updatedGoal = Goal(
            id: goal.id,
            name: goal.name,
            type: goal.type,
            category: goal.category,
            startValue: goal.startValue,
            targetValue: goal.targetValue,
            currentValue: value,
            unit: goal.unit,
            deadline: goal.deadline,
            updateFrequency: goal.updateFrequency,
            updates: goal.updates + [update],
            createdDate: goal.createdDate,
            isActive: goal.isActive
        )
        
        // Update the binding
        goal = updatedGoal
        
        // Update in the goals array
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = updatedGoal
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views
struct QuickAdjustButton: View {
    let value: Double
    @Binding var currentValue: String
    let goal: Goal
    
    var body: some View {
        Button {
            adjustValue()
        } label: {
            Text(value > 0 ? "+\(formatted(value))" : formatted(value))
                .font(.premiumCaption1)
                .foregroundColor(.premiumIndigo)
                .padding(.horizontal, .spacing12)
                .padding(.vertical, .spacing6)
                .background(
                    Capsule()
                        .fill(Color.premiumIndigo.opacity(0.1))
                )
        }
    }
    
    private func adjustValue() {
        guard let current = Double(currentValue) else {
            currentValue = goal.formattedValue(goal.currentValue + value)
            return
        }
        currentValue = goal.formattedValue(current + value)
    }
    
    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

struct ProgressMetric: View {
    let label: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: .spacing4) {
            Text(label)
                .font(.premiumCaption2)
                .foregroundColor(.premiumGray3)
            
            Text(value)
                .font(.premiumHeadline)
                .foregroundColor(color)
            
            Text(unit)
                .font(.premiumCaption2)
                .foregroundColor(.premiumGray3)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UpdateHistoryRow: View {
    let update: GoalUpdate
    let unit: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: .spacing4) {
                Text("\(formatted(update.value)) \(unit)")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray1)
                
                if let note = update.note {
                    Text(note)
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumGray3)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(relativeDate(update.date))
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
        }
        .padding(.spacing12)
        .background(
            RoundedRectangle(cornerRadius: .radiusS)
                .fill(Color.white)
        )
    }
    
    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}