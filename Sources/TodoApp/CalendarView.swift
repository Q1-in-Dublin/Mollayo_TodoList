import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var store: TaskStore
    @EnvironmentObject var i18n: LocalizationManager
    @State private var displayedMonth: Date = Date().startOfMonth
    @State private var selectedDate: Date = Date()
    @State private var showAddSheet = false

    private var calendar: Calendar {
        var cal = Calendar.current
        cal.locale = i18n.locale
        cal.firstWeekday = 2 // Monday
        return cal
    }

    private var weekdaySymbols: [String] {
        let f = DateFormatter()
        f.locale = i18n.locale
        let symbols = f.shortStandaloneWeekdaySymbols ?? ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
        return Array(symbols[1...] + symbols[..<1]) // Sunday-first -> Monday-first
    }

    private var monthTitle: String {
        let f = DateFormatter()
        f.locale = i18n.locale
        f.setLocalizedDateFormatFromTemplate("yMMMM")
        return f.string(from: displayedMonth)
    }

    private var gridDays: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else { return [] }
        let firstWeekday = calendar.component(.weekday, from: displayedMonth)
        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: leading)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: displayedMonth) {
                days.append(date)
            }
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    private func hasTask(on date: Date) -> Bool {
        store.tasks.contains { task in
            guard let due = task.dueDate else { return false }
            return calendar.isDate(due, inSameDayAs: date)
        }
    }

    private var selectedDayTasks: [TaskItem] {
        store.tasks.filter { task in
            guard let due = task.dueDate else { return false }
            return calendar.isDate(due, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Button { changeMonth(-1) } label: { Image(systemName: "chevron.left") }
                Text(monthTitle).font(.headline).frame(minWidth: 120)
                Button { changeMonth(1) } label: { Image(systemName: "chevron.right") }
                Spacer()
            }
            .buttonStyle(.plain)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption).bold()
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                ForEach(Array(gridDays.enumerated()), id: \.offset) { _, date in
                    dayCell(date)
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.separator))

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(selectedDate, style: .date).font(.subheadline).bold()
                    Spacer()
                    Button { showAddSheet = true } label: { Image(systemName: "plus") }
                        .buttonStyle(.plain)
                }
                .padding(10)
                Divider()
                if selectedDayTasks.isEmpty {
                    Text(i18n.t("No tasks")).foregroundStyle(.secondary).font(.caption).padding(10)
                } else {
                    ForEach(selectedDayTasks) { task in
                        TaskRow(task: task) {}
                            .padding(.horizontal, 10).padding(.vertical, 6)
                        Divider()
                    }
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(.separator))
        }
        .padding()
        .navigationTitle(i18n.t("Calendar"))
        .sheet(isPresented: $showAddSheet) { TaskEditView(defaultDate: selectedDate) }
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    @ViewBuilder
    private func dayCell(_ date: Date?) -> some View {
        VStack(spacing: 4) {
            if let date {
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                Text("\(calendar.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(isToday || isSelected ? .bold : .regular)
                    .frame(width: 22, height: 22)
                    .background(isSelected ? Color.accentColor : .clear)
                    .foregroundStyle(isSelected ? .white : (isToday ? Color.accentColor : .primary))
                    .clipShape(Circle())
                if hasTask(on: date) {
                    Circle().fill(Color.accentColor).frame(width: 4, height: 4)
                } else {
                    Circle().fill(.clear).frame(width: 4, height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
        .onTapGesture { if let date { selectedDate = date } }
    }
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
}
