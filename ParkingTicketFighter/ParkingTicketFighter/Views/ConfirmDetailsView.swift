import SwiftUI

/// The fields the user confirmed on Confirm Details (S4), handed back
/// to Add Ticket to fill the form. Nothing the app read is treated as
/// final until the user taps "These are right."
struct ConfirmedTicketFields {
    var number: String
    var issueDate: Date
    var zone: String
    var location: String
    var plate: String
    var fineAmount: Double?
}

/// Confirm details (S4). Shows what the app read off the ticket photo,
/// with every field editable. If the issue date is missing or
/// impossible, that field is flagged in place and the user must pick
/// the date before confirming, because the deadlines depend on it.
struct ConfirmDetailsView: View {
    let reading: OCRReading
    var onConfirm: (ConfirmedTicketFields) -> Void
    var onCancel: () -> Void

    @State private var number: String
    @State private var zone: String
    @State private var location: String
    @State private var plate: String
    @State private var fineText: String
    @State private var issueDate: Date
    /// False when the photo gave no usable date. The user must pick
    /// the date before "These are right" enables.
    @State private var dateConfirmed: Bool

    init(reading: OCRReading, onConfirm: @escaping (ConfirmedTicketFields) -> Void, onCancel: @escaping () -> Void) {
        self.reading = reading
        self.onConfirm = onConfirm
        self.onCancel = onCancel
        let fields = reading.fields
        _number = State(initialValue: fields.number ?? "")
        _zone = State(initialValue: fields.zone ?? "")
        _location = State(initialValue: fields.location ?? "")
        _plate = State(initialValue: fields.plate ?? "")
        if let fine = fields.fineAmount {
            _fineText = State(initialValue: String(format: "%.2f", fine))
        } else {
            _fineText = State(initialValue: "")
        }
        _issueDate = State(initialValue: fields.issueDate ?? Date())
        _dateConfirmed = State(initialValue: fields.issueDate != nil && !fields.issueDateInvalid)
    }

    private var fineAmount: Double? {
        let cleaned = fineText.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "$", with: "")
        return Double(cleaned)
    }

    private var canConfirm: Bool {
        dateConfirmed
            && !number.trimmingCharacters(in: .whitespaces).isEmpty
            && !zone.trimmingCharacters(in: .whitespaces).isEmpty
            && !plate.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                Kicker(text: "Check what the app read")
                                Text("Check every field. The app read these from your photo, and you can fix anything it got wrong before the ticket is saved.")
                                    .font(.subheadline)
                                    .foregroundStyle(.ink.opacity(0.7))
                            }
                        }
                        BriefPanel {
                            VStack(alignment: .leading, spacing: 0) {
                                fieldRow(label: "Ticket number") {
                                    TextField("Ticket number", text: $number)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.characters)
                                }
                                dateRow
                                fieldRow(label: "Zone") {
                                    TextField("Zone", text: $zone)
                                        .keyboardType(.numberPad)
                                        .autocorrectionDisabled()
                                }
                                fieldRow(label: "Location") {
                                    TextField("Location", text: $location)
                                }
                                fieldRow(label: "Plate") {
                                    TextField("Plate", text: $plate)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.characters)
                                }
                                fieldRow(label: "Fine amount") {
                                    TextField("45.00", text: $fineText)
                                        .keyboardType(.decimalPad)
                                }
                            }
                        }
                        AppPrimaryButton(title: "These are right", systemImage: "checkmark.shield.fill") {
                            onConfirm(ConfirmedTicketFields(
                                number: number.trimmingCharacters(in: .whitespaces).uppercased(),
                                issueDate: issueDate,
                                zone: zone.trimmingCharacters(in: .whitespaces),
                                location: location.trimmingCharacters(in: .whitespaces),
                                plate: plate.trimmingCharacters(in: .whitespaces).uppercased(),
                                fineAmount: fineAmount
                            ))
                        }
                        .disabled(!canConfirm)
                        .opacity(canConfirm ? 1 : 0.5)
                        if !canConfirm {
                            Text(missingHint)
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                        Text("The photo stays attached as evidence either way.")
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Confirm details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }

    private var missingHint: String {
        if !dateConfirmed {
            return "Pick the issue date to continue. We need it to calculate your deadline."
        }
        return "Add a ticket number, a zone, and a plate to continue."
    }

    private var dateRow: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text("DATE AND TIME ISSUED")
                    .font(.caption.weight(.semibold))
                    .tracking(1.0)
                    .foregroundStyle(.ink)
                DatePicker("", selection: $issueDate)
                    .labelsHidden()
                    .onChange(of: issueDate) { _, _ in
                        dateConfirmed = true
                    }
                if !dateConfirmed {
                    Text("We need the issue date to calculate your deadline.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.signal)
                    if let raw = reading.fields.issueDateText {
                        Text("The photo read: \(raw). Pick the right date above.")
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    } else {
                        Text("The photo did not give a clear date. Pick it above.")
                            .font(.footnote)
                            .foregroundStyle(.ink.opacity(0.7))
                    }
                }
            }
            .padding(.vertical, 8)
            Divider()
                .background(Color.ink.opacity(0.2))
        }
    }

    private func fieldRow<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(1.0)
                    .foregroundStyle(.ink)
                content()
                    .font(.body)
            }
            .padding(.vertical, 8)
            Divider()
                .background(Color.ink.opacity(0.2))
        }
    }
}

#Preview {
    ConfirmDetailsView(
        reading: OCRReading(
            fields: {
                var fields = ParsedTicketFields()
                fields.number = "Y18776021"
                fields.zone = "105"
                fields.location = "Cadillac Sq"
                fields.plate = "7PAC20"
                fields.fineAmount = 45.00
                fields.issueDateInvalid = true
                fields.issueDateText = "13/40/2026"
                return fields
            }(),
            looksLikeTicket: true
        ),
        onConfirm: { _ in },
        onCancel: {}
    )
}
