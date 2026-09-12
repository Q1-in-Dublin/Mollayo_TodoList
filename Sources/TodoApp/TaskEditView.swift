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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(editingTask == nil ? i18n.t("New Task") : i18n.t("Edit Task")).font(.headline)

            TextField(i18n.t("Task name"), text: $name)
                .textFieldStyle(.roundedBorder)

            Text(i18n.t("Notes")).foregroundStyle(.secondary).font(.caption)
            TextEditor(text: $notes)
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(.separator))

            Toggle(i18n.t("Set due date"), isOn: $hasDueDate)
            if hasDueDate {
                DatePicker(i18n.t("Due date"), selection: $dueDate, displayedComponents: .date)
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
            } else if let defaultDate {
                hasDueDate = true
                dueDate = defaultDate
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if var task = editingTask {
            task.name = trimmed
            task.notes = notes
            task.dueDate = hasDueDate ? dueDate : nil
            store.update(task)
        } else {
            store.add(TaskItem(name: trimmed, notes: notes, dueDate: hasDueDate ? dueDate : nil))
        }
        dismiss()
    }
}
