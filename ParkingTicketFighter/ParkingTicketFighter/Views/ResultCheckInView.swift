import SwiftUI
import SwiftData

/// Result check-in (S15). At day 30 after filing, the app asks "Did
/// your letter arrive?" Dismissed shows a celebration screen with the
/// money saved. Upheld shows what is now owed and the deadline to pay
/// it, taken from the letter. Not yet snoozes the check-in by 2 weeks.
struct ResultCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket
    /// Lifetime money saved across all tickets, for the celebration.
    let lifetimeSaved: Double

    @State private var outcome: Outcome?
    @State private var owedText: String
    @State private var payDeadline: Date

    private enum Outcome {
        case dismissed
        case upheld
    }

    init(ticket: Ticket, lifetimeSaved: Double) {
        self.ticket = ticket
        self.lifetimeSaved = lifetimeSaved
        _owedText = State(initialValue: String(format: "%.2f", ticket.fineLater))
        _payDeadline = State(initialValue: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        switch outcome {
                        case .none:
                            questionPanel
                        case .dismissed:
                            dismissedPanel
                        case .upheld:
                            upheldPanel
                        }
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Your result")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var questionPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Ticket \(ticket.number)")
                Text("Did your letter arrive?")
                    .font(.briefHeadline(24, relativeTo: .title2))
                Text("Results come by mail, usually within about 30 days of filing.")
                    .font(.subheadline)
                    .foregroundStyle(.ink.opacity(0.7))
                AppPrimaryButton(title: "Dismissed", systemImage: "party.popper.fill") {
                    outcome = .dismissed
                }
                AppSecondaryButton(title: "Upheld", systemImage: "doc.text.fill") {
                    outcome = .upheld
                }
                AppSecondaryButton(title: "Not yet", systemImage: "clock.fill") {
                    ticket.resultCheckSnoozedUntil = Calendar.current.date(byAdding: .day, value: 14, to: Date())
                    try? modelContext.save()
                    Task { await NotificationManager.schedule(for: ticket) }
                    dismiss()
                }
                Text("Not yet snoozes this check by 2 weeks.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    private var dismissedPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Dismissed")
                Text("You won.")
                    .font(.briefTitle(30, relativeTo: .title))
                Text("Detroit dismissed ticket \(ticket.number). You saved \(Money.format(ticket.fineLater)).")
                    .font(.subheadline)
                Text("Lifetime saved: \(Money.format(lifetimeSaved + ticket.fineLater)).")
                    .font(.subheadline.weight(.semibold))
                AppPrimaryButton(title: "Done", systemImage: "checkmark") {
                    ticket.status = .dismissed
                    try? modelContext.save()
                    Task { await NotificationManager.schedule(for: ticket) }
                    dismiss()
                }
            }
        }
    }

    private var upheldPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Upheld")
                Text("Detroit upheld ticket \(ticket.number). Here is what the letter says you owe, and by when.")
                    .font(.subheadline)
                VStack(alignment: .leading, spacing: 4) {
                    Text("AMOUNT OWED")
                        .font(.caption.weight(.semibold))
                        .tracking(1.0)
                    TextField("45.00", text: $owedText)
                        .keyboardType(.decimalPad)
                        .font(.body)
                }
                DatePicker("Pay by", selection: $payDeadline, displayedComponents: .date)
                Text("Pay by that date so the ticket never becomes a bigger problem. The app will remind you 3 days before.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                AppPrimaryButton(title: "Save result", systemImage: "checkmark") {
                    let cleaned = owedText.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "$", with: "")
                    ticket.resultAmountOwed = Double(cleaned) ?? ticket.fineLater
                    ticket.resultPaymentDeadline = payDeadline
                    ticket.status = .upheld
                    try? modelContext.save()
                    Task { await NotificationManager.schedule(for: ticket) }
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    ResultCheckInView(ticket: SampleData.appFailureTicket, lifetimeSaved: 45.00)
        .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
