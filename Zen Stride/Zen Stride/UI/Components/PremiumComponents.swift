import SwiftUI

// MARK: - Premium Segmented Control
struct PremiumSegmentedControl: View {
    @Binding var selection: Int
    let options: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(options.indices, id: \.self) { index in
                Button {
                    withAnimation(.premiumQuick) {
                        selection = index
                    }
                } label: {
                    Text(options[index])
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(selection == index ? .white : .premiumGray2)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: .radiusM)
                                .fill(selection == index ? Color.premiumIndigo : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: .radiusL)
                .fill(Color.premiumGray6)
        )
    }
}

// MARK: - Premium Toggle
struct PremiumToggle: View {
    @Binding var isOn: Bool
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.premiumBody)
                .foregroundColor(.premiumGray1)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.premiumIndigo)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Preview
struct PremiumComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PremiumSegmentedControl(
                selection: .constant(0),
                options: ["Daily", "Weekly", "Monthly"]
            )
            
            PremiumToggle(
                isOn: .constant(true),
                title: "Enable Notifications"
            )
        }
        .padding()
    }
}