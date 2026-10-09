import Foundation
import Observation

@Observable
final class SettingsStore {
    private enum Key {
        static let preset = "clockFormatPreset"
        static let customFormat = "clockCustomFormat"
        static let showSeconds = "clockShowSeconds"
        static let hourCycle = "clockHourCycle"
        static let locale = "clockLocalePreference"
    }

    private let defaults: UserDefaults
    private var isLoaded = false
    var onChange: (() -> Void)?

    var preset: ClockFormatPreset {
        didSet { persistAndNotify() }
    }

    var customFormat: String {
        didSet { persistAndNotify() }
    }

    var showSeconds: Bool {
        didSet { persistAndNotify() }
    }

    var hourCycle: HourCyclePreference {
        didSet { persistAndNotify() }
    }

    var localePreference: FormatLocalePreference {
        didSet { persistAndNotify() }
    }

    var clockSettings: ClockSettings {
        ClockSettings(
            preset: preset,
            customFormat: customFormat,
            showSeconds: showSeconds,
            hourCycle: hourCycle,
            localePreference: localePreference
        )
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let fallback = ClockSettings.default
        let storedPreset = defaults.string(forKey: Key.preset) ?? ""
        preset = ClockFormatPreset(rawValue: storedPreset) ?? fallback.preset

        if let storedFormat = defaults.string(forKey: Key.customFormat), !storedFormat.isEmpty {
            customFormat = storedFormat
        } else {
            customFormat = fallback.customFormat
        }

        if defaults.object(forKey: Key.showSeconds) == nil {
            showSeconds = fallback.showSeconds
        } else {
            showSeconds = defaults.bool(forKey: Key.showSeconds)
        }

        let storedHourCycle = defaults.string(forKey: Key.hourCycle) ?? ""
        hourCycle = HourCyclePreference(rawValue: storedHourCycle) ?? fallback.hourCycle

        let storedLocale = defaults.string(forKey: Key.locale) ?? ""
        localePreference = FormatLocalePreference(rawValue: storedLocale) ?? fallback.localePreference
        isLoaded = true
    }

    private func persistAndNotify() {
        guard isLoaded else { return }
        defaults.set(preset.rawValue, forKey: Key.preset)
        defaults.set(customFormat, forKey: Key.customFormat)
        defaults.set(showSeconds, forKey: Key.showSeconds)
        defaults.set(hourCycle.rawValue, forKey: Key.hourCycle)
        defaults.set(localePreference.rawValue, forKey: Key.locale)
        onChange?()
    }
}
