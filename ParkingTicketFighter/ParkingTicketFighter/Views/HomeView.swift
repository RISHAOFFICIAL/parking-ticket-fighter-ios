import SwiftUI

/// Home. Mirrors the approved flow's Home states:
/// open tickets with money at risk up top, the lifetime money saved,
/// and the friendly empty state when there are no tickets yet
/// ("No tickets yet. Good. When one shows up, start here.").
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
                Color.ivory.opacity(0.55).ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
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
                .contentMargins(.bottom, 110)
            }
            .navigationTitle("Parking Ticket Fighter")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Got a parking ticket you already paid for?")
                .font(.title2.weight(.bold))
            Text("Fight it in about 10 minutes.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            IvoryCard {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: "car.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.forest)
                    Text("No tickets yet. Good.")
                        .font(.headline)
                    Text("When one shows up, start here.")
                        .foregroundStyle(.secondary)
                }
            }
            GlassPrimaryButton(title: "Add a ticket", systemImage: "plus") {}
        }
    }

    /// Money at risk and the nearest deadline, on a glass panel because
    /// this is one of the key summary moments in the approved design.
    private var summaryPanel: some View {
        GlassPanel(tint: .brass) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Money at risk", systemImage: "exclamationmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                Text(Money.format(SampleData.totalAtRisk))
                    .font(.largeTitle.weight(.bold))
                if let next = openTickets.min(by: { $0.contestDeadline < $1.contestDeadline }) {
                    Text("Next contest deadline: \(next.contestDeadline.formatted(date: .abbreviated, time: .omitted)) for ticket \(next.number).")
                        .font(.footnote)
                }
                Text("\(openTickets.count) open ticket(s). Filing freezes penalties while you wait on a result.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var openTicketList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Open tickets")
                .font(.headline)
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

/// One ticket row: number, zone, verdict badge, contest deadline.
/// Verdicts carry an icon and words, never color alone.
struct TicketRow: View {
    let ticket: Ticket

    var body: some View {
        IvoryCard {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(ticket.number)
                        .font(.headline)
                    Spacer()
                    GlassBadge(
                        text: ticket.verdict.rawValue,
                        systemImage: ticket.verdict.badgeIcon,
                        tint: ticket.verdict.badgeTint
                    )
                }
                Text("Zone \(ticket.zone), \(ticket.location). Issued \(ticket.issueDate.formatted(date: .abbreviated, time: .shortened)).")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                    Text("Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                    Text("or the fine steps up to \(Money.format(ticket.fineLater)).")
                }
                .font(.footnote.weight(.medium))
                .foregroundStyle(ticket.contestDeadlinePassed ? Color.urgent : Color.primary)
            }
        }
    }
}

#Preview {
    HomeView()
}
