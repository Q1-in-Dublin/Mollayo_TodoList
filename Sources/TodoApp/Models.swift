import Foundation

struct SubTask: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var isDone: Bool = false
}

struct TaskItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var notes: String = ""
    var dueDate: Date?
    var isDone: Bool = false
    var snoozeUntil: Date?
    var subtasks: [SubTask] = []

    init(id: UUID = UUID(), name: String, notes: String = "", dueDate: Date? = nil,
         isDone: Bool = false, snoozeUntil: Date? = nil, subtasks: [SubTask] = []) {
        self.id = id
        self.name = name
        self.notes = notes
        self.dueDate = dueDate
        self.isDone = isDone
        self.snoozeUntil = snoozeUntil
        self.subtasks = subtasks
    }

    // Fields added after the app first shipped must decode gracefully when
    // absent from older saved data (synthesized Codable throws on a missing
    // key instead of falling back to the property's default value).
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try c.decode(String.self, forKey: .name)
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        dueDate = try c.decodeIfPresent(Date.self, forKey: .dueDate)
        isDone = try c.decodeIfPresent(Bool.self, forKey: .isDone) ?? false
        snoozeUntil = try c.decodeIfPresent(Date.self, forKey: .snoozeUntil)
        subtasks = try c.decodeIfPresent([SubTask].self, forKey: .subtasks) ?? []
    }
}
