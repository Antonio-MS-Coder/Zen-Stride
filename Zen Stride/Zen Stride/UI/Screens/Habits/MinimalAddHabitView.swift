import SwiftUI
import CoreData

struct MinimalAddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var habitName = ""
    @State private var targetValue: Double = 1
    @State private var targetUnit = "times"
    @State private var selectedIcon = "circle"
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    
    private let commonUnits = ["times", "minutes", "hours", "pages", "glasses", "steps", "words", "reps"]
    private let icons = [
        "circle", "checkmark.circle", "star", "heart", "book", 
        "figure.walk", "drop", "brain.head.profile", "pencil", "music.note"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .notion24) {
                    // Name Section
                    VStack(alignment: .leading, spacing: .notion8) {
                        Text("Name")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextSecondary)
                        
                        TextField("e.g., Read daily", text: $habitName)
                            .font(.notionBody)
                            .padding(.notion12)
                            .background(Color.notionGray50)
                            .overlay(
                                RoundedRectangle(cornerRadius: .notionCornerSmall)
                                    .stroke(Color.notionBorder, lineWidth: 1)
                            )
                    }
                    
                    // Target Section
                    VStack(alignment: .leading, spacing: .notion8) {
                        Text("Daily Target")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextSecondary)
                        
                        HStack(spacing: .notion12) {
                            // Value Input
                            HStack {
                                TextField("1", value: $targetValue, format: .number)
                                    .font(.notionBody)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                                
                                Stepper("", value: $targetValue, in: 1...999)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, .notion12)
                            .padding(.vertical, .notion8)
                            .background(Color.notionGray50)
                            .overlay(
                                RoundedRectangle(cornerRadius: .notionCornerSmall)
                                    .stroke(Color.notionBorder, lineWidth: 1)
                            )
                            
                            // Unit Picker
                            Menu {
                                ForEach(commonUnits, id: \.self) { unit in
                                    Button(unit) {
                                        targetUnit = unit
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(targetUnit)
                                        .font(.notionBody)
                                        .foregroundColor(.notionText)
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.notionTextSecondary)
                                }
                                .padding(.horizontal, .notion12)
                                .padding(.vertical, .notion8)
                                .background(Color.notionGray50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: .notionCornerSmall)
                                        .stroke(Color.notionBorder, lineWidth: 1)
                                )
                            }
                        }
                    }
                    
                    // Icon Section
                    VStack(alignment: .leading, spacing: .notion8) {
                        Text("Icon")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: .notion8) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedIcon == icon ? .notionAccent : .notionTextSecondary)
                                        .frame(width: 44, height: 44)
                                        .background(selectedIcon == icon ? Color.notionAccentLight : Color.notionGray50)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: .notionCornerSmall)
                                                .stroke(selectedIcon == icon ? Color.notionAccent : Color.notionBorder, lineWidth: 1)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Reminder Section
                    VStack(alignment: .leading, spacing: .notion12) {
                        Toggle(isOn: $reminderEnabled) {
                            Text("Daily Reminder")
                                .font(.notionBody)
                                .foregroundColor(.notionText)
                        }
                        .tint(.notionAccent)
                        
                        if reminderEnabled {
                            DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .font(.notionBody)
                                .foregroundColor(.notionText)
                        }
                    }
                    .padding(.notion16)
                    .notionCard()
                    
                    Spacer(minLength: .notion32)
                }
                .padding(.notion16)
            }
            .background(Color.notionBackground)
            .navigationTitle("New Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.notionTextSecondary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        saveHabit()
                    }
                    .foregroundColor(habitName.isEmpty ? .notionTextTertiary : .notionAccent)
                    .disabled(habitName.isEmpty)
                }
            }
        }
    }
    
    private func saveHabit() {
        let newHabit = Habit(context: viewContext)
        newHabit.id = UUID()
        newHabit.name = habitName
        newHabit.iconName = selectedIcon
        newHabit.targetValue = targetValue
        newHabit.targetUnit = targetUnit
        newHabit.frequency = "daily"
        newHabit.isActive = true
        newHabit.createdDate = Date()
        newHabit.category = "General"
        newHabit.colorHex = "#3781FA"
        
        if reminderEnabled {
            newHabit.reminderTime = reminderTime
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error saving habit: \(error)")
        }
    }
}