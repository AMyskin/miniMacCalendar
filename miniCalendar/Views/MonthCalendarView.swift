import Foundation
import SwiftUI

struct MonthCalendarView: View {
    var model: CalendarViewModel
    var onOpenSettings: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 8) {
            header
            weekdayRow
            Divider()
            grid
                .clipped()
            footer
        }
        .padding(16)
        .frame(width: 308)
    }

    private var header: some View {
        HStack(spacing: 8) {
            monthMenu
            Spacer(minLength: 8)
            HoverSymbolButton(systemName: "chevron.left", help: "Предыдущий месяц") {
                changeMonth(model.showPreviousMonth)
            }
            HoverSymbolButton(systemName: "chevron.right", help: "Следующий месяц") {
                changeMonth(model.showNextMonth)
            }
        }
    }

    private var monthMenu: some View {
        Menu {
            Button("Сегодня") {
                changeMonth(model.showToday)
            }
            Divider()
            ForEach(1...12, id: \.self) { month in
                Toggle(model.monthSymbol(number: month), isOn: monthBinding(month))
            }
            Divider()
            Menu("Год") {
                ForEach(model.availableYears, id: \.self) { year in
                    Toggle(String(year), isOn: yearBinding(year))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(model.monthTitle)
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)
            }
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel(model.monthTitle)
    }

    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(model.weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(model.days) { day in
                DayCell(
                    day: day,
                    isSelected: model.isSelected(day.date),
                    accessibilityLabel: model.accessibilityLabel(for: day.date)
                ) {
                    model.select(day.date)
                }
            }
        }
        .id(model.displayedMonth)
        .transition(.push(from: model.movesForward ? .trailing : .leading))
    }

    private var footer: some View {
        HStack {
            Spacer()
            HoverSymbolButton(systemName: "gearshape", weight: .regular, help: "Настройки", action: onOpenSettings)
        }
        .padding(.top, 4)
    }

    private func monthBinding(_ month: Int) -> Binding<Bool> {
        Binding(
            get: { model.displayedMonthNumber == month },
            set: { isOn in
                guard isOn else { return }
                changeMonth { model.showMonth(number: month) }
            }
        )
    }

    private func yearBinding(_ year: Int) -> Binding<Bool> {
        Binding(
            get: { model.displayedYear == year },
            set: { isOn in
                guard isOn else { return }
                changeMonth { model.showYear(year) }
            }
        )
    }

    private func changeMonth(_ update: () -> Void) {
        withAnimation(.snappy(duration: 0.28)) {
            update()
        }
    }
}

private struct DayCell: View {
    let day: CalendarDay
    let isSelected: Bool
    let accessibilityLabel: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Text(day.number)
                .font(.system(size: 13, weight: day.isToday ? .semibold : .regular))
                .monospacedDigit()
                .foregroundStyle(foreground)
                .frame(width: 28, height: 28)
                .background { background }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits(day.isToday || isSelected ? .isSelected : [])
    }

    private var foreground: AnyShapeStyle {
        if day.isToday {
            AnyShapeStyle(Color.white)
        } else if day.isInDisplayedMonth {
            AnyShapeStyle(HierarchicalShapeStyle.primary)
        } else {
            AnyShapeStyle(HierarchicalShapeStyle.tertiary)
        }
    }

    @ViewBuilder
    private var background: some View {
        if day.isToday {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.accentColor)
        } else if isSelected {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.accentColor, lineWidth: 1.5)
        } else if isHovering {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(.quaternary)
        }
    }
}

#Preview("Calendar") {
    let defaults = UserDefaults(suiteName: "miniCalendar.preview.calendar") ?? .standard
    MonthCalendarView(model: CalendarViewModel(settings: SettingsStore(defaults: defaults))) {}
        .padding()
}
