import SwiftUI
import SwiftData

/// Packet preview (S9). The full packet as it will be filed: cover
/// summary, statement, ticket photo, evidence pages, deadlines page.
/// "This looks right" marks the packet built. Share exports the packet
/// as a PDF (Save to Files, AirDrop, mail, or print) so the user can
/// file it with the City of Detroit. The packet is free during launch.
struct PacketPreviewView: View {
    @Environment(\.modelContext) private var modelContext

    let ticket: Ticket

    @State private var shareURL: URL?
    @State private var packetConfirmed = false

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    coverPanel
                    statementPanel
                    photosPanel
                    evidencePanel
                    deadlinesPanel
                    actionsPanel
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("Your packet")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            shareURL = PacketBuilder.packetURL(for: ticket)
        }
    }

    private var coverPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Cover summary")
                    .padding(.bottom, 8)
                Text("BEAT THE METER")
                    .font(.briefTitle(22, relativeTo: .title2))
                Text("Contest packet, City of Detroit")
                    .font(.subheadline)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.bottom, 8)
                RuledRow(label: "Ticket") { Text(ticket.number).font(.subheadline) }
                RuledRow(label: "Issued") {
                    Text(ticket.issueDate.formatted(date: .abbreviated, time: .shortened)).font(.subheadline)
                }
                RuledRow(label: "Zone") { Text(ticket.zone).font(.subheadline) }
                RuledRow(label: "Location") {
                    Text(ticket.location.isEmpty ? "Not recorded" : ticket.location).font(.subheadline)
                }
                RuledRow(label: "Plate") { Text(ticket.plate).font(.subheadline) }
                RuledRow(label: "Code") { Text(ticket.code).font(.subheadline) }
                RuledRow(label: "Case check") { Text(ticket.verdict.rawValue).font(.subheadline) }
            }
        }
    }

    private var statementPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your statement")
                Text(ticket.statement)
                    .font(.subheadline)
                NavigationLink {
                    StatementEditorView(ticket: ticket)
                } label: {
                    Text("Edit statement")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.ink)
                }
            }
        }
    }

    private var photosPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Ticket photos")
                if let front = ticket.frontPhotoData, let image = UIImage(data: front) {
                    Text("Front of ticket")
                        .font(.footnote.weight(.semibold))
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .border(Color.ink.opacity(0.2), width: 1)
                }
                if let back = ticket.backPhotoData, let image = UIImage(data: back) {
                    Text("Back of ticket")
                        .font(.footnote.weight(.semibold))
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 240)
                        .border(Color.ink.opacity(0.2), width: 1)
                }
                if ticket.frontPhotoData == nil && ticket.backPhotoData == nil {
                    Text("No ticket photo attached. Add one from the ticket detail screen.")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                }
            }
        }
    }

    private var evidencePanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Evidence")
                    .padding(.bottom, 8)
                if ticket.evidence.filter({ $0.kind != .ticketPhoto }).isEmpty {
                    Text("No evidence items recorded.")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                ForEach(ticket.evidence.filter { $0.kind != .ticketPhoto }) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.label)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            StatusCaps(text: item.state == .present ? "Attached" : item.state == .missing ? "Not available" : "Not recorded")
                        }
                        if item.kind == .sessionProof, let matchText = item.sessionMatchText(for: ticket) {
                            Text(matchText)
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                        if let photoData = item.photoData, let image = UIImage(data: photoData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .border(Color.ink.opacity(0.2), width: 1)
                        }
                    }
                    .padding(.vertical, 8)
                    Divider()
                        .background(Color.ink.opacity(0.2))
                }
                NavigationLink {
                    EvidenceChecklistView(ticket: ticket)
                } label: {
                    Text("Edit evidence")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.ink)
                }
                .padding(.top, 8)
            }
        }
    }

    private var deadlinesPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Deadlines and filing")
                DeadlineCaps(text: "Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted))")
                DeadlineCaps(text: "Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                Text("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)). \(DetroitFacts.code821LateFeeNote)")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                    RuledRow(label: route.title) {
                        Text(route.detail).font(.subheadline)
                    }
                }
                RuledRow(label: "Phone") {
                    Text(DetroitFacts.phone).font(.subheadline)
                }
                Text(DetroitFacts.resultByMailNote)
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.top, 8)
            }
        }
    }

    private var actionsPanel: some View {
        VStack(spacing: 12) {
            if ticket.status == .notFiled {
                AppPrimaryButton(title: "This looks right", systemImage: "checkmark.seal.fill") {
                    ticket.status = .packetBuilt
                    try? modelContext.save()
                    packetConfirmed = true
                    Task { await NotificationManager.schedule(for: ticket) }
                }
            }
            if packetConfirmed || ticket.status == .packetBuilt {
                Text("Packet built. File it with Detroit using the routes above, then mark it as filed from the ticket detail screen.")
                    .font(.footnote.weight(.semibold))
            }
            if let shareURL {
                ShareLink(item: shareURL) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share packet PDF")
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.paper)
                    .foregroundStyle(.ink)
                    .border(Color.ink, width: 1)
                }
                .buttonStyle(.plain)
            }
            Text("Your packet is free during launch. No payment is processed and no card is stored.")
                .font(.footnote)
                .foregroundStyle(.ink.opacity(0.7))
        }
    }
}

#Preview {
    NavigationStack {
        PacketPreviewView(ticket: SampleData.appFailureTicket)
    }
    .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
