import SwiftUI
import CoreData

struct PremiumAddHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var habitName = ""
    @State private var selectedCategory = "Health"
    @State private var selectedIcon = "heart.fill"
    @State private var targetValue: Int = 1
    @State private var selectedFrequency = "Daily"
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    
    @State private var showingIconPicker = false
    @State private var animateIn = false
    
    let categories = ["Health", "Fitness", "Mindfulness", "Learning", "Creativity", "Productivity", "Social", "Custom"]
    let frequencies = ["Daily", "Weekly", "Custom"]
    
    let categoryIcons: [String: String] = [
        "Health": "heart.fill",
        "Fitness": "figure.run",
        "Mindfulness": "brain.head.profile",
        "Learning": "book.fill",
        "Creativity": "paintbrush.fill",
        "Productivity": "checklist",
        "Social": "person.2.fill",
        "Custom": "star.fill"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.premiumGray6
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: .spacing24) {
                        // Header Section
                        headerSection
                            .padding(.top, .spacing24)
                        
                        // Form Sections
                        VStack(spacing: .spacing20) {
                            basicInfoSection
                            categorySection
                            targetSection
                            reminderSection
                            notesSection
                        }
                        .padding(.bottom, .spacing32)
                    }
                    .padding(.horizontal, .spacing20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.premiumIndigo)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .font(.premiumHeadline)
                    .foregroundColor(canSave ? .premiumIndigo : .premiumGray4)
                    .disabled(!canSave)
                }
            }
        }
        .onAppear {
            withAnimation(.premiumSpring) {
                animateIn = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: .spacing16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.premiumIndigo.opacity(0.2), Color.premiumTeal.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: selectedIcon)
                    .font(.system(size: 36))
                    .foregroundColor(.premiumIndigo)
            }
            .scaleEffect(animateIn ? 1 : 0.5)
            .opacity(animateIn ? 1 : 0)
            .animation(.premiumBounce.delay(0.1), value: animateIn)
            
            Text("Create New Habit")
                .font(.premiumTitle2)
                .foregroundColor(.premiumGray1)
            
            Text("Build consistency, one day at a time")
                .font(.premiumCallout)
                .foregroundColor(.premiumGray3)
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Label("HABIT NAME", systemImage: "pencil")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            TextField("Enter habit name", text: $habitName)
                .font(.premiumBody)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .fill(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .stroke(habitName.isEmpty ? Color.premiumGray5 : Color.premiumIndigo.opacity(0.3), lineWidth: 1)
                        )
                )
                .premiumShadowXS()
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
        .animation(.premiumSpring.delay(0.2), value: animateIn)
    }
    
    // MARK: - Category Section
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Label("CATEGORY", systemImage: "folder")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: .spacing12) {
                ForEach(categories, id: \.self) { category in
                    PremiumCategoryChip(
                        title: category,
                        icon: categoryIcons[category] ?? "star.fill",
                        isSelected: selectedCategory == category,
                        action: {
                            withAnimation(.premiumSpring) {
                                selectedCategory = category
                                selectedIcon = categoryIcons[category] ?? "star.fill"
                            }
                        }
                    )
                }
            }
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
        .animation(.premiumSpring.delay(0.3), value: animateIn)
    }
    
    // MARK: - Target Section
    private var targetSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Label("TARGET", systemImage: "target")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            VStack(spacing: .spacing16) {
                // Frequency Selector
                PremiumSegmentedControl(
                    selection: .constant(frequencies.firstIndex(of: selectedFrequency) ?? 0),
                    options: frequencies
                )
                
                // Target Value
                if targetValue > 1 {
                    HStack {
                        Text("Times per \(selectedFrequency.lowercased())")
                            .font(.premiumCallout)
                            .foregroundColor(.premiumGray2)
                        
                        Spacer()
                        
                        HStack(spacing: .spacing12) {
                            Button {
                                if targetValue > 1 {
                                    targetValue -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.premiumIndigo)
                            }
                            
                            Text("\(targetValue)")
                                .font(.premiumTitle3)
                                .foregroundColor(.premiumGray1)
                                .frame(minWidth: 40)
                            
                            Button {
                                targetValue += 1
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.premiumIndigo)
                            }
                        }
                    }
                }
                
                // Quick presets
                HStack(spacing: .spacing8) {
                    Text("Quick set:")
                        .font(.premiumCaption1)
                        .foregroundColor(.premiumGray3)
                    
                    ForEach([1, 3, 5, 7], id: \.self) { value in
                        Button {
                            withAnimation(.premiumSpring) {
                                targetValue = value
                            }
                        } label: {
                            Text("\(value)")
                                .font(.premiumCallout)
                                .foregroundColor(targetValue == value ? .white : .premiumIndigo)
                                .padding(.horizontal, .spacing12)
                                .padding(.vertical, .spacing6)
                                .background(
                                    Capsule()
                                        .fill(targetValue == value ? Color.premiumIndigo : Color.premiumIndigo.opacity(0.1))
                                )
                        }
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
        .animation(.premiumSpring.delay(0.4), value: animateIn)
    }
    
    // MARK: - Reminder Section
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            HStack {
                Label("REMINDER", systemImage: "bell")
                    .font(.premiumCaption1)
                    .foregroundColor(.premiumGray3)
                    .tracking(1.2)
                
                Spacer()
                
                PremiumToggle(isOn: $reminderEnabled)
            }
            
            if reminderEnabled {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .font(.premiumCallout)
                    .tint(.premiumIndigo)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
            }
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
        .animation(.premiumSpring.delay(0.5), value: animateIn)
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: .spacing16) {
            Label("NOTES (OPTIONAL)", systemImage: "note.text")
                .font(.premiumCaption1)
                .foregroundColor(.premiumGray3)
                .tracking(1.2)
            
            TextEditor(text: $notes)
                .font(.premiumCallout)
                .frame(minHeight: 100)
                .padding(.spacing8)
                .background(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: .radiusM)
                        .stroke(Color.premiumGray5, lineWidth: 1)
                )
        }
        .padding(.spacing20)
        .premiumGlassCard()
        .scaleEffect(animateIn ? 1 : 0.95)
        .opacity(animateIn ? 1 : 0)
        .animation(.premiumSpring.delay(0.6), value: animateIn)
    }
    
    // MARK: - Helpers
    private var canSave: Bool {
        !habitName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func saveHabit() {
        guard canSave else { return }
        
        let newHabit = Habit(context: viewContext)
        newHabit.id = UUID()
        newHabit.name = habitName.trimmingCharacters(in: .whitespacesAndNewlines)
        newHabit.category = selectedCategory
        newHabit.iconName = selectedIcon
        newHabit.targetValue = Double(targetValue)
        newHabit.frequency = selectedFrequency
        newHabit.reminderTime = reminderEnabled ? reminderTime : nil
        newHabit.habitDescription = notes.isEmpty ? nil : notes
        newHabit.createdDate = Date()
        newHabit.isActive = true
        
        do {
            try viewContext.save()
            
            #if canImport(UIKit)
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)
            #endif
            
            dismiss()
        } catch {
            print("Error saving habit: \(error)")
        }
    }
}

// MARK: - Category Chip
struct PremiumCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: .spacing8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .premiumIndigo)
                
                Text(title)
                    .font(.premiumCaption1)
                    .foregroundColor(isSelected ? .white : .premiumGray2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing12)
            .background(
                RoundedRectangle(cornerRadius: .radiusM)
                    .fill(isSelected ? Color.premiumIndigo : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusM)
                            .stroke(isSelected ? Color.clear : Color.premiumGray5, lineWidth: 1)
                    )
            )
            .premiumShadowXS()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct PremiumAddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        PremiumAddHabitView()
    }
}