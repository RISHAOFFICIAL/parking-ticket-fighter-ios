import SwiftUI
import SwiftData

/// Mark as filed (S13). The user taps "I filed it" and picks the date
/// and method. The ticket moves to Filed, waiting on result, and the
/// day-30 result check reminder is scheduled. A photo of the
/// confirmation or mailing receipt can be kept with the ticket.
/// The app never files anything; this records a filing the user did.
struct MarkFiledView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket

    @State private var filedDate: Date
    @State private var method: FilingMethod
    @State private var receiptData: Data?

    init(ticket: Ticket) {
        self.ticket = ticket
        _filedDate = State(initialValue: Date())
        _method = State(initialValue: .online)
        _receiptData = State(initialValue: ticket.filingReceiptData)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                Kicker(text: "Mark ticket \(ticket.number) as filed")
                                Text("Tap this only after you have filed your packet with Detroit. Filing freezes the penalties while the review is pending.")
                                    .font(.subheadline)
                                    .foregroundStyle(.ink.opacity(0.7))
                            }
                        }
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 12) {
                                Kicker(text: "When and how did you file?")
                                DatePicker(
                                    "Date filed",
                                    selection: $filedDate,
                                    in: ...Date(),
                                    displayedComponents: .date
                                )
                                Picker("Method", selection: $method) {
                                    ForEach(FilingMethod.allCases, id: \.self) { method in
                                        Text(method.rawValue).tag(method)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                        BriefPanel {
                            PhotoSlotView(
                                title: "Confirmation or mailing receipt (optional)",
                                photoData: receiptData,
                                onPhoto: { image in
                                    receiptData = PhotoStorage.jpegData(for: image)
                                },
                                onRemove: { receiptData = nil }
                            )
                        }
                        AppPrimaryButton(title: "I filed it", systemImage: "checkmark.seal.fill") {
                            ticket.filedDate = filedDate
                            ticket.filedMethod = method
                            ticket.filingReceiptData = receiptData
                            ticket.status = .filedWaiting
                            ticket.resultCheckSnoozedUntil = nil
                            try? modelContext.save()
                            Task { await NotificationManager.schedule(for: ticket) }
                            dismiss()
                        }
                        Text(DetroitFacts.resultByMailNote)
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Mark as filed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    MarkFiledView(ticket: SampleData.appFailureTicket)
        .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
