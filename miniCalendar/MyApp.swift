import SwiftUI

@main
struct MyApp: App {
    @State private var appModel = AppModel()

    var body: some Scene {
        MenuBarExtra {
            CalendarPopoverView(
                clock: appModel.clock,
                calendar: appModel.calendar,
                settings: appModel.settings
            )
        } label: {
            MenuBarClockLabel(model: appModel.clock)
        }
        .menuBarExtraStyle(.window)
    }
}

final class AppModel {
    let clock: MenuBarClockViewModel
    let calendar: CalendarViewModel
    let settings: SettingsViewModel

    init() {
        let store = SettingsStore()
        clock = MenuBarClockViewModel(settings: store)
        calendar = CalendarViewModel(settings: store)
        settings = SettingsViewModel(store: store)
    }
}

private struct MenuBarClockLabel: View {
    var model: MenuBarClockViewModel

    var body: some View {
        Text(model.title)
            .monospacedDigit()
            .fixedSize()
    }
}
