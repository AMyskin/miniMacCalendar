import SwiftUI

struct HoverSymbolButton: View {
    let systemName: String
    var weight: Font.Weight = .semibold
    let help: String
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: weight))
                .foregroundStyle(.primary)
                .frame(width: 26, height: 26)
                .background {
                    if isHovering {
                        Circle().fill(.quaternary)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help(help)
        .onHover { isHovering = $0 }
    }
}
