import SwiftUI

/// Reusable components, per Apple's Human Interface Guidelines.
///
/// HIG rule, verified against the Tab Bars and Sign in with Apple pages
/// and the component pages (Buttons, Navigation, Lists, Text Fields,
/// Materials, Typography, Color): Liquid Glass belongs only in the
/// functional layer (the tab bar, toolbars, nav bars, sheets, alerts).
/// A button or card sitting in content uses a standard solid style, not
/// glass. So the tab bar is glass, and everything on a screen is solid.
/// This also matches the app's Editorial Brief direction (no glass in
/// content). The brand palette (forest, ivory, brass) and the solid
/// ivory cards stay, because they are the approved brand, not glass.
enum AppTheme {
    /// Deep forest green, the primary brand color from the approved hi-fi.
    /// Contrast on ivory is 9.92:1, well above the 4.5:1 minimum.
    static let forest = Color(red: 0.11, green: 0.27, blue: 0.20)
    /// Warm ivory, the app background.
    static let ivory = Color(red: 0.98, green: 0.96, blue: 0.92)
    /// Brass, the accent for deadlines and money saved. Used only as a
    /// background tint, never as text: brass on ivory is 3.17:1, below
    /// the 4.5:1 minimum for normal text.
    static let brass = Color(red: 0.66, green: 0.52, blue: 0.24)
    /// Clear red, reserved for urgent deadline flags only.
    /// Contrast on ivory is 5.19:1.
    static let urgent = Color(red: 0.75, green: 0.20, blue: 0.16)
    /// Clear green for strong cases and dismissed results.
    /// Contrast on ivory is 4.87:1.
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

/// Primary action button, solid forest.
/// Per HIG, a button in content uses a standard style, not glass.
/// Used for the one main action on a screen, like "Fight a ticket".
/// Minimum height follows the approved 44 point touch target rule.
struct AppPrimaryButton: View {
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
        .buttonStyle(.borderedProminent)
        .tint(.forest)
        .controlSize(.large)
    }
}

/// Secondary action button, standard bordered style.
/// Pairs with AppPrimaryButton. Minimum height follows the 44 point
/// touch target rule.
struct AppSecondaryButton: View {
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
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}

/// The two button pair used on Welcome (S1) and the pay panel (S11):
/// one primary action, one secondary.
struct AppButtonPair: View {
    let primaryTitle: String
    let secondaryTitle: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            AppPrimaryButton(title: primaryTitle, action: primaryAction)
            AppSecondaryButton(title: secondaryTitle, action: secondaryAction)
        }
    }
}

// MARK: - Cards and panels

/// A content card. Content cards stay solid ivory for legibility,
/// per the HIG rule that glass is not used in the content layer.
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

/// A small solid pill used for verdicts and statuses. The label always
/// pairs an icon with words, so color is never the only signal. The
/// text stays dark on a light tint wash, so it meets the 4.5:1 contrast
/// minimum even for the brass tint, which is too light to use as text.
struct StatusBadge: View {
    let text: String
    let systemImage: String
    var tint: Color = .forest

    var body: some View {
        Label(text, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.15), in: .capsule)
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
            AppButtonPair(
                primaryTitle: "Fight a ticket",
                secondaryTitle: "I run vehicles for a business",
                primaryAction: {},
                secondaryAction: {}
            )
            IvoryCard {
                Text("Strong case").font(.headline)
            }
            StatusBadge(text: "Worth filing", systemImage: "doc.text.magnifyingglass", tint: .brass)
        }
        .padding()
    }
}
