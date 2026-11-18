import SwiftUI
import SwiftData

/// Add Ticket. The entry point of the core fight flow (S3, S4, S5).
///
/// The ticket comes in by photo (front and back) or by typing. Photos
/// are read on the phone with Vision text recognition (free, private,
/// no server) and the read fields land on Confirm Details (S4), where
/// every field is editable and nothing is saved until the user taps
/// "These are right." A photo that cannot be read stays attached as
/// evidence either way. "Check my case" saves the ticket, builds its
/// evidence checklist, runs the full S6 case check, asks for
/// notification permission at first save, and shows the case check.
///
/// Honest limit: photo reading is not claimed as working until it is
/// verified with a real ticket photo. See
/// 07-native/ocr-verification-checklist.md.
///
/// Editorial Brief: paper white, ruled rows, black square buttons.
/// Every field carries a persistent label above it, never a
/// placeholder alone.
struct AddTicketView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var number = ""
    @State private var zone = ""
    @State private var location = ""
    @State private var plate = ""
    @State private var code = "821"
    @State private var issueDate = Date()
    @State private var paidAnswer: PaidAnswer = .paid
    @State private var fineNow = DetroitFacts.code821DiscountFine
    @State private var fineLater = DetroitFacts.code821FullFine

    @State private var frontPhotoData: Data?
    @State private var backPhotoData: Data?

    @State private var isReadingPhoto = false
    @State private var photoMessage: String?
    @State private var pendingReading: OCRReading?
    @State private var savedTicket: Ticket?

    /// The form needs a ticket number, a zone, and a plate before
    /// anything can be saved. Location is optional.
    private var canSave: Bool {
        !number.trimmingCharacters(in: .whitespaces).isEmpty
            && !zone.trimmingCharacters(in: .whitespaces).isEmpty
            && !plate.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        photoSection
                        detailsSection
                        questionSection
                        checkSection
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Add Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $pendingReading) { reading in
                ConfirmDetailsView(
                    reading: reading,
                    onConfirm: { confirmed in
                        applyConfirmed(confirmed)
                        pendingReading = nil
                    },
                    onCancel: { pendingReading = nil }
                )
            }
            .sheet(item: $savedTicket) { ticket in
                CaseCheckView(ticket: ticket)
            }
        }
    }

    private var photoSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 16) {
                Kicker(text: "Start with the ticket")
                PhotoSlotView(
                    title: "Front of ticket",
                    photoData: frontPhotoData,
                    onPhoto: { image in
                        frontPhotoData = PhotoStorage.jpegData(for: image)
                        runOCR()
                    },
                    onRemove: { frontPhotoData = nil }
                )
                PhotoSlotView(
                    title: "Back of ticket",
                    photoData: backPhotoData,
                    onPhoto: { image in
                        backPhotoData = PhotoStorage.jpegData(for: image)
                        runOCR()
                    },
                    onRemove: { backPhotoData = nil }
                )
                if isReadingPhoto {
                    Text("Reading your ticket...")
                        .font(.footnote.weight(.semibold))
                }
                if let photoMessage {
                    Text(photoMessage)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.signal)
                }
                Text("The photo stays attached as evidence either way. If the app cannot read it clearly, you can type the details instead.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    private var detailsSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Or type the details")
                    .padding(.bottom, 8)
                fieldRow(label: "Ticket number") {
                    TextField("Ticket number", text: $number)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                }
                fieldRow(label: "Date and time issued") {
                    DatePicker("", selection: $issueDate)
                        .labelsHidden()
                }
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
                fieldRow(label: "Code") {
                    TextField("Code", text: $code)
                        .keyboardType(.numberPad)
                        .autocorrectionDisabled()
                }
                Text("We need the issue date to calculate your deadline. Deadlines: pay the discounted fine within \(DeadlineRules.discountWindowDays) days, contest within \(DeadlineRules.contestWindowDays) days. The discounted fine is only for Detroit residents with a plate registered in the City's Detroit Discount program.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.top, 8)
            }
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

    private var questionSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "The one question")
                Text("When this ticket was written, had you paid for parking?")
                    .font(.subheadline)
                Picker("Had you paid?", selection: $paidAnswer) {
                    ForEach(PaidAnswer.allCases) { answer in
                        Text(answer.rawValue).tag(answer)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var checkSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            AppPrimaryButton(title: "Check my case", systemImage: "checkmark.shield.fill") {
                saveTicket()
            }
            .disabled(!canSave)
            .opacity(canSave ? 1 : 0.5)
            if !canSave {
                Text("Add a ticket number, a zone, and a plate to save.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    // MARK: - Photo reading

    /// Reads the attached photos (front, then back) with on-device
    /// Vision OCR. A readable ticket opens Confirm Details. An
    /// unreadable photo or a photo that is not a ticket shows the
    /// approved message, and the photo stays attached either way.
    private func runOCR() {
        let images = [frontPhotoData, backPhotoData].compactMap { $0 }.compactMap { UIImage(data: $0) }
        guard !images.isEmpty else { return }
        isReadingPhoto = true
        photoMessage = nil
        Task {
            let reading = await TicketOCR.recognize(images: images)
            await MainActor.run {
                isReadingPhoto = false
                if !reading.looksLikeTicket {
                    photoMessage = "That does not look like a parking ticket. Retake, or continue typing details by hand."
                } else if reading.isUnreadable {
                    photoMessage = "We could not read that clearly. Try again in better light, or type the ticket number instead."
                } else {
                    pendingReading = reading
                }
            }
        }
    }

    /// Fills the form from the fields the user confirmed on S4. When
    /// the photo gave a fine amount, it becomes the full fine and the
    /// discounted fine is half of it (the Detroit Discount is 50%).
    private func applyConfirmed(_ confirmed: ConfirmedTicketFields) {
        number = confirmed.number
        issueDate = confirmed.issueDate
        zone = confirmed.zone
        location = confirmed.location
        plate = confirmed.plate
        if let fine = confirmed.fineAmount, fine > 0 {
            fineLater = fine
            fineNow = (fine / 2).rounded(toPlaces: 2)
        }
        photoMessage = nil
    }

    // MARK: - Saving

    /// Builds a Ticket from the form and saves it to the store, with
    /// its photos and default evidence checklist. The verdict comes
    /// from the full S6 case check, not the first-pass rule. First
    /// save asks for notification permission; every save schedules
    /// the ticket's reminders.
    private func saveTicket() {
        let ticket = Ticket(
            number: number.trimmingCharacters(in: .whitespaces).uppercased(),
            issueDate: issueDate,
            zone: zone.trimmingCharacters(in: .whitespaces),
            location: location.trimmingCharacters(in: .whitespaces),
            plate: plate.trimmingCharacters(in: .whitespaces).uppercased(),
            code: code.trimmingCharacters(in: .whitespaces),
            fineNow: fineNow,
            fineLater: fineLater,
            paidAnswer: paidAnswer,
            verdict: .weak,
            status: .notFiled,
            frontPhotoData: frontPhotoData,
            backPhotoData: backPhotoData
        )
        modelContext.insert(ticket)
        for item in EvidenceItem.defaultItems(for: ticket) {
            modelContext.insert(item)
        }
        ticket.refreshVerdict()
        try? modelContext.save()
        Task {
            await NotificationManager.requestPermissionIfNeeded()
            await NotificationManager.schedule(for: ticket)
        }
        savedTicket = ticket
        resetForm()
    }

    private func resetForm() {
        number = ""
        zone = ""
        location = ""
        plate = ""
        code = "821"
        issueDate = Date()
        paidAnswer = .paid
        fineNow = DetroitFacts.code821DiscountFine
        fineLater = DetroitFacts.code821FullFine
        frontPhotoData = nil
        backPhotoData = nil
        photoMessage = nil
    }
}

private extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

#Preview {
    AddTicketView()
        .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
