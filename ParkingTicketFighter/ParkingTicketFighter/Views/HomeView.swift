import SwiftUI

/// Home. The front page. Mirrors the approved flow's Home states:
/// open tickets with money at risk up top, the lifetime money saved,
/// and the friendly empty state when there are no tickets yet.
///
/// Editorial Brief: the masthead is the newspaper nameplate at the
/// top, headlines are declarative serif, money and deadlines use
/// tabular numerals, deadlines are red marginalia, status is small
/// caps text. Paper white always. No glass, no rounded cards.
struct HomeView: View {
    // Scaffold state: sample data stands in for saved records until
    // persistence ports from the web build in a later pass.
    private let tickets = SampleData.tickets

    private var openTickets: [Ticket] {
        tickets.filter { $0.status.isOpen }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Masthead()

                        header

                        if tickets.isEmpty {
                            emptyState
                        } else {
                            summaryPanel
                            openTicketList
                        }
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("You paid. They ticketed you anyway.")
                .font(.briefHeadline(28, relativeTo: .title2))
            Text("Fight it in about 10 minutes.")
                .font(.subheadline)
                .foregroundStyle(.ink.opacity(0.7))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            BriefPanel {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No tickets yet. Good.")
                        .font(.briefHeadline(20, relativeTo: .title3))
                    Text("When one shows up, start here.")
                        .foregroundStyle(.ink.opacity(0.7))
                }
            }
            AppPrimaryButton(title: "Add a ticket", systemImage: "plus") {}
        }
    }

    /// Money at risk and the nearest deadline, on a brief panel with
    /// a thick black top rule. The amount is large serif with tabular
    /// numerals. The deadline is red marginalia.
    private var summaryPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Money at risk")
                Text(Money.format(SampleData.totalAtRisk))
                    .font(.briefTitle(40, relativeTo: .largeTitle))
                    .monospacedDigit()
                if let next = openTickets.min(by: { $0.contestDeadline < $1.contestDeadline }) {
                    DeadlineCaps(text: "Contest by \(next.contestDeadline.formatted(date: .abbreviated, time: .omitted)) for ticket \(next.number)")
                }
                Text("\(openTickets.count) open ticket(s). Filing freezes penalties while you wait on a result.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    private var openTicketList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Kicker(text: "Open tickets")
                .padding(.bottom, 8)
            ForEach(openTickets) { ticket in
                NavigationLink(value: ticket) {
                    TicketRow(ticket: ticket)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationDestination(for: Ticket.self) { ticket in
            TicketDetailView(ticket: ticket)
        }
    }
}

/// One ticket row: number, zone, verdict in small caps, contest
/// deadline in red. Ruled with a hairline below it. Verdicts carry
/// words, never color alone, and never a pill.
struct TicketRow: View {
    let ticket: Ticket

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text(ticket.number)
                        .font(.briefHeadline(20, relativeTo: .title3))
                    Spacer()
                    StatusCaps(text: ticket.verdict.rawValue)
                }
                Text("Zone \(ticket.zone), \(ticket.location). Issued \(ticket.issueDate.formatted(date: .abbreviated, time: .shortened)).")
                    .font(.subheadline)
                    .foregroundStyle(.ink.opacity(0.7))
                HStack(spacing: 6) {
                    DeadlineCaps(text: "Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                    Text("or the fine steps up to \(Money.format(ticket.fineLater)).")
                        .font(.footnote.weight(.medium))
                }
            }
            .padding(.vertical, 12)
            Divider()
                .background(Color.ink.opacity(0.2))
        }
    }
}

#Preview {
    HomeView()
}
