import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var i18n: LocalizationManager
    @State private var showOnlyPending = false
    @State private var showAddSheet = false
    @State private var editingTask: TaskItem?

    private var filtered: [TaskItem] {
        let sorted = store.tasks.sorted { ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture) }
        return showOnlyPending ? sorted.filter { !$0.isDone } : sorted
    }

    var body: some View {
        VStack(spacing: 0) {
            StatsBar()
            Toggle(i18n.t("Show pending only"), isOn: $showOnlyPending)
                .padding(.horizontal)
                .padding(.top, 8)

            List {
                ForEach(filtered) { task in
                    TaskRow(task: task) { editingTask = task }
                }
                .onDelete { offsets in store.delete(at: offsets, in: filtered) }
            }
        }
        .navigationTitle(i18n.t("Tasks"))
        .toolbar {
            Button { showAddSheet = true } label: { Label(i18n.t("Add"), systemImage: "plus") }
        }
        .sheet(isPresented: $showAddSheet) { TaskEditView() }
        .sheet(item: $editingTask) { task in TaskEditView(editingTask: task) }
    }
}

struct TaskRow: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var i18n: LocalizationManager
    let task: TaskItem
    let onTap: () -> Void

    private var isSnoozed: Bool {
        guard let until = task.snoozeUntil else { return false }
        return until > Date()
    }

    private var snoozeTimeText: String {
        guard let until = task.snoozeUntil else { return "" }
        let f = DateFormatter()
        f.locale = i18n.locale
        f.timeStyle = .short
        f.dateStyle = .none
        return f.string(from: until)
    }

    var body: some View {
        HStack {
            Button { store.toggleDone(task) } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                if !task.notes.isEmpty {
                    Text(task.notes).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                if isSnoozed {
                    Text(i18n.t("Remind again at %@", snoozeTimeText))
                        .font(.caption2).foregroundStyle(.orange)
                }
            }

            Spacer()

            if let due = task.dueDate {
                Text(due, style: .date).font(.caption).foregroundStyle(.secondary)
            }

            if !task.isDone {
                Button { store.snooze(task) } label: {
                    Image(systemName: "fish")
                        .foregroundStyle(isSnoozed ? .orange : .secondary)
                }
                .buttonStyle(.plain)
                .help(i18n.t("I forgot"))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}
