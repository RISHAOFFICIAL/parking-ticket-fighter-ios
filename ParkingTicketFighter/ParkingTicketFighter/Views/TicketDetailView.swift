import SwiftUI

/// Ticket detail. Mirrors the tracking screen (S14): the facts, both
/// deadlines up front, the status timeline, the drafted statement (S8),
/// and the evidence checklist (S7). Read only in this scaffold: editing,
/// packet building, and the pay gate port in later passes.
///
/// Editorial Brief: the detail reads as a case brief. Labeled fields
/// in ruled two column rows, deadlines as red marginalia, status in
/// small caps text. Paper white always.
struct TicketDetailView: View {
    let ticket: Ticket

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    verdictPanel
                    factsCard
                    deadlinesCard
                    statementCard
                    evidenceCard
                    filingCard
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle(ticket.number)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The case check verdict (S6), on a brief panel with a thick top
    /// rule. The verdict is small caps ink text, with the reason in words.
    private var verdictPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Case check")
                StatusCaps(text: ticket.verdict.rawValue)
                Text(verdictReason)
                    .font(.subheadline)
            }
        }
    }

    private var verdictReason: String {
        switch ticket.verdict {
        case .strong:
            return "You paid, and the time and zone line up. Tickets like this get dismissed when the proof is filed right."
        case .worthFiling:
            return "Your proof is partial. The evidence checklist below shows what would make it stronger."
        case .weak:
            return "Honest answer: this one is unlikely to be dismissed. Paying the discounted amount by the discount date may cost less than contesting, if you live in Detroit and your plate is registered in the City's Detroit Discount program."
        }
    }

    private var factsCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Ticket facts")
                    .padding(.bottom, 8)
                RuledRow(label: "Issued") {
                    Text(ticket.issueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                }
                RuledRow(label: "Zone") {
                    Text(ticket.zone).font(.subheadline)
                }
                RuledRow(label: "Location") {
                    Text(ticket.location).font(.subheadline)
                }
                RuledRow(label: "Plate") {
                    Text(ticket.plate).font(.subheadline)
                }
                RuledRow(label: "Code") {
                    Text(ticket.code).font(.subheadline)
                }
                RuledRow(label: "City") {
                    Text(ticket.city).font(.subheadline)
                }
                RuledRow(label: "You said") {
                    Text(ticket.paidAnswer.rawValue).font(.subheadline)
                }
            }
        }
    }

    /// Both deadlines up front, the rule from the case check screen (S6):
    /// the discount deadline and the contest deadline, with the step up.
    /// Deadlines are red marginalia.
    private var deadlinesCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your deadlines")
                DeadlineCaps(text: "Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted))")
                DeadlineCaps(text: "Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                Text("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)). \(DetroitFacts.code821LateFeeNote)")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                if ticket.contestDeadlinePassed {
                    Text("This contest deadline has passed. The app shows what is owed now and the pay instructions path instead of the contest path.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.signal)
                }
            }
        }
    }

    /// Status timeline (S14): Added, Packet built, Filed, Waiting on result.
    private var statementCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Status")
                StatusCaps(text: ticket.status.rawValue)
                if let filedDate = ticket.filedDate, let method = ticket.filedMethod {
                    Text("Filed \(filedDate.formatted(date: .abbreviated, time: .omitted)), \(method.rawValue).")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                    Text(DetroitFacts.resultByMailNote)
                        .font(.footnote)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                Divider()
                    .background(Color.ink.opacity(0.2))
                Kicker(text: "Your statement (draft)")
                Text(ticket.statementDraft)
                    .font(.subheadline)
                Text("Sign only what is true. You can edit this in your own words before anything is filed.")
                    .font(.footnote.weight(.semibold))
            }
        }
    }

    private var evidenceCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Evidence checklist")
                    .padding(.bottom, 8)
                ForEach(SampleData.evidenceChecklist, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label(item.label, systemImage: item.isDone ? "checkmark.square.fill" : "square")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.ink)
                            Text(item.help)
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                        .padding(.vertical, 8)
                        Divider()
                            .background(Color.ink.opacity(0.2))
                    }
                }
            }
        }
    }

    /// Where to file in Detroit, the exact routes from screen S12.
    private var filingCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Where to file in Detroit")
                    .padding(.bottom, 8)
                ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                    RuledRow(label: route.title) {
                        Text(route.detail).font(.subheadline)
                    }
                }
                RuledRow(label: "Phone") {
                    Text(DetroitFacts.phone).font(.subheadline)
                }
                Text("Your packet is free during launch. In this scaffold no payment is processed and no card is stored.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetailView(ticket: SampleData.appFailureTicket)
    }
}
