import SwiftUI

/// asphalt-brown with a highway-sign orange accent
enum Theme {
    static let background = Color(red: 0.094, green: 0.078, blue: 0.055)
    static let accent = Color(red: 0.878, green: 0.478, blue: 0.18)
    static let ink = Color(red: 0.973, green: 0.937, blue: 0.886)
    static let cardBackground = Color(red: 0.165, green: 0.149, blue: 0.125)
    static let secondaryInk = Color(red: 0.816, green: 0.78, blue: 0.729)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 18
}

extension View {
    func themedBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
