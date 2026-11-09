import SwiftUI

/// My Tickets. Every saved ticket with its status, sorted so the most
/// urgent contest deadline comes first, the same ordering rule the
/// fleet dashboard (S19) uses.
///
/// Editorial Brief: ruled rows with hairline rules, ticket numbers in
/// serif, deadlines in red, status in small caps. Paper white always.
struct TicketListView: View {
    // Scaffold state: sample data stands in for saved records until
    // persistence ports from the web build in a later pass.
    private let tickets = SampleData.tickets.sorted {
        $0.contestDeadline < $1.contestDeadline
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
                            ForEach(tickets) { ticket in
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
}
