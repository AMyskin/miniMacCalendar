import Foundation
import SwiftUI

struct CalendarPopoverView: View {
    var clock: MenuBarClockViewModel
    var calendar: CalendarViewModel
    var settings: SettingsViewModel

    @State private var showsSettings = false

    var body: some View {
        Group {
            if showsSettings {
                SettingsView(model: settings, now: clock.now) {
                    showsSettings = false
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            } else {
                MonthCalendarView(model: calendar) {
                    showsSettings = true
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .fixedSize()
        .animation(.snappy(duration: 0.22), value: showsSettings)
        .onChange(of: clock.now, initial: true) { _, newValue in
            calendar.refresh(now: newValue)
        }
    }
}
