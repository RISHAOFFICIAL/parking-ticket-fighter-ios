import SwiftUI

/// Root tab structure, mirroring the approved flow's top level navigation:
/// Home, My Tickets, Add Ticket, More (resources).
///
/// Editorial Brief (chosen by Risha Nov 2, 2026): paper white, ink
/// black, signal red only for deadlines and money at risk. The tab bar
/// is a white bar with a black top rule and black text. The center
/// camera button is a solid black square with a white camera icon.
///
/// The tabs are switched manually (a ZStack with one visible tab),
/// not with a TabView. A TabView renders its own floating pill tab bar
/// in iOS 26, and hiding it left a white pill covering content. The
/// manual switch keeps each tab's NavigationStack alive, so navigation
/// state is preserved, and the custom tab bar sits in the layout flow
/// below the content (a VStack), so content can never hide behind it.
/// The theme is locked to light, paper white always, even in device
/// dark mode.
struct ContentView: View {
    enum AppTab: Hashable {
        case home, tickets, add, more
    }

    @State private var selectedTab: AppTab = .home

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HomeView()
                    .opacity(selectedTab == .home ? 1 : 0)
                    .disabled(selectedTab != .home)
                TicketListView()
                    .opacity(selectedTab == .tickets ? 1 : 0)
                    .disabled(selectedTab != .tickets)
                AddTicketView()
                    .opacity(selectedTab == .add ? 1 : 0)
                    .disabled(selectedTab != .add)
                MoreView()
                    .opacity(selectedTab == .more ? 1 : 0)
                    .disabled(selectedTab != .more)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            customTabBar
        }
        .tint(.ink)
        .preferredColorScheme(.light)
    }

    /// The bottom bar. A white bar with a black top rule and black text,
    /// per the Editorial Brief. Home and My Tickets on the left, More on
    /// the right, and the Add Ticket camera button as a solid black
    /// square in the exact center. Every tab keeps a short label under
    /// its icon. The selected tab is ink black; the others are a muted
    /// ink. The bar is in the layout flow, so it never covers content.
    private var customTabBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.ink)
                .frame(height: 1)
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(.home, title: "Home", systemImage: "house.fill")
                    tabButton(.tickets, title: "My Tickets", systemImage: "ticket.fill")
                }
                .frame(maxWidth: .infinity)
                centerCameraTab
                    .frame(maxWidth: .infinity)
                HStack(spacing: 0) {
                    tabButton(.more, title: "More", systemImage: "ellipsis.circle.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .background(Color.paper)
        }
    }

    private var centerCameraTab: some View {
        Button {
            selectedTab = .add
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Rectangle()
                        .fill(Color.ink)
                        .frame(width: 52, height: 52)
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                Text("Add Ticket")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(selectedTab == .add ? Color.ink : Color.ink.opacity(0.6))
            }
        }
        .accessibilityLabel("Add Ticket")
    }

    private func tabButton(_ tab: AppTab, title: String, systemImage: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            .foregroundStyle(selectedTab == tab ? Color.ink : Color.ink.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    ContentView()
}
