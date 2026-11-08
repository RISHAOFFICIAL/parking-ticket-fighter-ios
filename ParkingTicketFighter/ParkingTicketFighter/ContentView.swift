import SwiftUI

/// Root tab structure, mirroring the approved flow's top level navigation:
/// Home, My Tickets, Add Ticket, More (resources).
/// Per the approved hi-fi notes, the tab bar is navigation only. Actions
/// that belong to a screen live on that screen, not in the tab bar.
struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            Tab("My Tickets", systemImage: "ticket.fill") {
                TicketListView()
            }
            Tab("Add Ticket", systemImage: "plus.circle.fill") {
                AddTicketView()
            }
            Tab("More", systemImage: "ellipsis.circle.fill") {
                MoreView()
            }
        }
        .tint(.forest)
    }
}

#Preview {
    ContentView()
}
