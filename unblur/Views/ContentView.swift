import SwiftUI

struct ContentView: View {
    @State private var showcasePreviousDayPriorities: Bool = true
    @State private var priorities: [String]
    @State private var previousDayPriorities: [Priority] = []
    @State private var isFirstLaunch: Bool
    @State private var showDisplayView: Bool = false
    @State private var currentContext: PriorityContext
    @State private var isUpdatingSettings = false
    @Environment(\.colorScheme) var colorScheme

    private let contextManager = ContextManagement()
    private let priorityManager = PriorityManagement()
    
    enum ActionType {
        case update
    }
    

    init() {
        let isFirstLaunch = !contextManager.checkDatabaseExistence()
        let currentContext =
            isFirstLaunch
            ? PriorityContext(defaultTaskNumber: 3, previousDayTaskView: true)
            : contextManager.loadSettings()
        let previosDayPriorities = priorityManager.getPreviousDayPriorties()

        _isFirstLaunch = State(initialValue: isFirstLaunch)
        _currentContext = State(initialValue: currentContext)
        _priorities = State(
            initialValue: Array(repeating: "", count: currentContext.defaultTaskNumber))
        _previousDayPriorities = State(initialValue: previosDayPriorities)
    }

    private func savePriorities() {
        let currentTime = Date().timeIntervalSince1970
        for (index, text) in priorities.enumerated() {
            if !text.isEmpty {
                let priority = Priority(
                    id: UUID().uuidString,
                    timestamp: currentTime,
                    text: text,
                    priority: index + 1,
                    isEdited: false
                )
                priorityManager.insertPriority(priority)
            }
        }

        showDisplayView = true
    }

    private func addPriorityLocaly() {
        priorities.append("")
    }

    private func removePriority() {
        let lastElement: String? = priorities.popLast()
        if lastElement != nil {
            print("Removed \(lastElement!)")
        }
    }

    private func getSubmittedPrioritiesObjects() -> [Priority] {
        var currentPriorities: [Priority] = []
        for (index, text) in priorities.enumerated() {
            if !text.isEmpty {
                currentPriorities.append(
                    Priority(
                        id: UUID().uuidString,
                        timestamp: Date().timeIntervalSince1970,
                        text: text,
                        priority: index + 1,
                        isEdited: false
                    ))
            }
        }
        return currentPriorities
    }

    private var previousDayView: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("Yesterday's Priorities")
                .font(.system(size: 16, weight: .semibold))
                .padding()

            ForEach(previousDayPriorities) { priority in
                HStack(alignment: .center) {
                    Text(priority.text)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var headerView: some View {
        VStack {
            Text("Good Morning José!")
                .font(.system(size: 24, weight: .bold))
            Text("What are your main priorities for today?")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            Button(action: savePriorities) {
                Text("Save Priorities")
            }
            Spacer()
            Button(action: addPriorityLocaly) {
                Image(systemName: "plus.circle.fill")
                Text("Add")
            }
            .buttonStyle(.borderless)

            Button(action: removePriority) {
                Image(systemName: "minus.circle.fill")
                Text("Remove")
            }
            .buttonStyle(.borderless)
            .disabled(priorities.count <= 1)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                if showDisplayView {
                    let currentPriorities = getSubmittedPrioritiesObjects()
                    DisplayView(
                        priorities: currentPriorities,
                        showDisplayView: $showDisplayView,
                        priorityManager: priorityManager
                    )
                } else {
                    mainView
                        .overlay(
                            VStack {
                                HStack {
                                    Spacer()
                                    if isUpdatingSettings {
                                        UpdateSettingsMenu(
                                            isUpdatingSettings: $isUpdatingSettings,
                                            contextManager: contextManager
                                        )
                                    } else {
                                        MenuButton()
                                    }
                                }
                                .padding()
                                Spacer()
                            }
                        )
                }
            }
        }
        .frame(minWidth: 500, minHeight: 500)
    }

    private var mainView: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 20) {
                if currentContext.previousDayTaskView && !previousDayPriorities.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Spacer()
                        headerView
                        
                        PriorityInputView(
                            priorities: $priorities,
                            onSave: savePriorities
                        )
                        
                        controlButtons
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                    
                    previousDayView
                } else {
                    VStack(spacing: 20) {
                        Spacer()
                        headerView
                        
                        PriorityInputView(
                            priorities: $priorities,
                            onSave: savePriorities
                        )
                        
                        controlButtons
                        Spacer()
                    }
                    .padding()
                }
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(colorScheme == .dark ? .darkGray : .white).opacity(0.1),
                        Color(colorScheme == .dark ? .black : .gray).opacity(0.2),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func MenuButton() -> some View {
        Menu {
            Button(action: { handleAction(.update) }) {
                Label("Update Default Priorities Number", systemImage: "pencil")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
                .background(Color.clear)
                .contentShape(Rectangle())
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(width: 44, height: 44)
    }

    private func handleAction(_ action: ActionType?) {
        guard let action = action else { return }
        switch action {
        case .update:
            isUpdatingSettings = true
        }
    }
}
