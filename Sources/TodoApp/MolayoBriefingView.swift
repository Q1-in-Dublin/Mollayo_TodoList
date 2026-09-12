import SwiftUI

struct MolayoBriefingView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var pomodoro: PomodoroTimer
    @EnvironmentObject var i18n: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    private var timerLine: String {
        guard pomodoro.isRunning else { return i18n.t("No timer running right now.") }
        let m = pomodoro.remainingSeconds / 60
        let s = pomodoro.remainingSeconds % 60
        let time = String(format: "%02d:%02d", m, s)
        return pomodoro.mode == .focus
            ? i18n.t("You're focusing — %@ left", time)
            : i18n.t("You're on a break — %@ left", time)
    }

    private var statsLine: String {
        i18n.t("%d of %d tasks done, %d left.", store.completedCount, store.totalCount, store.pendingCount)
    }

    /// Pending tasks, overdue first, then due-today, then soonest-first, then no due date.
    private var pendingTasks: [TaskItem] {
        store.tasks.filter { !$0.isDone }.sorted {
            ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
        }
    }

    private func dueBadge(for date: Date) -> (text: String, color: Color) {
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return (date.formatted(date: .abbreviated, time: .omitted), .red)
        } else if calendar.isDateInToday(date) {
            return (i18n.t("Today"), .orange)
        } else {
            return (date.formatted(date: .abbreviated, time: .omitted), .secondary)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "fish.fill").foregroundStyle(Color.accentColor)
                Text(i18n.t("Molayo Briefing")).font(.headline)
            }

            Label(timerLine, systemImage: "timer").font(.subheadline)
            Text(statsLine).font(.caption).foregroundStyle(.secondary)

            Divider()

            if pendingTasks.isEmpty {
                Text(i18n.t("All done!")).font(.subheadline).foregroundStyle(.secondary)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(pendingTasks) { task in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(alignment: .firstTextBaseline) {
                                    Text(task.name).font(.subheadline).bold()
                                    Spacer()
                                    if let due = task.dueDate {
                                        let badge = dueBadge(for: due)
                                        Text(badge.text).font(.caption2).foregroundStyle(badge.color)
                                    }
                                }
                                if !task.notes.isEmpty {
                                    Text(task.notes).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: 220)
            }

            HStack {
                Spacer()
                Button(i18n.t("Got it")) { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        .frame(width: 360)
    }
}
