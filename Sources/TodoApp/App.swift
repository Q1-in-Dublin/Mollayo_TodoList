import SwiftUI

@main
struct TodoApp: App {
    @StateObject private var store = TaskStore()
    @StateObject private var pomodoro = PomodoroTimer()
    @StateObject private var i18n = LocalizationManager()

    init() {
        NotificationManager.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(pomodoro)
                .environmentObject(i18n)
                .environment(\.locale, i18n.locale)
                .frame(width: 840, height: 600)
                .onAppear {
                    pomodoro.i18n = i18n
                    store.i18n = i18n
                }
        }
        .windowResizability(.contentSize)
    }
}
