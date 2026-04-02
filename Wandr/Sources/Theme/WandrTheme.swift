import SwiftUI

// Flighty-inspired dark theme with aviation aesthetics
enum WandrTheme {
    // MARK: - Primary Colors
    static let background = Color(hex: "0A0E1A")
    static let surfacePrimary = Color(hex: "111827")
    static let surfaceSecondary = Color(hex: "1A2332")
    static let surfaceTertiary = Color(hex: "243044")

    // MARK: - Accent Colors
    static let accentBlue = Color(hex: "3B82F6")
    static let accentCyan = Color(hex: "06B6D4")
    static let accentPurple = Color(hex: "8B5CF6")
    static let accentGreen = Color(hex: "10B981")
    static let accentOrange = Color(hex: "F59E0B")
    static let accentRed = Color(hex: "EF4444")
    static let accentPink = Color(hex: "EC4899")

    // MARK: - Text Colors
    static let textPrimary = Color(hex: "F9FAFB")
    static let textSecondary = Color(hex: "9CA3AF")
    static let textTertiary = Color(hex: "6B7280")
    static let textAccent = accentCyan

    // MARK: - Gradients
    static let heroGradient = LinearGradient(
        colors: [accentBlue, accentCyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardGradient = LinearGradient(
        colors: [surfaceSecondary, surfaceTertiary],
        startPoint: .top,
        endPoint: .bottom
    )

    static let mapGradient = LinearGradient(
        colors: [accentCyan.opacity(0.6), accentBlue.opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let purpleGradient = LinearGradient(
        colors: [accentPurple, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Trip Purpose Colors
    static func purposeColor(_ purpose: TripPurpose) -> Color {
        switch purpose {
        case .leisure: return accentCyan
        case .business: return accentBlue
        case .tour: return accentPurple
        case .relocation: return accentOrange
        case .layover: return textTertiary
        case .digitalNomad: return accentGreen
        case .familyVisit: return accentPink
        case .conference: return accentBlue
        case .adventure: return accentOrange
        }
    }

    // MARK: - Spacing
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius
    static let radiusSM: CGFloat = 8
    static let radiusMD: CGFloat = 12
    static let radiusLG: CGFloat = 16
    static let radiusXL: CGFloat = 24

    // MARK: - Typography helpers
    static let monoFont = "SF Mono"
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct WandrCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(WandrTheme.spacingMD)
            .background(WandrTheme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}

struct WandrGlassStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(WandrTheme.spacingMD)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}

extension View {
    func wandrCard() -> some View {
        modifier(WandrCardStyle())
    }

    func wandrGlass() -> some View {
        modifier(WandrGlassStyle())
    }
}

// MARK: - Date Formatting
extension Date {
    var shortFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }

    var dayMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: self)
    }

    var fullFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: self)
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
