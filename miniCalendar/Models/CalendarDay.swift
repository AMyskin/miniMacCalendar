import Foundation

struct CalendarDay: Identifiable, Equatable {
    let date: Date
    let number: String
    let isInDisplayedMonth: Bool
    let isToday: Bool

    var id: Date { date }
}
