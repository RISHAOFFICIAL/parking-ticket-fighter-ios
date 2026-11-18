import SwiftUI
import SwiftData

/// Beat the Meter, native iOS app.
/// Mirrors the approved web version (Stage 6 build spec, October 13, 2026).
/// Saving is wired with SwiftData: the model container holds Ticket
/// and EvidenceItem, and hands its `modelContext` down to every view.
/// Views read saved tickets with `@Query` and write them through the
/// context. The core fight flow is built (photo and OCR, case check,
/// evidence, statement, packet, filing, result check-in, reminders);
/// the remaining approved screens (S1 welcome, S11 pay, S16 duplicate
/// review, S17 to S21 fleet) port in later passes.
@main
struct ParkingTicketFighterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Ticket.self, EvidenceItem.self])
    }
}
