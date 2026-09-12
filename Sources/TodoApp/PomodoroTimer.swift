import Foundation
import AppKit

enum PomodoroMode {
    case focus
    case rest
}

@MainActor
final class PomodoroTimer: ObservableObject {
    @Published var focusMinutes: Int {
        didSet {
            UserDefaults.standard.set(focusMinutes, forKey: "focusMinutes")
            if !isRunning && mode == .focus { remainingSeconds = focusMinutes * 60 }
        }
    }
    @Published var breakMinutes: Int {
        didSet {
            UserDefaults.standard.set(breakMinutes, forKey: "breakMinutes")
            if !isRunning && mode == .rest { remainingSeconds = breakMinutes * 60 }
        }
    }
    @Published var mode: PomodoroMode = .focus
    @Published var remainingSeconds: Int
    @Published var isRunning: Bool = false
    @Published var justFinishedMode: PomodoroMode?
    var i18n: LocalizationManager?

    private var timer: Timer?

    init() {
        let f = UserDefaults.standard.object(forKey: "focusMinutes") as? Int ?? 50
        let b = UserDefaults.standard.object(forKey: "breakMinutes") as? Int ?? 10
        focusMinutes = f
        breakMinutes = b
        remainingSeconds = f * 60
    }

    var totalSeconds: Int { (mode == .focus ? focusMinutes : breakMinutes) * 60 }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        pause()
        remainingSeconds = totalSeconds
    }

    private func tick() {
        guard remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            finishSession()
        }
    }

    private func finishSession() {
        pause()
        let finishedMode = mode
        mode = (mode == .focus) ? .rest : .focus
        remainingSeconds = totalSeconds
        justFinishedMode = finishedMode

        let title = finishedMode == .focus ? i18n?.t("Focus session ended!") : i18n?.t("Break ended!")
        let body = finishedMode == .focus
            ? i18n?.t("You focused for %d minutes. Time for a break.", focusMinutes)
            : i18n?.t("Break's over. Start your next focus session.")

        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.isMiniaturized {
            window.deminiaturize(nil)
        }
        NotificationManager.notify(title: title ?? "", body: body ?? "")
    }

    func dismissPopup() {
        justFinishedMode = nil
    }
}
