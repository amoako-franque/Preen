import SwiftUI

enum PreenIcons {
    static let dashboard = "gauge.with.dots.needle.67percent"
    static let clean = "trash.circle"
    static let apps = "app.badge"
    static let optimize = "bolt.circle"
    static let analyze = "chart.bar.doc.horizontal"
    static let settings = "gearshape"
    static let safe = "checkmark.shield"
    static let caution = "exclamationmark.triangle"
    static let danger = "xmark.octagon"
    static let helper = "wrench.and.screwdriver"
    static let sparkline = "waveform.path.ecg"
}

enum PreenColors {
    static let background = Color("Background")
    static let surface = Color("Surface")
    static let accent = Color.accentColor
    static let safe = Color("SafeGreen")
    static let caution = Color("CautionOrange")
    static let danger = Color("DangerRed")
    static let secondaryText = Color.secondary
}

enum PreenTypography {
    static let largeTitle = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let title = Font.system(.title2, design: .rounded).weight(.semibold)
    static let body = Font.system(.body, design: .default)
    static let caption = Font.system(.caption, design: .default)
}

enum PreenSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

#Preview("Design System Tokens") {
    VStack(alignment: .leading, spacing: PreenSpacing.md) {
        Label("Dashboard", systemImage: PreenIcons.dashboard)
        Label("Safe", systemImage: PreenIcons.safe).foregroundStyle(PreenColors.safe)
        Label("Caution", systemImage: PreenIcons.caution).foregroundStyle(PreenColors.caution)
        Label("Danger", systemImage: PreenIcons.danger).foregroundStyle(PreenColors.danger)
    }
    .padding()
    .frame(width: 320, height: 200)
}
