import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var goals: [Goal]
    
    @State private var goalName = ""
    @State private var goalType: GoalType = .quantitative
    @State private var category = "Health"
    @State private var startValue = ""
    @State private var targetValue = ""
    @State private var currentValue = ""
    @State private var unit = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var updateFrequency: UpdateFrequency = .weekly
    
    let categories = ["Health", "Fitness", "Learning", "Finance", "Career", "Personal", "Creative"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: .spacing24) {
                        // Goal type selector
                        goalTypeSection
                        
                        // Basic info
                        basicInfoSection
                        
                        // Values section
                        valuesSection
                        
                        // Timeline section
                        timelineSection
                    }
                    .padding(.spacing20)
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createGoal()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var goalTypeSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("GOAL TYPE")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            HStack(spacing: .spacing12) {
                ForEach(GoalType.allCases, id: \.self) { type in
                    GoalTypeCard(
                        type: type,
                        isSelected: goalType == type,
                        onTap: { goalType = type }
                    )
                }
            }
        }
    }
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("DETAILS")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            // Goal name
            VStack(alignment: .leading, spacing: .spacing8) {
                Text("What's your goal?")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                TextField("e.g., Read 12 books this year", text: $goalName)
                    .font(.premiumBody)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: .radiusM)
                            .fill(Color.white)
                    )
            }
            
            // Category
            VStack(alignment: .leading, spacing: .spacing8) {
                Text("Category")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: .spacing8) {
                        ForEach(categories, id: \.self) { cat in
                            GoalCategoryChip(
                                title: cat,
                                isSelected: category == cat,
                                onTap: { category = cat }
                            )
                        }
                    }
                }
            }
        }
    }
    
    private var valuesSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("PROGRESS TRACKING")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            HStack(spacing: .spacing16) {
                // Current value
                VStack(alignment: .leading, spacing: .spacing8) {
                    Text("Current")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray2)
                    
                    TextField("0", text: $currentValue)
                        .font(.premiumBody)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .fill(Color.white)
                        )
                }
                
                // Target value
                VStack(alignment: .leading, spacing: .spacing8) {
                    Text("Target")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray2)
                    
                    TextField("12", text: $targetValue)
                        .font(.premiumBody)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .fill(Color.white)
                        )
                }
                
                // Unit
                VStack(alignment: .leading, spacing: .spacing8) {
                    Text("Unit")
                        .font(.premiumCallout)
                        .foregroundColor(.premiumGray2)
                    
                    TextField("books", text: $unit)
                        .font(.premiumBody)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .fill(Color.white)
                        )
                }
            }
            
            // Update frequency
            VStack(alignment: .leading, spacing: .spacing8) {
                Text("How often will you update progress?")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                PremiumSegmentedControl(
                    selection: Binding(
                        get: { UpdateFrequency.allCases.firstIndex(of: updateFrequency) ?? 0 },
                        set: { updateFrequency = UpdateFrequency.allCases[$0] }
                    ),
                    options: UpdateFrequency.allCases.map { $0.rawValue }
                )
            }
        }
    }
    
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Text("TIMELINE")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            HStack {
                Text("Set a deadline")
                    .font(.premiumCallout)
                    .foregroundColor(.premiumGray2)
                
                Spacer()
                
                PremiumToggle(isOn: $hasDeadline, title: "Set Deadline")
            }
            
            if hasDeadline {
                DatePicker(
                    "Deadline",
                    selection: $deadline,
                    in: Date()...,
                    displayedComponents: .date
                )
                .font(.premiumCallout)
                .tint(.premiumIndigo)
            }
        }
    }
    
    // MARK: - Helpers
    
    private var isValid: Bool {
        !goalName.isEmpty &&
        !currentValue.isEmpty &&
        !targetValue.isEmpty &&
        !unit.isEmpty
    }
    
    private func createGoal() {
        guard isValid,
              let current = Double(currentValue),
              let target = Double(targetValue) else { return }
        
        let newGoal = Goal(
            id: UUID(),
            name: goalName,
            type: goalType,
            category: category,
            startValue: current,
            targetValue: target,
            currentValue: current,
            unit: unit,
            deadline: hasDeadline ? deadline : nil,
            updateFrequency: updateFrequency,
            updates: [],
            createdDate: Date(),
            isActive: true
        )
        
        goals.append(newGoal)
        dismiss()
    }
}

// MARK: - Supporting Views
struct GoalTypeCard: View {
    let type: GoalType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .premiumIndigo)
                
                Text(type.rawValue)
                    .font(.premiumCaption1)
                    .foregroundColor(isSelected ? .white : .premiumGray2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing16)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(isSelected ? Color.premiumIndigo : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: .radiusM)
                    .stroke(isSelected ? Color.clear : Color.premiumGray5, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct GoalCategoryChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.premiumCallout)
                .foregroundColor(isSelected ? .white : .premiumGray2)
                .padding(.horizontal, .spacing16)
                .padding(.vertical, .spacing8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.premiumIndigo : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.premiumGray5, lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}