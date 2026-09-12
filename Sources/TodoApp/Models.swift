import Foundation

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var notes: String = ""
    var dueDate: Date?
    var isDone: Bool = false
    var snoozeUntil: Date?
}
