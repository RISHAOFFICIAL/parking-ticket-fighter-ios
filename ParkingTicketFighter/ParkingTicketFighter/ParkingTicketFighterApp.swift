import SwiftUI
import SwiftData

/// Beat the Meter, native iOS scaffold.
/// Mirrors the approved web version (Stage 6 build spec, October 13, 2026).
/// Saving is wired with SwiftData: `.modelContainer(for: Ticket.self)`
/// creates the on-device store and hands its `modelContext` down to
/// every view. Views read saved tickets with `@Query` and write them
/// through the context. The remaining approved screens (S1 to S21)
/// are placeholder stubs that port screen by screen in later passes.
@main
struct ParkingTicketFighterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Ticket.self)
    }
}
