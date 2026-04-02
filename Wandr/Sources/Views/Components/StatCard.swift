import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let color: Color

    init(title: String, value: String, subtitle: String? = nil, icon: String, color: Color = WandrTheme.accentCyan) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: WandrTheme.spacingSM) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(WandrTheme.textPrimary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(WandrTheme.textSecondary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(WandrTheme.textTertiary)
                }
            }
        }
        .padding(WandrTheme.spacingMD)
        .background(WandrTheme.surfaceSecondary)
        .clipShape(RoundedRectangle(cornerRadius: WandrTheme.radiusMD))
    }
}

struct MiniStatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(WandrTheme.textTertiary)
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}
