import SwiftUI
import SwiftData

/// My Tickets. Every saved ticket with its status, sorted so the most
/// urgent contest deadline comes first, the same ordering rule the
/// fleet dashboard (S19) uses. Tickets come from the SwiftData store
/// (`@Query`), so adds and deletes show up here right away.
///
/// Editorial Brief: ruled rows with hairline rules, ticket numbers in
/// serif, deadlines in red, status in small caps. Paper white always.
struct TicketListView: View {
    @Query private var tickets: [Ticket]

    /// Most urgent contest deadline first. The contest deadline is
    /// computed from the issue date, so the sort happens here rather
    /// than in the query itself.
    private var sortedTickets: [Ticket] {
        tickets.sorted { $0.contestDeadline < $1.contestDeadline }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                if tickets.isEmpty {
                    VStack {
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("No tickets yet.")
                                    .font(.briefHeadline(20, relativeTo: .title3))
                                Text("When one shows up, add it from the Add Ticket tab.")
                                    .foregroundStyle(.ink.opacity(0.7))
                            }
                        }
                    }
                    .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(sortedTickets) { ticket in
                                NavigationLink(value: ticket) {
                                    TicketRow(ticket: ticket)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .contentMargins(.bottom, 16)
                }
            }
            .navigationTitle("My Tickets")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Ticket.self) { ticket in
                TicketDetailView(ticket: ticket)
            }
        }
    }
}

#Preview {
    TicketListView()
        .modelContainer(for: Ticket.self, inMemory: true)
}
