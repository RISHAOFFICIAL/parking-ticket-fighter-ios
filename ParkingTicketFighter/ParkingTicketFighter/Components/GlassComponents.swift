import SwiftUI

/// Reusable Liquid Glass components, per Risha's standing Apple design
/// rule (October 13, 2026): Apple platform apps use the glass effect
/// for buttons and other UI elements, using the iOS 26 glass APIs.
///
/// Per Apple Materials guidance carried in the approved hi-fi spec:
/// glass belongs on the functional layer (buttons, tab bar, toolbars,
/// floating actions, key verdict and pay panels), used sparingly.
/// Content stays on solid ivory cards so text stays legible. Critical
/// text never sits on unmodified glass without a legibility layer.
enum AppTheme {
    /// Deep forest green, the primary brand color from the approved hi-fi.
    static let forest = Color(red: 0.11, green: 0.27, blue: 0.20)
    /// Warm ivory, the app background.
    static let ivory = Color(red: 0.98, green: 0.96, blue: 0.92)
    /// Brass, the accent for deadlines and money saved.
    static let brass = Color(red: 0.66, green: 0.52, blue: 0.24)
    /// Clear red, reserved for urgent deadline flags only.
    static let urgent = Color(red: 0.75, green: 0.20, blue: 0.16)
    /// Clear green for strong cases and dismissed results.
    static let success = Color(red: 0.16, green: 0.48, blue: 0.28)
}

extension Color {
    static let forest = AppTheme.forest
    static let ivory = AppTheme.ivory
    static let brass = AppTheme.brass
    static let urgent = AppTheme.urgent
    static let success = AppTheme.success
}

/// The same brand colors as ShapeStyle, so they work in
/// `.foregroundStyle(.forest)` and other shape positions. A plain
/// `Color` extension is not enough there: `foregroundStyle` takes a
/// generic ShapeStyle, and the compiler only sees members defined on
/// ShapeStyle itself. This extension makes `.forest` and the rest
/// resolve in those positions too.
extension ShapeStyle where Self == Color {
    static var forest: Color { AppTheme.forest }
    static var ivory: Color { AppTheme.ivory }
    static var brass: Color { AppTheme.brass }
    static var urgent: Color { AppTheme.urgent }
    static var success: Color { AppTheme.success }
}

// MARK: - Buttons

/// Primary action button in Liquid Glass, tinted forest.
/// Used for the one main action on a screen, like "Fight a ticket".
/// Minimum height follows the approved 44 point touch target rule.
struct GlassPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .buttonStyle(.glassProminent)
        .tint(.forest)
        .controlSize(.large)
    }
}

/// Secondary action button in plain Liquid Glass, no tint.
/// Pairs with GlassPrimaryButton inside a GlassEffectContainer so the
/// two surfaces blend correctly where they sit close together.
struct GlassSecondaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
        .buttonStyle(.glass)
        .controlSize(.large)
    }
}

/// The two button pair used on Welcome (S1) and the pay panel (S11):
/// one primary action, one secondary, grouped in a glass container.
struct GlassButtonPair: View {
    let primaryTitle: String
    let secondaryTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            VStack(spacing: 12) {
                GlassPrimaryButton(title: primaryTitle, action: primaryAction)
                GlassSecondaryButton(title: secondaryTitle, action: secondaryAction)
            }
        }
    }
}

// MARK: - Cards and panels

/// A content card. Content cards stay solid ivory for legibility,
/// per the hi-fi rule that glass is not smeared over all content.
struct IvoryCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ivory, in: RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(.forest.opacity(0.12), lineWidth: 1)
            )
    }
}

/// A glass panel for the key moments the hi-fi reserves glass for:
/// the verdict on the case check (S6) and the pay panel (S11).
/// Text sits on the tinted glass with a strong tint so it stays legible.
struct GlassPanel<Content: View>: View {
    var tint: Color = .forest
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(
                .regular.tint(tint.opacity(0.22)).interactive(false),
                in: RoundedRectangle(cornerRadius: 24)
            )
    }
}

/// A small glass pill used for verdicts and statuses. The label always
/// pairs an icon with words, so color is never the only signal.
struct GlassBadge: View {
    let text: String
    let systemImage: String
    var tint: Color = .forest

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .glassEffect(.regular.tint(tint.opacity(0.25)), in: .capsule)
    }
}

extension CaseVerdict {
    var badgeTint: Color {
        switch self {
        case .strong: return .success
        case .worthFiling: return .brass
        case .weak: return .urgent
        }
    }

    var badgeIcon: String {
        switch self {
        case .strong: return "checkmark.shield.fill"
        case .worthFiling: return "doc.text.magnifyingglass"
        case .weak: return "exclamationmark.triangle.fill"
        }
    }
}

/// Money formatting used across the app: $22.50, $45.00.
enum Money {
    static func format(_ value: Double) -> String {
        value.formatted(.currency(code: "USD"))
    }
}

#Preview {
    ZStack {
        Color.ivory.ignoresSafeArea()
        VStack(spacing: 16) {
            GlassButtonPair(
                primaryTitle: "Fight a ticket",
                secondaryTitle: "I run vehicles for a business",
                primaryAction: {},
                secondaryAction: {}
            )
            GlassPanel(tint: .forest) {
                Text("Strong case").font(.headline)
            }
            GlassBadge(text: "Worth filing", systemImage: "doc.text.magnifyingglass", tint: .brass)
        }
        .padding()
    }
}
