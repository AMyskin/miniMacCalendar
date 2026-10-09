import Foundation

enum ClockFormatPreset: String, CaseIterable, Identifiable, Codable {
    case weekdayDayMonthTime
    case dayMonthYearTime
    case numericDateTime
    case timeOnly
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekdayDayMonthTime: "День и время"
        case .dayMonthYearTime: "Полная дата"
        case .numericDateTime: "Числовая дата"
        case .timeOnly: "Только время"
        case .custom: "Свой формат"
        }
    }
}

enum HourCyclePreference: String, CaseIterable, Identifiable, Codable {
    case system
    case twentyFour
    case twelve

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Как в системе"
        case .twentyFour: "24 часа"
        case .twelve: "12 часов"
        }
    }
}

enum FormatLocalePreference: String, CaseIterable, Identifiable, Codable {
    case system
    case russian
    case english

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Система"
        case .russian: "Русский"
        case .english: "English"
        }
    }

    var locale: Locale {
        switch self {
        case .system: .autoupdatingCurrent
        case .russian: Locale(identifier: "ru_RU")
        case .english: Locale(identifier: "en_US")
        }
    }
}

struct ClockSettings: Equatable {
    var preset: ClockFormatPreset
    var customFormat: String
    var showSeconds: Bool
    var hourCycle: HourCyclePreference
    var localePreference: FormatLocalePreference

    static let `default` = ClockSettings(
        preset: .weekdayDayMonthTime,
        customFormat: "EEE, d MMM HH:mm",
        showSeconds: false,
        hourCycle: .system,
        localePreference: .system
    )

    var locale: Locale { localePreference.locale }

    var includesSeconds: Bool {
        switch preset {
        case .custom:
            customFormat.contains("s")
        default:
            showSeconds
        }
    }
}

enum ClockFormatter {
    static func string(from date: Date, settings: ClockSettings) -> String {
        switch settings.preset {
        case .weekdayDayMonthTime:
            weekdayDayMonthTime(date, settings: settings)
        case .dayMonthYearTime:
            dayMonthYearTime(date, settings: settings)
        case .numericDateTime:
            numericDateTime(date, settings: settings)
        case .timeOnly:
            timeString(from: date, settings: settings)
        case .custom:
            custom(date, settings: settings)
        }
    }

    private static func weekdayDayMonthTime(_ date: Date, settings: ClockSettings) -> String {
        let locale = settings.locale
        let weekday = part(date, locale: locale, template: "EEE")
        let day = part(date, locale: locale, template: "d")
        let month = part(date, locale: locale, template: "MMM")
        let time = timeString(from: date, settings: settings)
        return "\(weekday), \(day) \(month) \(time)".capitalizingFirstLetter(with: locale)
    }

    private static func dayMonthYearTime(_ date: Date, settings: ClockSettings) -> String {
        let locale = settings.locale
        let day = part(date, locale: locale, template: "d")
        let month = part(date, locale: locale, template: "MMMM")
        let year = part(date, locale: locale, template: "y")
        let time = timeString(from: date, settings: settings)
        return "\(day) \(month) \(year), \(time)"
    }

    private static func numericDateTime(_ date: Date, settings: ClockSettings) -> String {
        let datePart = part(date, locale: settings.locale, template: "ddMMyyyy")
        let time = timeString(from: date, settings: settings)
        return "\(datePart) \(time)"
    }

    private static func custom(_ date: Date, settings: ClockSettings) -> String {
        let format = settings.customFormat.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = format.isEmpty ? ClockSettings.default.customFormat : format
        return formatter(locale: settings.locale, format: pattern).string(from: date)
    }

    private static func timeString(from date: Date, settings: ClockSettings) -> String {
        switch settings.hourCycle {
        case .system:
            let template = settings.showSeconds ? "jmmss" : "jmm"
            return part(date, locale: settings.locale, template: template)
        case .twentyFour:
            let format = settings.showSeconds ? "HH:mm:ss" : "HH:mm"
            return formatter(locale: settings.locale, format: format).string(from: date)
        case .twelve:
            let format = settings.showSeconds ? "h:mm:ss a" : "h:mm a"
            return formatter(locale: settings.locale, format: format).string(from: date)
        }
    }

    private static func part(_ date: Date, locale: Locale, template: String) -> String {
        formatter(locale: locale, template: template).string(from: date)
    }

    private static func formatter(locale: Locale, template: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(template)
        return formatter
    }

    private static func formatter(locale: Locale, format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = format
        return formatter
    }
}

extension String {
    func capitalizingFirstLetter(with locale: Locale) -> String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased(with: locale) + dropFirst()
    }
}
