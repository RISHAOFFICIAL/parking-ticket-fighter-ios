import SwiftUI

/// Root tab structure, mirroring the approved flow's top level navigation:
/// Home, My Tickets, Add Ticket, More (resources).
///
/// Per Apple's Human Interface Guidelines, the tab bar is for navigation:
/// every tab has an icon and a short label, each tab keeps its own
/// navigation state, and tapping a tab takes people to that tab's top
/// level. Add Ticket is the center tab because photographing a ticket is
/// the app's primary job, so it gets the prominent raised camera button,
/// like other apps. It is a navigation tab to the Add Ticket section, not
/// an action that opens the camera, so the tab bar stays navigation only.
/// The camera itself lives on the Add Ticket screen, where the user picks
/// Take a photo, Upload a photo, or Type the ticket number instead.
struct ContentView: View {
    enum AppTab: Hashable {
        case home, tickets, add, more
    }

    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                Tab(value: .home) {
                    HomeView()
                }
                Tab(value: .tickets) {
                    TicketListView()
                }
                Tab(value: .add) {
                    AddTicketView()
                }
                Tab(value: .more) {
                    MoreView()
                }
            }
            .toolbar(.hidden, for: .tabBar)

            customTabBar
        }
        .tint(.forest)
    }

    /// The bottom bar. A floating glass capsule, centered in the safe
    /// area, with Home and My Tickets on the left, More on the right, and
    /// the Add Ticket camera button raised in the exact center. Every tab
    /// keeps a short label under its icon, and the selected tab uses the
    /// filled icon in forest, per the HIG icon and label rules.
    private var customTabBar: some View {
        ZStack(alignment: .center) {
            Capsule()
                .glassEffect(.regular, in: Capsule())
                .frame(height: 64)
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    tabButton(.home, title: "Home", systemImage: "house.fill")
                    tabButton(.tickets, title: "My Tickets", systemImage: "ticket.fill")
                }
                .frame(maxWidth: .infinity)
                Spacer()
                    .frame(width: 84)
                HStack(spacing: 0) {
                    tabButton(.more, title: "More", systemImage: "ellipsis.circle.fill")
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4)
            centerCameraTab
        }
        .frame(height: 64)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var centerCameraTab: some View {
        Button {
            selectedTab = .add
        } label: {
            VStack(spacing: 2) {
                ZStack {
                    Circle()
                        .fill(Color.forest)
                        .frame(width: 60, height: 60)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .offset(y: -12)
                Text("Add Ticket")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(selectedTab == .add ? Color.forest : Color.primary)
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
            .foregroundStyle(selectedTab == tab ? Color.forest : Color.secondary)
            .frame(maxWidth: .infinity)
        }
        .accessibilityLabel(title)
    }
}

#Preview {
    ContentView()
}
