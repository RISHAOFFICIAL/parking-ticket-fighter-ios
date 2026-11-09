import SwiftUI

/// Editorial Brief theme and components.
///
/// Chosen by Risha November 2, 2026. The app reads as a legal brief
/// crossed with a broadsheet newspaper. Stark, serious, credible.
/// Paper white backgrounds, ink black text and rules, one accent only:
/// signal red, reserved for deadlines, money at risk, and urgent flags.
/// No gradients, no glass, no blur, no shadows, no brass, no forest
/// green. Flat matte ink on paper. Buttons are solid black rectangles
/// with white text and square corners. Status is small caps text, not
/// pills. Deadlines are red marginalia, not badges. The theme is
/// locked to light (paper white always, even in device dark mode).
enum AppTheme {
    /// Paper white, the only background. #ffffff.
    static let paper = Color(red: 1.0, green: 1.0, blue: 1.0)
    /// Ink black, text and rules. #111111.
    static let ink = Color(red: 0.067, green: 0.067, blue: 0.067)
    /// Signal red, the one accent. #c8102e. Deadlines, money at risk,
    /// and urgent flags only. Never used as body text.
    static let signal = Color(red: 0.784, green: 0.063, blue: 0.180)
}

extension Color {
    static let paper = AppTheme.paper
    static let ink = AppTheme.ink
    static let signal = AppTheme.signal
}

/// The same brand colors as ShapeStyle, so they work in
/// `.foregroundStyle(.ink)` and other shape positions.
extension ShapeStyle where Self == Color {
    static var paper: Color { AppTheme.paper }
    static var ink: Color { AppTheme.ink }
    static var signal: Color { AppTheme.signal }
}

// MARK: - Typography

extension Font {
    /// Sharp serif headline (Georgia), scales with Dynamic Type.
    static func briefHeadline(_ size: CGFloat = 28, relativeTo: TextStyle = .title2) -> Font {
        .custom("Georgia", size: size, relativeTo: relativeTo).weight(.bold)
    }
    /// Serif title, for the masthead and large headlines.
    static func briefTitle(_ size: CGFloat = 34, relativeTo: TextStyle = .largeTitle) -> Font {
        .custom("Georgia", size: size, relativeTo: relativeTo).weight(.bold)
    }
}

/// A small caps kicker with letterspacing, for section and screen
/// labels, e.g. "THE BRIEF".
struct Kicker: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.5)
            .foregroundStyle(.ink)
    }
}

/// Status stated in small caps text, never a pill or chip,
/// e.g. "FILED, WAITING ON RESULT".
struct StatusCaps: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .tracking(1.0)
            .foregroundStyle(.ink)
    }
}

/// A deadline as red marginalia: bold red, never a soft badge,
/// e.g. "CONTEST BY NOV 8".
struct DeadlineCaps: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.footnote.weight(.bold))
            .tracking(0.5)
            .foregroundStyle(.signal)
    }
}

// MARK: - Buttons

/// Primary action button: a solid black rectangle with white text and
/// square corners. Used for the one main action on a screen.
/// Minimum height follows the 44 point touch target rule.
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
            .background(Color.ink)
            .foregroundStyle(.white)
            .cornerRadius(0)
        }
        .buttonStyle(.plain)
    }
}

/// Secondary action button: white with a 1px ink border and ink text,
/// square corners. Pairs with AppPrimaryButton.
/// Minimum height follows the 44 point touch target rule.
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
            .background(Color.paper)
            .foregroundStyle(.ink)
            .overlay(
                Rectangle()
                    .strokeBorder(Color.ink, lineWidth: 1)
            )
            .cornerRadius(0)
        }
        .buttonStyle(.plain)
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

// MARK: - Panels and rows

/// A brief panel: paper white with a thick black top rule (6px) and
/// square corners. Used for the major panels and the masthead.
/// Content sits on paper, never on glass.
struct BriefPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.ink)
                .frame(height: 6)
            content
                .padding(16)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.paper)
        .overlay(
            Rectangle()
                .strokeBorder(Color.ink.opacity(0.15), lineWidth: 1)
        )
    }
}

/// A ruled row: a two column labeled row with a hairline rule below it.
/// Used for ticket facts and filing routes, the case brief layout.
struct RuledRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 110, alignment: .leading)
                content
                Spacer()
            }
            .padding(.vertical, 8)
            Divider()
                .background(Color.ink.opacity(0.2))
        }
    }
}

/// The app masthead: a newspaper nameplate, "PARKING TICKET FIGHTER"
/// in letterspaced serif caps, with a thick black rule below it.
struct Masthead: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PARKING TICKET FIGHTER")
                .font(.briefTitle(26, relativeTo: .title2))
                .tracking(1.0)
                .foregroundStyle(.ink)
            Rectangle()
                .fill(Color.ink)
                .frame(height: 6)
        }
    }
}

/// Money formatting used across the app: $22.50, $45.00.
/// Tabular numerals so figures align in columns.
enum Money {
    static func format(_ value: Double) -> String {
        value.formatted(.currency(code: "USD"))
    }
}

#Preview {
    ZStack {
        Color.paper.ignoresSafeArea()
        VStack(spacing: 16) {
            Masthead()
            BriefPanel {
                VStack(alignment: .leading, spacing: 8) {
                    Kicker(text: "Money at risk")
                    Text(Money.format(135))
                        .font(.briefTitle(34, relativeTo: .largeTitle))
                        .monospacedDigit()
                    DeadlineCaps(text: "Contest by Nov 5, 2026")
                    StatusCaps(text: "Filed, waiting on result")
                }
            }
            AppButtonPair(
                primaryTitle: "Fight a ticket",
                secondaryTitle: "I run vehicles for a business",
                primaryAction: {},
                secondaryAction: {}
            )
        }
        .padding()
    }
}
