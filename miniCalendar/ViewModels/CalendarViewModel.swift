import Foundation
import Observation

@Observable
final class CalendarViewModel {
    private(set) var displayedMonth: Date
    private(set) var today: Date
    private(set) var movesForward = true
    var selectedDate: Date?
    private let settings: SettingsStore

    init(settings: SettingsStore, now: Date = Date()) {
        self.settings = settings
        let calendar = Self.makeCalendar(from: settings)
        let startOfToday = calendar.startOfDay(for: now)
        today = startOfToday
        displayedMonth = Self.monthStart(for: startOfToday, calendar: calendar)
        selectedDate = startOfToday
    }

    var calendar: Calendar {
        Self.makeCalendar(from: settings)
    }

    var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        formatter.setLocalizedDateFormatFromTemplate("yMMM")
        return formatter.string(from: displayedMonth)
    }

    var weekdaySymbols: [String] {
        let calendar = calendar
        let symbols = calendar.shortStandaloneWeekdaySymbols
        guard symbols.count == 7 else { return symbols }
        let locale = calendar.locale ?? settings.clockSettings.locale
        let startIndex = (calendar.firstWeekday - 1 + symbols.count) % symbols.count
        return (0..<7).map { offset in
            symbols[(startIndex + offset) % 7].capitalizingFirstLetter(with: locale)
        }
    }

    var days: [CalendarDay] {
        makeDays()
    }

    var displayedYear: Int {
        calendar.component(.year, from: displayedMonth)
    }

    var displayedMonthNumber: Int {
        calendar.component(.month, from: displayedMonth)
    }

    var availableYears: [Int] {
        let currentYear = calendar.component(.year, from: today)
        let lower = min(currentYear - 10, displayedYear)
        let upper = max(currentYear + 10, displayedYear)
        return Array(lower...upper)
    }

    func monthSymbol(number: Int) -> String {
        var components = calendar.dateComponents([.year], from: displayedMonth)
        components.month = number
        components.day = 1
        guard let date = calendar.date(from: components) else { return "\(number)" }
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        formatter.setLocalizedDateFormatFromTemplate("LLLL")
        let locale = calendar.locale ?? settings.clockSettings.locale
        return formatter.string(from: date).capitalizingFirstLetter(with: locale)
    }

    func showPreviousMonth() {
        guard let date = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
        show(monthStart: date, movesForward: false)
    }

    func showNextMonth() {
        guard let date = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        show(monthStart: date, movesForward: true)
    }

    func showToday() {
        show(monthStart: Self.monthStart(for: today, calendar: calendar), movesForward: today >= displayedMonth)
        selectedDate = today
    }

    func showMonth(number: Int) {
        var components = calendar.dateComponents([.year], from: displayedMonth)
        components.month = number
        components.day = 1
        guard let date = calendar.date(from: components) else { return }
        show(monthStart: date, movesForward: date >= displayedMonth)
    }

    func showYear(_ year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = displayedMonthNumber
        components.day = 1
        guard let date = calendar.date(from: components) else { return }
        show(monthStart: date, movesForward: date >= displayedMonth)
    }

    func select(_ date: Date) {
        selectedDate = calendar.startOfDay(for: date)
    }

    func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return calendar.isDate(selectedDate, inSameDayAs: date)
    }

    func refresh(now: Date) {
        let updatedToday = calendar.startOfDay(for: now)
        guard updatedToday != today else { return }
        today = updatedToday
    }

    func accessibilityLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = calendar.locale
        formatter.dateStyle = .full
        var label = formatter.string(from: date)
        if calendar.isDate(date, inSameDayAs: today) {
            label += ", сегодня"
        }
        return label
    }

    private func show(monthStart: Date, movesForward: Bool) {
        let target = Self.monthStart(for: monthStart, calendar: calendar)
        guard target != displayedMonth else { return }
        self.movesForward = movesForward
        displayedMonth = target
    }

    private func makeDays() -> [CalendarDay] {
        let calendar = calendar
        let monthStart = Self.monthStart(for: displayedMonth, calendar: calendar)
        let weekdayOfFirst = calendar.component(.weekday, from: monthStart)
        let leading = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        guard let gridStart = calendar.date(byAdding: .day, value: -leading, to: monthStart) else { return [] }

        return (0..<42).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else { return nil }
            let start = calendar.startOfDay(for: date)
            return CalendarDay(
                date: start,
                number: String(calendar.component(.day, from: start)),
                isInDisplayedMonth: calendar.isDate(start, equalTo: monthStart, toGranularity: .month),
                isToday: calendar.isDate(start, inSameDayAs: today)
            )
        }
    }

    private static func monthStart(for date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
    }

    private static func makeCalendar(from settings: SettingsStore) -> Calendar {
        switch settings.localePreference {
        case .system:
            var calendar = Calendar.current
            calendar.locale = .autoupdatingCurrent
            return calendar
        case .russian:
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "ru_RU")
            calendar.firstWeekday = 2
            return calendar
        case .english:
            var calendar = Calendar(identifier: .gregorian)
            calendar.locale = Locale(identifier: "en_US")
            calendar.firstWeekday = 1
            return calendar
        }
    }
}
