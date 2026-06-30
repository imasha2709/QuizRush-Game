import SwiftUI

// Declare this EXACTLY ONCE for the whole project
struct Card: Identifiable {
    let id = UUID()
    var isLit: Bool = false
    var emoji: String = "❓"
}

// Declare this EXACTLY ONCE for the whole project
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
