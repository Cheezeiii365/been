import SwiftUI

// MARK: - Wandr Design System — iOS 26 Liquid Glass
enum WandrTheme {

    // MARK: - Accent & Brand Colors
    static let accentTeal = Color(hex: "0EA5E9")
    static let accentIndigo = Color(hex: "6366F1")
    static let accentViolet = Color(hex: "8B5CF6")
    static let accentAmber = Color(hex: "F59E0B")
    static let accentEmerald = Color(hex: "34D399")
    static let accentRose = Color(hex: "FB7185")
    static let accentRed = Color(hex: "EF4444")
    static let accentSky = Color(hex: "38BDF8")

    // MARK: - Semantic Text (adaptive for light/dark + glass readability)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(hex: "8E8E93")

    // MARK: - Trip Purpose Colors
    static func purposeColor(_ purpose: TripPurpose) -> Color {
        switch purpose {
        case .leisure: return accentTeal
        case .business: return accentIndigo
        case .tour: return accentViolet
        case .relocation: return accentAmber
        case .layover: return textTertiary
        case .digitalNomad: return accentEmerald
        case .familyVisit: return accentRose
        case .conference: return accentIndigo
        case .adventure: return accentAmber
        }
    }

    // MARK: - Mesh Gradient Backgrounds
    /// Rich ocean-to-sky gradient — the "world behind the glass"
    static func meshBackground() -> some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Color(hex: "0C1445"), Color(hex: "0F2167"), Color(hex: "1A1050"),
                Color(hex: "062E5C"), Color(hex: "0B4F8A"), Color(hex: "1D2B6B"),
                Color(hex: "031B35"), Color(hex: "093553"), Color(hex: "0D1B3E")
            ]
        )
        .ignoresSafeArea()
    }

    /// Warm variant for Stats / Passport views
    static func warmMeshBackground() -> some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                Color(hex: "1A0A2E"), Color(hex: "2D1066"), Color(hex: "1A1050"),
                Color(hex: "16213E"), Color(hex: "1B3A5C"), Color(hex: "2A1B5E"),
                Color(hex: "0A1628"), Color(hex: "0E2444"), Color(hex: "170D38")
            ]
        )
        .ignoresSafeArea()
    }

    // MARK: - Gradients
    static let heroGradient = LinearGradient(
        colors: [accentTeal, accentIndigo],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let warmGradient = LinearGradient(
        colors: [accentViolet, accentRose],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // MARK: - Spacing (8pt grid)
    static let spacingXS: CGFloat = 4
    static let spacingSM: CGFloat = 8
    static let spacingMD: CGFloat = 16
    static let spacingLG: CGFloat = 24
    static let spacingXL: CGFloat = 32

    // MARK: - Corner Radius
    static let radiusSM: CGFloat = 10
    static let radiusMD: CGFloat = 14
    static let radiusLG: CGFloat = 20
    static let radiusXL: CGFloat = 28
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

// MARK: - Liquid Glass View Modifiers
struct GlassCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(WandrTheme.spacingMD)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}

struct GlassCardDenseStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(WandrTheme.spacingSM)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: WandrTheme.radiusSM))
    }
}

struct GlassPillStyle: ViewModifier {
    var isActive: Bool = false
    var activeColor: Color = WandrTheme.accentTeal

    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background {
                if isActive {
                    Capsule().fill(activeColor)
                } else {
                    Capsule().fill(.ultraThinMaterial)
                }
            }
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardStyle())
    }

    func glassCardDense() -> some View {
        modifier(GlassCardDenseStyle())
    }

    func glassPill(isActive: Bool = false, activeColor: Color = WandrTheme.accentTeal) -> some View {
        modifier(GlassPillStyle(isActive: isActive, activeColor: activeColor))
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
