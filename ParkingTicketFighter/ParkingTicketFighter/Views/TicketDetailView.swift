import SwiftUI
import SwiftData

/// Ticket detail. Mirrors the tracking screen (S14): the facts, both
/// deadlines up front, the status timeline, the case check (S6), the
/// statement (S8), the evidence checklist (S7), the ticket photos,
/// the packet (S9), mark as filed (S13), the result check-in (S15),
/// and the Detroit filing routes (S12). Delete is wired: the button
/// at the bottom removes the ticket from the store after a
/// confirmation, and cancels its reminders.
///
/// Editorial Brief: the detail reads as a case brief. Labeled fields
/// in ruled two column rows, deadlines as red marginalia, status in
/// small caps text. Paper white always.
struct TicketDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allTickets: [Ticket]

    let ticket: Ticket

    @State private var showingDeleteConfirmation = false
    @State private var showingCaseCheck = false
    @State private var showingMarkFiled = false
    @State private var showingResultCheckIn = false

    private var lifetimeSaved: Double {
        allTickets.reduce(0) { $0 + $1.amountSaved }
    }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if ticket.resultCheckDue {
                        resultCheckInPanel
                    }
                    verdictPanel
                    factsCard
                    deadlinesCard
                    photosCard
                    statusCard
                    statementCard
                    evidenceCard
                    packetCard
                    filingCard
                    deleteSection
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle(ticket.number)
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "Delete ticket \(ticket.number)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete ticket", role: .destructive) {
                NotificationManager.cancel(for: ticket)
                modelContext.delete(ticket)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This removes the ticket and its deadlines. It cannot be undone.")
        }
        .sheet(isPresented: $showingCaseCheck) {
            CaseCheckView(ticket: ticket)
        }
        .sheet(isPresented: $showingMarkFiled) {
            MarkFiledView(ticket: ticket)
        }
        .sheet(isPresented: $showingResultCheckIn) {
            ResultCheckInView(ticket: ticket, lifetimeSaved: lifetimeSaved)
        }
    }

    /// Delete sits at the bottom, away from the case content, in
    /// signal red so it reads as destructive at a glance.
    private var deleteSection: some View {
        Button {
            showingDeleteConfirmation = true
        } label: {
            Text("Delete this ticket")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.signal)
        }
    }

    /// The day-30 result check-in (S15), shown when it is due.
    private var resultCheckInPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your result")
                Text("Did your letter arrive?")
                    .font(.briefHeadline(20, relativeTo: .title3))
                AppPrimaryButton(title: "Record my result", systemImage: "envelope.fill") {
                    showingResultCheckIn = true
                }
            }
        }
    }

    /// The case check verdict (S6), on a brief panel with a thick top
    /// rule. The verdict is small caps ink text, with the reason in words.
    private var verdictPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Case check")
                StatusCaps(text: ticket.verdict.rawValue)
                Text(CaseCheck.evaluate(ticket).reason)
                    .font(.subheadline)
                Button("See the full case check") {
                    showingCaseCheck = true
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.ink)
            }
        }
    }

    private var factsCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Ticket facts")
                    .padding(.bottom, 8)
                RuledRow(label: "Issued") {
                    Text(ticket.issueDate.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                }
                RuledRow(label: "Zone") {
                    Text(ticket.zone).font(.subheadline)
                }
                RuledRow(label: "Location") {
                    Text(ticket.location.isEmpty ? "Not recorded" : ticket.location).font(.subheadline)
                }
                RuledRow(label: "Plate") {
                    Text(ticket.plate).font(.subheadline)
                }
                RuledRow(label: "Code") {
                    Text(ticket.code).font(.subheadline)
                }
                RuledRow(label: "City") {
                    Text(ticket.city).font(.subheadline)
                }
                RuledRow(label: "You said") {
                    Text(ticket.paidAnswer.rawValue).font(.subheadline)
                }
            }
        }
    }

    /// Both deadlines up front, the rule from the case check screen (S6):
    /// the discount deadline and the contest deadline, with the step up.
    /// Deadlines are red marginalia.
    private var deadlinesCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your deadlines")
                DeadlineCaps(text: "Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted))")
                DeadlineCaps(text: "Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted))")
                Text("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)). \(DetroitFacts.code821LateFeeNote)")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                if ticket.contestDeadlinePassed {
                    Text("This contest deadline has passed. The app shows what is owed now and the pay instructions path instead of the contest path.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.signal)
                }
                if ticket.status == .upheld, let owed = ticket.resultAmountOwed, let deadline = ticket.resultPaymentDeadline {
                    DeadlineCaps(text: "Pay \(Money.format(owed)) by \(deadline.formatted(date: .abbreviated, time: .omitted))")
                }
            }
        }
    }

    /// Front and back ticket photos, attached as evidence. A photo can
    /// be added or retaken here even when the ticket was typed in.
    private var photosCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 16) {
                Kicker(text: "Ticket photos")
                PhotoSlotView(
                    title: "Front of ticket",
                    photoData: ticket.frontPhotoData,
                    onPhoto: { image in
                        ticket.frontPhotoData = PhotoStorage.jpegData(for: image)
                        markTicketPhotoPresent()
                        try? modelContext.save()
                    },
                    onRemove: {
                        ticket.frontPhotoData = nil
                        try? modelContext.save()
                    }
                )
                PhotoSlotView(
                    title: "Back of ticket",
                    photoData: ticket.backPhotoData,
                    onPhoto: { image in
                        ticket.backPhotoData = PhotoStorage.jpegData(for: image)
                        try? modelContext.save()
                    },
                    onRemove: {
                        ticket.backPhotoData = nil
                        try? modelContext.save()
                    }
                )
            }
        }
    }

    /// A front photo marks the ticket photo evidence item done.
    private func markTicketPhotoPresent() {
        if let photoItem = ticket.evidence.first(where: { $0.kind == .ticketPhoto }) {
            photoItem.state = .present
        }
    }

    /// Status timeline (S14): Added, Packet built, Filed, Waiting on result.
    private var statusCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Status")
                StatusCaps(text: ticket.status.rawValue)
                if let filedDate = ticket.filedDate, let method = ticket.filedMethod {
                    Text("Filed \(filedDate.formatted(date: .abbreviated, time: .omitted)), \(method.rawValue).")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                    Text(DetroitFacts.resultByMailNote)
                        .font(.footnote)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                if ticket.status == .notFiled || ticket.status == .packetBuilt {
                    AppPrimaryButton(title: "I filed it", systemImage: "checkmark.seal.fill") {
                        showingMarkFiled = true
                    }
                }
            }
        }
    }

    private var statementCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your statement")
                Text(ticket.statement)
                    .font(.subheadline)
                Text("Sign only what is true. You can edit this in your own words before anything is filed.")
                    .font(.footnote.weight(.semibold))
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

    private var evidenceCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Evidence checklist")
                    .padding(.bottom, 8)
                if ticket.evidence.isEmpty {
                    Text("No evidence items yet. Add them from the checklist.")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                ForEach(ticket.evidence) { item in
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 2) {
                            Label(item.label, systemImage: item.state == .present ? "checkmark.square.fill" : item.state == .missing ? "xmark.square.fill" : "square")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.ink)
                            Text(item.help)
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                            if item.kind == .sessionProof, let matchText = item.sessionMatchText(for: ticket) {
                                Text(matchText)
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(item.sessionMatch(for: ticket) == .covers ? .ink : .signal)
                            }
                        }
                        .padding(.vertical, 8)
                        Divider()
                            .background(Color.ink.opacity(0.2))
                    }
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

    private var packetCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                Kicker(text: "Your packet")
                Text("Cover summary, statement, ticket photo, evidence, and deadlines, as it will be filed.")
                    .font(.subheadline)
                    .foregroundStyle(.ink.opacity(0.7))
                NavigationLink {
                    PacketPreviewView(ticket: ticket)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.richtext.fill")
                        Text("Preview packet")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.ink)
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
    }

    /// Where to file in Detroit, the exact routes from screen S12.
    private var filingCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Where to file in Detroit")
                    .padding(.bottom, 8)
                ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                    RuledRow(label: route.title) {
                        Text(route.detail).font(.subheadline)
                    }
                }
                RuledRow(label: "Phone") {
                    Text(DetroitFacts.phone).font(.subheadline)
                }
                Text("Your packet is free during launch. In this build no payment is processed and no card is stored.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TicketDetailView(ticket: SampleData.appFailureTicket)
    }
    .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
