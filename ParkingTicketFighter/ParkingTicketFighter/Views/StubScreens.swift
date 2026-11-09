import SwiftUI

/// STUB SCREENS, clearly marked.
///
/// The approved flow has 21 screens (S1 to S21). This scaffold ports the
/// top level structure for real (Home, My Tickets, Add Ticket, More)
/// and shows ticket detail with real facts and deadline math. Every
/// other approved screen is a placeholder stub below, labeled with its
/// screen number so nothing is silently missing and nothing here
/// pretends to be finished work.
///
/// Porting order follows the approved flows: core fight flow first
/// (S6 case check, S7 evidence, S8 statement, S9 packet, S11 pay),
/// then tracking (S13 to S15), then duplicate review (S16), then the
/// fleet flow (S17 to S21). Photo reading and AI features port last,
/// and only once each is verified, matching the web build's limits.
struct ScreenStub: Identifiable {
    let screenID: String
    let title: String
    let note: String

    var id: String { screenID }
}

enum StubCatalog {
    static let remaining: [ScreenStub] = [
        ScreenStub(screenID: "S1", title: "Welcome", note: "One line of promise and two routes: fight a ticket, or the fleet flow. Ports with the first launch pass."),
        ScreenStub(screenID: "S6", title: "Case check", note: "The verdict engine (Strong, Worth filing, Weak) with both deadlines up front. The sample tickets already carry verified verdicts."),
        ScreenStub(screenID: "S7", title: "Evidence checklist", note: "Guided one item at a time, with session coverage and zone matching checks and mismatch warnings."),
        ScreenStub(screenID: "S8", title: "Your statement", note: "The editable statement. The draft text already generates from ticket facts in the model; this screen adds editing."),
        ScreenStub(screenID: "S9", title: "Packet preview", note: "Cover summary, statement, ticket photo, evidence pages, deadlines page, in one printable packet."),
        ScreenStub(screenID: "S10", title: "Defense checker", note: "Broken meter, hidden sign, loading, emergency, wrong plate. Each yes attaches evidence and updates the case check."),
        ScreenStub(screenID: "S11", title: "Pay $19", note: "Shown only at packet completion. Real payment needs a processor connected with approval. Until then, no card is charged or stored."),
        ScreenStub(screenID: "S13", title: "Mark as filed", note: "Pick the date and method filed. Moves the ticket to Filed, waiting on result."),
        ScreenStub(screenID: "S15", title: "Result check in", note: "At day 30: Dismissed (shows money saved), Upheld (shows what is owed and by when), or Not yet (snoozes two weeks)."),
        ScreenStub(screenID: "S16", title: "Duplicate review", note: "Suspected duplicate parking charges side by side, with a dispute summary to take to the bank. The app never contacts the bank."),
        ScreenStub(screenID: "S17", title: "Fleet setup", note: "Business name and vehicles for the fleet flow (Marcus). Per vehicle monthly plan."),
        ScreenStub(screenID: "S18", title: "Driver invite", note: "Drivers join by link, see only Add a ticket, and their tickets land on the fleet dashboard."),
        ScreenStub(screenID: "S19", title: "Fleet dashboard", note: "Every ticket by vehicle and driver, sorted by deadline urgency, red flags inside 5 days of a deadline."),
        ScreenStub(screenID: "S20", title: "Bulk packets", note: "Select the winnable tickets, build packets in one batch, review each statement, file per ticket."),
        ScreenStub(screenID: "S21", title: "Monthly report", note: "Fines paid, fines dismissed, fees spent, money saved.")
    ]
}

/// The shared stub screen: honest about what it is.
struct StubScreenView: View {
    let stub: ScreenStub

    var body: some View {
        ZStack {
            Color.ivory.opacity(0.55).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    GlassPanel(tint: .brass) {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("Stub screen", systemImage: "hammer.fill")
                                .font(.headline)
                            Text("\(stub.screenID), \(stub.title)")
                                .font(.title3.weight(.bold))
                        }
                    }
                    IvoryCard {
                        Text(stub.note)
                            .font(.subheadline)
                    }
                    Text("This screen is a placeholder in the native scaffold. It ports screen by screen from the approved design, with approval at each stage, the same process the web version followed.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .contentMargins(.bottom, 110)
        }
        .navigationTitle(stub.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// A small banner used inside partly real screens to mark the part
/// that is still a stub, so a real screen never hides a stub piece.
struct StubBanner: View {
    let note: String

    var body: some View {
        Label(note, systemImage: "hammer.fill")
            .font(.footnote.weight(.medium))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassEffect(.regular.tint(.brass.opacity(0.25)), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        StubScreenView(stub: StubCatalog.remaining[0])
    }
}
