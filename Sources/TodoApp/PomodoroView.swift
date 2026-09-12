import SwiftUI

struct PomodoroView: View {
    @EnvironmentObject var pomodoro: PomodoroTimer
    @EnvironmentObject var i18n: LocalizationManager

    private var progress: Double {
        guard pomodoro.totalSeconds > 0 else { return 0 }
        return 1 - (Double(pomodoro.remainingSeconds) / Double(pomodoro.totalSeconds))
    }

    private var timeText: String {
        let m = pomodoro.remainingSeconds / 60
        let s = pomodoro.remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        VStack(spacing: 28) {
            Text(pomodoro.mode == .focus ? i18n.t("Focusing") : i18n.t("On break"))
                .font(.subheadline).bold()
                .foregroundStyle(Color.accentColor)

            ZStack {
                Circle()
                    .stroke(.separator, lineWidth: 10)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: progress)
                VStack(spacing: 4) {
                    Text(timeText).font(.system(size: 40, weight: .light, design: .rounded))
                        .monospacedDigit()
                    let minutes = pomodoro.mode == .focus ? pomodoro.focusMinutes : pomodoro.breakMinutes
                    Text("\(minutes) \(i18n.t("min"))")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .frame(width: 220, height: 220)

            HStack(spacing: 14) {
                Button {
                    pomodoro.isRunning ? pomodoro.pause() : pomodoro.start()
                } label: {
                    Label(pomodoro.isRunning ? i18n.t("Pause") : i18n.t("Start"), systemImage: pomodoro.isRunning ? "pause.fill" : "play.fill")
                        .frame(minWidth: 90)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    pomodoro.reset()
                } label: {
                    Label(i18n.t("Reset"), systemImage: "arrow.counterclockwise").frame(minWidth: 70)
                }
                .buttonStyle(.bordered)
            }

            Divider().padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 12) {
                Text(i18n.t("Timer Settings")).font(.caption).bold().foregroundStyle(.secondary)
                HStack(spacing: 40) {
                    Stepper(i18n.t("Focus time: %d min", pomodoro.focusMinutes), value: $pomodoro.focusMinutes, in: 5...120, step: 5)
                        .disabled(pomodoro.isRunning)
                    Stepper(i18n.t("Break time: %d min", pomodoro.breakMinutes), value: $pomodoro.breakMinutes, in: 1...60, step: 1)
                        .disabled(pomodoro.isRunning)
                }
            }
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(i18n.t("Pomodoro"))
        .alert(
            pomodoro.justFinishedMode == .focus ? i18n.t("Focus session ended!") : i18n.t("Break ended!"),
            isPresented: Binding(
                get: { pomodoro.justFinishedMode != nil },
                set: { if !$0 { pomodoro.dismissPopup() } }
            )
        ) {
            Button(i18n.t("OK")) { pomodoro.dismissPopup() }
        } message: {
            Text(pomodoro.justFinishedMode == .focus
                 ? i18n.t("You focused for %d minutes. Time for a break.", pomodoro.focusMinutes)
                 : i18n.t("Break's over. Start your next focus session."))
        }
    }
}
