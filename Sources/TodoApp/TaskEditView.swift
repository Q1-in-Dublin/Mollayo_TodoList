import SwiftUI

struct TaskEditView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var i18n: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var editingTask: TaskItem?
    var defaultDate: Date?

    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var hasDueDate: Bool = false
    @State private var dueDate: Date = Date()
    @State private var subtasks: [SubTask] = []
    @State private var newSubtaskName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(editingTask == nil ? i18n.t("New Task") : i18n.t("Edit Task")).font(.headline)

            TextField(i18n.t("Task name"), text: $name)
                .textFieldStyle(.roundedBorder)

            Text(i18n.t("Notes")).foregroundStyle(.secondary).font(.caption)
            TextEditor(text: $notes)
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(.separator))

            Toggle(i18n.t("Set due date"), isOn: $hasDueDate)
            if hasDueDate {
                DatePicker(i18n.t("Due date"), selection: $dueDate, displayedComponents: .date)
            }

            Divider()
            Text(i18n.t("Subtasks")).foregroundStyle(.secondary).font(.caption)
            VStack(alignment: .leading, spacing: 4) {
                ForEach($subtasks) { $sub in
                    HStack {
                        Button { $sub.isDone.wrappedValue.toggle() } label: {
                            Image(systemName: sub.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(sub.isDone ? .green : .secondary)
                        }
                        .buttonStyle(.plain)

                        TextField("", text: $sub.name)
                            .textFieldStyle(.plain)
                            .strikethrough(sub.isDone)
                            .foregroundStyle(sub.isDone ? .secondary : .primary)

                        Button { subtasks.removeAll { $0.id == sub.id } } label: {
                            Image(systemName: "xmark.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                }
                HStack {
                    TextField(i18n.t("New subtask"), text: $newSubtaskName)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addSubtask() }
                    Button { addSubtask() } label: { Image(systemName: "plus.circle.fill") }
                        .buttonStyle(.plain)
                        .disabled(newSubtaskName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            HStack {
                Spacer()
                Button(i18n.t("Cancel")) { dismiss() }
                Button(i18n.t("Save")) { save() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 380)
        .onAppear {
            if let task = editingTask {
                name = task.name
                notes = task.notes
                hasDueDate = task.dueDate != nil
                dueDate = task.dueDate ?? Date()
                subtasks = task.subtasks
            } else if let defaultDate {
                hasDueDate = true
                dueDate = defaultDate
            }
        }
    }

    private func addSubtask() {
        let trimmed = newSubtaskName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        subtasks.append(SubTask(name: trimmed))
        newSubtaskName = ""
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if var task = editingTask {
            task.name = trimmed
            task.notes = notes
            task.dueDate = hasDueDate ? dueDate : nil
            task.subtasks = subtasks
            store.update(task)
        } else {
            store.add(TaskItem(name: trimmed, notes: notes, dueDate: hasDueDate ? dueDate : nil, subtasks: subtasks))
        }
        dismiss()
    }
}
