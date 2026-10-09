import Foundation
import SwiftUI

struct SettingsView: View {
    @Bindable var model: SettingsViewModel
    var now: Date
    var onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            preview
            settingGroup("Формат") {
                Picker("Формат", selection: $model.preset) {
                    ForEach(ClockFormatPreset.allCases) { preset in
                        Text(preset.title).tag(preset)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if model.usesCustomFormat {
                settingGroup("Свой формат") {
                    TextField("EEE, d MMM HH:mm", text: $model.customFormat)
                        .textFieldStyle(.roundedBorder)
                    Text("Например: EEE, d MMM HH:mm. Секунды и 12/24 задаются символами шаблона.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                settingGroup("Время") {
                    Picker("Время", selection: $model.hourCycle) {
                        ForEach(HourCyclePreference.allCases) { cycle in
                            Text(cycle.title).tag(cycle)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Toggle("Секунды", isOn: $model.showSeconds)
                }
            }

            settingGroup("Язык") {
                Picker("Язык", selection: $model.localePreference) {
                    ForEach(FormatLocalePreference.allCases) { preference in
                        Text(preference.title).tag(preference)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Divider()

            Button("Завершить", role: .destructive, action: model.quit)
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(16)
        .frame(width: 308)
    }

    private var header: some View {
        HStack(spacing: 8) {
            HoverSymbolButton(systemName: "chevron.left", help: "Назад", action: onBack)
            Text("Настройки")
                .font(.headline)
            Spacer()
        }
    }

    private var preview: some View {
        Text(model.previewText(at: now))
            .font(.title3)
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.quaternary.opacity(0.7))
            }
            .accessibilityLabel("Пример: \(model.previewText(at: now))")
    }

    private func settingGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            content()
        }
    }
}

#Preview("Settings") {
    let defaults = UserDefaults(suiteName: "miniCalendar.preview.settings") ?? .standard
    SettingsView(model: SettingsViewModel(store: SettingsStore(defaults: defaults)), now: Date()) {}
        .padding()
}
