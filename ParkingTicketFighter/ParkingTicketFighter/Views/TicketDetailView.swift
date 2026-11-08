import SwiftUI

/// Ticket detail. Mirrors the tracking screen (S14): the facts, both
/// deadlines up front, the status timeline, the drafted statement (S8),
/// and the evidence checklist (S7). Read only in this scaffold: editing,
/// packet building, and the pay gate port in later passes.
struct TicketDetailView: View {
    let ticket: Ticket

    var body: some View {
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
        .background(Color.ivory.opacity(0.55))
        .navigationTitle(ticket.number)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The case check verdict (S6), on glass, with the reason in words.
    private var verdictPanel: some View {
        GlassPanel(tint: ticket.verdict.badgeTint) {
            VStack(alignment: .leading, spacing: 8) {
                GlassBadge(
                    text: ticket.verdict.rawValue,
                    systemImage: ticket.verdict.badgeIcon,
                    tint: ticket.verdict.badgeTint
                )
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
        IvoryCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Ticket facts").font(.headline)
                factRow("Issued", ticket.issueDate.formatted(date: .abbreviated, time: .shortened))
                factRow("Zone", ticket.zone)
                factRow("Location", ticket.location)
                factRow("Plate", ticket.plate)
                factRow("Code", ticket.code)
                factRow("City", ticket.city)
                factRow("You said", ticket.paidAnswer.rawValue)
            }
        }
    }

    /// Both deadlines up front, the rule from the case check screen (S6):
    /// the discount deadline and the contest deadline, with the step up.
    private var deadlinesCard: some View {
        IvoryCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Your deadlines").font(.headline)
                factRow("Pay \(Money.format(ticket.fineNow)) by", ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted))
                factRow("Contest by", ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))
                Text("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)). \(DetroitFacts.code821LateFeeNote)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if ticket.contestDeadlinePassed {
                    Text("This contest deadline has passed. The app shows what is owed now and the pay instructions path instead of the contest path.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.urgent)
                }
            }
        }
    }

    /// Status timeline (S14): Added, Packet built, Filed, Waiting on result.
    private var statementCard: some View {
        IvoryCard {
            VStack(alignment: .leading, spacing: 8) {
                Text("Status: \(ticket.status.rawValue)").font(.headline)
                if let filedDate = ticket.filedDate, let method = ticket.filedMethod {
                    Text("Filed \(filedDate.formatted(date: .abbreviated, time: .omitted)), \(method.rawValue).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(DetroitFacts.resultByMailNote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Divider()
                Text("Your statement (draft)").font(.headline)
                Text(ticket.statementDraft)
                    .font(.subheadline)
                Text("Sign only what is true. You can edit this in your own words before anything is filed.")
                    .font(.footnote.weight(.semibold))
            }
        }
    }

    private var evidenceCard: some View {
        IvoryCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Evidence checklist").font(.headline)
                ForEach(SampleData.evidenceChecklist, id: \.label) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        Label(item.label, systemImage: item.isDone ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(item.isDone ? Color.success : Color.primary)
                        Text(item.help)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    /// Where to file in Detroit, the exact routes from screen S12.
    private var filingCard: some View {
        IvoryCard {
            VStack(alignment: .leading, spacing: 6) {
                Text("Where to file in Detroit").font(.headline)
                ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                    factRow(route.title, route.detail)
                }
                factRow("Phone", DetroitFacts.phone)
                Text("Your packet is free during launch. In this scaffold no payment is processed and no card is stored.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func factRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .frame(width: 110, alignment: .leading)
            Text(value)
                .font(.subheadline)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetailView(ticket: SampleData.appFailureTicket)
    }
}
