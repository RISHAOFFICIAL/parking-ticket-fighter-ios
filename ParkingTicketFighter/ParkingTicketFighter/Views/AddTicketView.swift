import SwiftUI
import SwiftData

/// Add Ticket. The entry point of the core fight flow (S3, S4, S5).
///
/// Saving is wired: "Check my case" builds a Ticket from the form,
/// inserts it into the SwiftData store, and shows the case check
/// verdict. The verdict here is the first-pass rule from the approved
/// flow: paid means Strong, tried to pay means Worth filing, did not
/// pay means Weak. The full S6 case check, which weighs the evidence,
/// arrives in a later pass. Photo reading (OCR) is not claimed
/// anywhere until it is verified working with a real ticket photo,
/// the same honest limit the web build carries.
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
    @State private var savedTicketNumber: String?
    @State private var savedVerdict: CaseVerdict?

    /// The form needs a ticket number, a zone, and a plate before
    /// anything can be saved. Location is optional.
    private var canSave: Bool {
        !number.trimmingCharacters(in: .whitespaces).isEmpty
            && !zone.trimmingCharacters(in: .whitespaces).isEmpty
            && !plate.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// First-pass verdict from the one question (S5). The full S6
    /// case check weighs the evidence too and arrives in a later pass.
    private var verdictForAnswer: CaseVerdict {
        switch paidAnswer {
        case .paid: return .strong
        case .triedToPay: return .worthFiling
        case .didNotPay: return .weak
        }
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
        }
    }

    private var photoSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Start with the ticket")
                AppSecondaryButton(title: "Take a photo of the ticket", systemImage: "camera.fill") {}
                AppSecondaryButton(title: "Upload a photo", systemImage: "photo.on.rectangle") {}
                Text("The photo stays attached as evidence either way. If the app cannot read it clearly, you can type the details instead. Photo reading arrives in a later pass and will only be switched on once it is verified.")
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
            if let savedTicketNumber, let savedVerdict {
                Text("Ticket \(savedTicketNumber) saved. Case check: \(savedVerdict.rawValue). Find it in My Tickets.")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.ink)
            } else if !canSave {
                Text("Add a ticket number, a zone, and a plate to save.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
            }
        }
    }

    /// Builds a Ticket from the form and saves it to the store.
    /// Code 821 is the Detroit standard: $45 fine, $22.50 inside the
    /// discount window for registered Detroit plates. Other codes
    /// keep the same amounts for now; per-code fines arrive later.
    private func saveTicket() {
        let ticket = Ticket(
            number: number.trimmingCharacters(in: .whitespaces).uppercased(),
            issueDate: issueDate,
            zone: zone.trimmingCharacters(in: .whitespaces),
            location: location.trimmingCharacters(in: .whitespaces),
            plate: plate.trimmingCharacters(in: .whitespaces).uppercased(),
            code: code.trimmingCharacters(in: .whitespaces),
            fineNow: 22.50,
            fineLater: 45.00,
            paidAnswer: paidAnswer,
            verdict: verdictForAnswer,
            status: .notFiled
        )
        modelContext.insert(ticket)
        try? modelContext.save()
        savedTicketNumber = ticket.number
        savedVerdict = ticket.verdict
        number = ""
        zone = ""
        location = ""
        plate = ""
        code = "821"
        issueDate = Date()
        paidAnswer = .paid
    }
}

#Preview {
    AddTicketView()
        .modelContainer(for: Ticket.self, inMemory: true)
}
