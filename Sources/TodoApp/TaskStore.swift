import Foundation

@MainActor
final class TaskStore: ObservableObject {
    @Published var tasks: [TaskItem] = [] {
        didSet { save() }
    }
    var i18n: LocalizationManager?

    private let fileURL: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = support.appendingPathComponent("Mollayo", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let url = dir.appendingPathComponent("tasks.json")

        // One-time migration from the old "Molayo" (pre-rename) storage folder.
        let oldURL = support.appendingPathComponent("Molayo/tasks.json")
        if !FileManager.default.fileExists(atPath: url.path), FileManager.default.fileExists(atPath: oldURL.path) {
            try? FileManager.default.copyItem(at: oldURL, to: url)
        }
        return url
    }()

    init() {
        load()
    }

    var totalCount: Int { tasks.count }
    var completedCount: Int { tasks.filter(\.isDone).count }
    var pendingCount: Int { totalCount - completedCount }

    func add(_ task: TaskItem) {
        tasks.append(task)
    }

    func update(_ task: TaskItem) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx] = task
    }

    func delete(at offsets: IndexSet, in filtered: [TaskItem]) {
        let ids = offsets.map { filtered[$0].id }
        tasks.removeAll { ids.contains($0.id) }
    }

    func toggleDone(_ task: TaskItem) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[idx].isDone.toggle()
    }

    /// "Mollayo" (I forgot) — reminds the user about this task again after a short delay.
    func snooze(_ task: TaskItem, minutes: Int = 15) {
        guard let idx = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        let remindAt = Date().addingTimeInterval(TimeInterval(minutes * 60))
        tasks[idx].snoozeUntil = remindAt
        NotificationManager.scheduleDelayed(
            title: task.name,
            body: i18n?.t("Don't forget this one!") ?? "",
            after: TimeInterval(minutes * 60)
        )
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        tasks = (try? JSONDecoder().decode([TaskItem].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(tasks) else { return }
        try? data.write(to: fileURL)
    }
}
