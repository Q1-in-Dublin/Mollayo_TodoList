import SwiftUI

enum Tab: String, CaseIterable, Identifiable {
    case tasks, calendar, pomodoro, settings, about
    var id: String { rawValue }

    var icon: String {
        switch self {
        case .tasks: return "checklist"
        case .calendar: return "calendar"
        case .pomodoro: return "timer"
        case .settings: return "gearshape"
        case .about: return "info.circle"
        }
    }

    @MainActor
    func title(_ i18n: LocalizationManager) -> String {
        switch self {
        case .tasks: return i18n.t("Tasks")
        case .calendar: return i18n.t("Calendar")
        case .pomodoro: return i18n.t("Pomodoro")
        case .settings: return i18n.t("Settings")
        case .about: return i18n.t("About")
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var i18n: LocalizationManager
    @State private var selection: Tab? = .tasks
    @State private var showBriefing = false

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(Tab.allCases, selection: $selection) { tab in
                    Label(tab.title(i18n), systemImage: tab.icon).tag(tab)
                }
                Divider()
                Button { showBriefing = true } label: {
                    Label("Molayo", systemImage: "fish.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(12)
                .foregroundStyle(Color.accentColor)
            }
            .navigationSplitViewColumnWidth(160)
        } detail: {
            Group {
                switch selection ?? .tasks {
                case .tasks: TaskListView()
                case .calendar: CalendarView()
                case .pomodoro: PomodoroView()
                case .settings: SettingsView()
                case .about: AboutView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showBriefing) { MolayoBriefingView() }
    }
}
