import SwiftUI

struct SetupView: View {
    @State private var defaultTaskNumber: Int = 3
    @State private var showPreviousDayTasks: Bool = true
    @Binding var isFirstLaunch: Bool
    @Binding var currentContext: PriorityContext
    let contextManager: ContextManagement

    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Priorities")
                .font(.system(size: 28, weight: .bold))

            VStack(alignment: .leading, spacing: 20) {
                Text("Let's set up your preferences")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Number of daily priorities:")
                        .foregroundColor(.secondary)

                    Stepper(value: $defaultTaskNumber, in: 1...10) {
                        Text("\(defaultTaskNumber)")
                            .frame(width: 40)
                    }
                }

                Toggle("Show previous day's priorities", isOn: $showPreviousDayTasks)
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)

            Button(action: savePreferences) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding(40)
        .frame(width: 400)
        // .background(VisualEffect(material: .hudWindow, blendingMode: .behindWindow))
    }

    private func savePreferences() {
        let context = PriorityContext(
            defaultTaskNumber: defaultTaskNumber,
            previousDayTaskView: showPreviousDayTasks
        )
        contextManager.saveSettings(context)
        currentContext = context
        isFirstLaunch = false
    }
}
