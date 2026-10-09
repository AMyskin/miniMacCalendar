import AppKit
import Foundation
import Observation

@Observable
final class SettingsViewModel {
    private let store: SettingsStore

    var preset: ClockFormatPreset {
        didSet {
            guard preset != oldValue else { return }
            store.preset = preset
        }
    }

    var customFormat: String {
        didSet {
            guard customFormat != oldValue else { return }
            store.customFormat = customFormat
        }
    }

    var showSeconds: Bool {
        didSet {
            guard showSeconds != oldValue else { return }
            store.showSeconds = showSeconds
        }
    }

    var hourCycle: HourCyclePreference {
        didSet {
            guard hourCycle != oldValue else { return }
            store.hourCycle = hourCycle
        }
    }

    var localePreference: FormatLocalePreference {
        didSet {
            guard localePreference != oldValue else { return }
            store.localePreference = localePreference
        }
    }

    var showWeekNumbers: Bool {
        didSet {
            guard showWeekNumbers != oldValue else { return }
            store.showWeekNumbers = showWeekNumbers
        }
    }

    init(store: SettingsStore) {
        self.store = store
        preset = store.preset
        customFormat = store.customFormat
        showSeconds = store.showSeconds
        hourCycle = store.hourCycle
        localePreference = store.localePreference
        showWeekNumbers = store.showWeekNumbers
    }

    var usesCustomFormat: Bool {
        preset == .custom
    }

    func previewText(at date: Date) -> String {
        ClockFormatter.string(
            from: date,
            settings: ClockSettings(
                preset: preset,
                customFormat: customFormat,
                showSeconds: showSeconds,
                hourCycle: hourCycle,
                localePreference: localePreference
            )
        )
    }

    func quit() {
        NSApplication.shared.terminate(nil)
    }
}
