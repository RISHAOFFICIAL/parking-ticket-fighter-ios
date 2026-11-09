import SwiftUI

/// My Tickets. Every saved ticket with its status, sorted so the most
/// urgent contest deadline comes first, the same ordering rule the
/// fleet dashboard (S19) uses.
struct TicketListView: View {
    // Scaffold state: sample data stands in for saved records until
    // persistence ports from the web build in a later pass.
    private let tickets = SampleData.tickets.sorted {
        $0.contestDeadline < $1.contestDeadline
    }

    var body: some View {
        NavigationStack {
            Group {
                if tickets.isEmpty {
                    ContentUnavailableView(
                        "No tickets yet",
                        systemImage: "ticket",
                        description: Text("When one shows up, add it from the Add Ticket tab.")
                    )
                } else {
                    List(tickets) { ticket in
                        NavigationLink(value: ticket) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(ticket.number).font(.headline)
                                    Spacer()
                                    Text(ticket.status.rawValue)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                                Text("Zone \(ticket.zone), \(ticket.location)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.footnote)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .contentMargins(.bottom, 110)
                }
            }
            .navigationTitle("My Tickets")
            .navigationDestination(for: Ticket.self) { ticket in
                TicketDetailView(ticket: ticket)
            }
        }
    }
}

#Preview {
    TicketListView()
}
