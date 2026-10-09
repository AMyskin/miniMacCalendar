import Foundation
import Observation

@Observable
final class MenuBarClockViewModel {
    private(set) var now = Date()

    private let settings: SettingsStore
    private var timer: Timer?
    private var repeatsEverySecond = false

    init(settings: SettingsStore) {
        self.settings = settings
        settings.onChange = { [weak self] in
            self?.handleSettingsChange()
        }
        armTimer()
    }

    var title: String {
        ClockFormatter.string(from: now, settings: settings.clockSettings)
    }

    private func handleSettingsChange() {
        now = Date()
        if settings.clockSettings.includesSeconds != repeatsEverySecond {
            armTimer()
        }
    }

    private func tick() {
        now = Date()
    }

    private func armTimer() {
        timer?.invalidate()
        let everySecond = settings.clockSettings.includesSeconds
        repeatsEverySecond = everySecond
        if everySecond {
            let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        } else {
            scheduleNextMinute()
        }
    }

    private func scheduleNextMinute() {
        timer?.invalidate()
        let timer = Timer(timeInterval: secondsUntilNextMinute(), repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.tick()
                guard !self.repeatsEverySecond else { return }
                self.scheduleNextMinute()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func secondsUntilNextMinute() -> TimeInterval {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        let startOfMinute = calendar.date(from: components) ?? Date()
        let nextMinute = calendar.date(byAdding: .minute, value: 1, to: startOfMinute) ?? Date().addingTimeInterval(60)
        return max(0.05, nextMinute.timeIntervalSinceNow)
    }
}
