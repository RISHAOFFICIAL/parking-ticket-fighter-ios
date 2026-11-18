import SwiftUI
import SwiftData

/// Case check (S6). The full verdict with the reason in plain words
/// and both deadlines up front. For a Weak verdict, the honest advice
/// screen: the math of paying the discounted amount versus contesting
/// and risking more, with "Pay it (we show you where)" and
/// "Contest anyway." The app never blocks a user from filing.
///
/// Guidance only, not legal advice. The app never promises a dismissal.
struct CaseCheckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket

    @State private var showingPaySheet = false
    @State private var showingDefenseChecker = false
    @State private var showingEvidence = false
    @State private var paidJustNow = false

    private var check: CaseCheckResult {
        CaseCheck.evaluate(ticket)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        verdictPanel
                        deadlinesPanel
                        if ticket.verdict == .weak {
                            honestAdvicePanel
                        } else if let gap = check.topGap {
                            gapPanel(gap)
                        }
                        actionsPanel
                        Text("Guidance only, not legal advice. The app never promises a dismissal, and it never files anything for you.")
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Case check")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaySheet) {
                PayInstructionsView(ticket: ticket, onPaid: {
                    paidJustNow = true
                    showingPaySheet = false
                })
            }
            .sheet(isPresented: $showingDefenseChecker) {
                DefenseCheckerView(ticket: ticket)
            }
            .sheet(isPresented: $showingEvidence) {
                NavigationStack {
                    EvidenceChecklistView(ticket: ticket)
                }
            }
            .onAppear {
                ticket.refreshVerdict()
                try? modelContext.save()
            }
        }
    }

    private var verdictPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Case check, ticket \(ticket.number)")
                StatusCaps(text: ticket.verdict.rawValue)
                Text(check.reason)
                    .font(.subheadline)
            }
        }
    }

    /// Both deadlines up front, the rule from the case check screen.
    private var deadlinesPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your deadlines")
                DeadlineCaps(text: "Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted))")
                DeadlineCaps(text: "Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                Text("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)).")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    private func gapPanel(_ gap: String) -> some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "What would make it stronger")
                Text(gap)
                    .font(.subheadline)
            }
        }
    }

    /// The honest weak case advice: pay the discounted amount by the
    /// discount date versus contesting and risking $45 plus late fees.
    private var honestAdvicePanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "The honest math")
                Text("Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted)) and this ticket is done. That rate is only for Detroit residents with a plate registered in the City's Detroit Discount program.")
                    .font(.subheadline)
                Text("Contest it and risk \(Money.format(ticket.fineLater)) plus late fees if Detroit upholds it. \(DetroitFacts.code821LateFeeNote)")
                    .font(.subheadline)
                AppPrimaryButton(title: "Pay it (we show you where)", systemImage: "dollarsign.circle.fill") {
                    showingPaySheet = true
                }
                AppSecondaryButton(title: "Contest anyway", systemImage: "checkmark.shield.fill") {
                    showingEvidence = true
                }
                Text("Contesting anyway continues with eyes open. The app never blocks you from filing.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    private var actionsPanel: some View {
        VStack(spacing: 12) {
            if ticket.verdict != .weak {
                AppPrimaryButton(title: "Continue to evidence", systemImage: "folder.fill") {
                    showingEvidence = true
                }
            }
            if ticket.paidAnswer == .didNotPay && ticket.defenseEvidence.isEmpty {
                AppSecondaryButton(title: "Check for other defenses", systemImage: "magnifyingglass") {
                    showingDefenseChecker = true
                }
            }
            if paidJustNow {
                Text("Marked as paid. The ticket is closed and its reminders are off.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.ink)
            }
        }
    }
}

/// Where to pay a ticket in Detroit, shown from the weak case screen.
/// Paying is the user's own step; the app only shows where. Marking
/// paid closes the ticket and cancels its reminders.
private struct PayInstructionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket
    var onPaid: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                Kicker(text: "Pay ticket \(ticket.number)")
                                Text("Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted)) to keep the discounted rate. That rate is only for Detroit residents with a plate registered in the City's Detroit Discount program.")
                                    .font(.subheadline)
                                Text("After the discount date the fine is \(Money.format(ticket.fineLater)).")
                                    .font(.subheadline)
                            }
                        }
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 0) {
                                Kicker(text: "Where to pay")
                                    .padding(.bottom, 8)
                                RuledRow(label: "Online") {
                                    Text("parkdetroit.us").font(.subheadline)
                                }
                                RuledRow(label: "By phone") {
                                    Text(DetroitFacts.phone).font(.subheadline)
                                }
                                RuledRow(label: "In person") {
                                    Text(DetroitFacts.inPersonAddress).font(.subheadline)
                                }
                                Link("Register your plate in the Detroit Discount program", destination: URL(string: "https://prdwmq.etimspayments.com/pbw/include/detroit/discount_request.jsp")!)
                                    .font(.subheadline)
                                    .padding(.top, 8)
                                Text("Registering does not contest a ticket. It is for paying one at half price, and it is the City's program, not the app's.")
                                    .font(.footnote)
                                    .foregroundStyle(.ink.opacity(0.7))
                                    .padding(.top, 4)
                            }
                        }
                        AppPrimaryButton(title: "I paid it", systemImage: "checkmark.circle.fill") {
                            ticket.status = .paid
                            try? modelContext.save()
                            Task { await NotificationManager.schedule(for: ticket) }
                            onPaid()
                        }
                        Text("Tap 'I paid it' only after you have paid. It closes the ticket and turns its reminders off.")
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Pay it")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CaseCheckView(ticket: SampleData.appFailureTicket)
        .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
