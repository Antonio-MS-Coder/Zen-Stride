import SwiftUI
import CoreData

struct MinimalHabitsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    
    @FetchRequest(
        entity: Habit.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Habit.createdDate, ascending: false)],
        predicate: NSPredicate(format: "isActive == true")
    ) private var habits: FetchedResults<Habit>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if habits.isEmpty {
                        emptyState
                    } else {
                        ForEach(habits) { habit in
                            habitRow(habit)
                            
                            if habit != habits.last {
                                Divider()
                                    .foregroundColor(.notionDivider)
                                    .padding(.leading, .notion48)
                            }
                        }
                    }
                }
            }
            .background(Color.notionBackground)
            .navigationTitle("All Habits")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(.notionAccent)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                MinimalAddHabitView()
            }
            .sheet(item: $selectedHabit) { habit in
                MinimalHabitDetailView(habit: habit)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: .notion16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 48))
                .foregroundColor(.notionTextTertiary)
            
            Text("No habits yet")
                .font(.notionHeading)
                .foregroundColor(.notionText)
            
            Text("Start building better habits")
                .font(.notionBody)
                .foregroundColor(.notionTextSecondary)
            
            Button(action: { showingAddHabit = true }) {
                Text("Add Habit")
                    .font(.notionBody)
                    .foregroundColor(.white)
                    .padding(.horizontal, .notion24)
                    .padding(.vertical, .notion12)
                    .background(Color.notionAccent)
                    .cornerRadius(.notionCornerSmall)
            }
            .padding(.top, .notion8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, .notion64)
    }
    
    private func habitRow(_ habit: Habit) -> some View {
        Button(action: { selectedHabit = habit }) {
            HStack(spacing: .notion12) {
                Image(systemName: habit.iconName ?? "circle")
                    .font(.system(size: 20))
                    .foregroundColor(.notionAccent)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: .notion4) {
                    Text(habit.name ?? "")
                        .font(.notionBody)
                        .foregroundColor(.notionText)
                    
                    HStack(spacing: .notion8) {
                        Text("\(Int(habit.targetValue)) \(habit.targetUnit ?? "")")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextSecondary)
                        
                        Text("•")
                            .foregroundColor(.notionTextTertiary)
                        
                        Text(habit.frequency ?? "daily")
                            .font(.notionCaption)
                            .foregroundColor(.notionTextSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.notionTextTertiary)
            }
            .padding(.horizontal, .notion16)
            .padding(.vertical, .notion12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}