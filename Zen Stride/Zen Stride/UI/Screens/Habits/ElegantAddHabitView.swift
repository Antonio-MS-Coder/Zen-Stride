import SwiftUI
import CoreData

struct ElegantAddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var habitName = ""
    @State private var selectedCategory = "Health"
    @State private var targetValue: Double = 1
    @State private var targetUnit = "times"
    @State private var selectedColor = Color.zenPrimary
    @State private var selectedIcon = "star.fill"
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    
    @State private var showingSuccess = false
    
    let categories = ["Health", "Fitness", "Learning", "Mindfulness", "Productivity", "Creativity", "Social", "Finance"]
    let units = ["times", "minutes", "hours", "pages", "glasses", "steps", "reps", "sets"]
    let icons = ["star.fill", "heart.fill", "brain.head.profile", "book.fill", "figure.run", "dumbbell.fill", "pencil", "chart.line.uptrend.xyaxis"]
    let colors = [Color.zenPrimary, Color.zenSecondary, Color.zenTertiary, Color.zenSuccess, Color.purple, Color.orange]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: .zen24) {
                    // Habit Name
                    VStack(alignment: .leading, spacing: .zen8) {
                        Label("Habit Name", systemImage: "pencil")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                        
                        TextField("e.g., Morning meditation", text: $habitName)
                            .font(.zenBody)
                            .padding(.zen12)
                            .background(Color.zenCloud)
                            .cornerRadius(.zenRadiusSmall)
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: .zen12) {
                        Label("Category", systemImage: "folder")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .zen8) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryChip(
                                        title: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Target Setting
                    VStack(alignment: .leading, spacing: .zen12) {
                        Label("Daily Target", systemImage: "target")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                        
                        HStack(spacing: .zen16) {
                            // Value stepper
                            HStack {
                                Button {
                                    if targetValue > 1 {
                                        targetValue -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(targetValue > 1 ? .zenPrimary : .zenMist)
                                }
                                .disabled(targetValue <= 1)
                                
                                Text("\(Int(targetValue))")
                                    .font(.zenTitle)
                                    .foregroundColor(.zenTextPrimary)
                                    .frame(minWidth: 50)
                                
                                Button {
                                    targetValue += 1
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 24))
                                        .foregroundColor(.zenPrimary)
                                }
                            }
                            
                            // Unit picker
                            Picker("Unit", selection: $targetUnit) {
                                ForEach(units, id: \.self) { unit in
                                    Text(unit).tag(unit)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(.horizontal, .zen12)
                            .padding(.vertical, .zen8)
                            .background(Color.zenCloud)
                            .cornerRadius(.zenRadiusSmall)
                        }
                    }
                    
                    // Visual Customization
                    VStack(alignment: .leading, spacing: .zen12) {
                        Label("Appearance", systemImage: "paintbrush")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                        
                        // Icon Selection
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: .zen12) {
                                ForEach(icons, id: \.self) { icon in
                                    IconOption(
                                        icon: icon,
                                        isSelected: selectedIcon == icon,
                                        color: selectedColor,
                                        action: { selectedIcon = icon }
                                    )
                                }
                            }
                        }
                        
                        // Color Selection
                        HStack(spacing: .zen12) {
                            ForEach(colors, id: \.self) { color in
                                ColorOption(
                                    color: color,
                                    isSelected: selectedColor == color,
                                    action: { selectedColor = color }
                                )
                            }
                        }
                    }
                    
                    // Reminder Settings
                    VStack(alignment: .leading, spacing: .zen12) {
                        HStack {
                            Label("Daily Reminder", systemImage: "bell")
                                .font(.zenCaption)
                                .foregroundColor(.zenTextSecondary)
                            
                            Spacer()
                            
                            Toggle("", isOn: $reminderEnabled)
                                .labelsHidden()
                        }
                        
                        if reminderEnabled {
                            DatePicker(
                                "Reminder Time",
                                selection: $reminderTime,
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.zen12)
                            .background(Color.zenCloud)
                            .cornerRadius(.zenRadiusSmall)
                        }
                    }
                    
                    // Notes (Optional)
                    VStack(alignment: .leading, spacing: .zen8) {
                        Label("Notes (Optional)", systemImage: "note.text")
                            .font(.zenCaption)
                            .foregroundColor(.zenTextSecondary)
                        
                        TextEditor(text: $notes)
                            .font(.zenBody)
                            .frame(minHeight: 80)
                            .padding(.zen8)
                            .background(Color.zenCloud)
                            .cornerRadius(.zenRadiusSmall)
                    }
                }
                .padding(.zen20)
            }
            .background(Color.zenBackground)
            .navigationTitle("New Habit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.zenTextSecondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createHabit()
                    }
                    .font(.zenButton)
                    .foregroundColor(.zenPrimary)
                    .disabled(habitName.isEmpty)
                }
            }
        }
        .overlay(
            showingSuccess ? 
            SuccessToast(message: "Habit created!", isShowing: $showingSuccess)
                .padding(.top, .zen48)
                .padding(.horizontal, .zen20)
                .transition(.move(edge: .top).combined(with: .opacity))
            : nil,
            alignment: .top
        )
    }
    
    private func createHabit() {
        let newHabit = Habit(context: viewContext)
        newHabit.id = UUID()
        newHabit.name = habitName
        newHabit.category = selectedCategory
        newHabit.targetValue = targetValue
        newHabit.targetUnit = targetUnit
        newHabit.createdDate = Date()
        newHabit.isActive = true
        newHabit.reminderTime = reminderEnabled ? reminderTime : nil
        
        do {
            try viewContext.save()
            
            withAnimation {
                showingSuccess = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } catch {
            print("Error creating habit: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.zenCaption)
                .foregroundColor(isSelected ? .white : .zenTextPrimary)
                .padding(.horizontal, .zen16)
                .padding(.vertical, .zen8)
                .background(
                    RoundedRectangle(cornerRadius: .zenRadiusSmall)
                        .fill(isSelected ? Color.zenPrimary : Color.zenCloud)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct IconOption: View {
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(isSelected ? color : .zenTextTertiary)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: .zenRadiusSmall)
                        .fill(isSelected ? color.opacity(0.1) : Color.zenCloud)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .zenRadiusSmall)
                        .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ColorOption: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 32, height: 32)
                .overlay(
                    Circle()
                        .stroke(Color.zenSurface, lineWidth: 3)
                        .scaleEffect(isSelected ? 1.2 : 0)
                        .animation(.zenSpring, value: isSelected)
                )
                .overlay(
                    isSelected ? 
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    : nil
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}