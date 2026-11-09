import SwiftUI

/// Add Ticket. The entry point of the core fight flow (S3, S4, S5).
///
/// SCAFFOLD NOTE: this screen has the approved shape, but it does not
/// save yet. In the approved flow, S3 offers "Take a photo of the
/// ticket", "Upload a photo", and "Type the ticket number instead".
/// Photo reading (OCR) is not claimed anywhere until it is verified
/// working with a real ticket photo, the same honest limit the web
/// build carries. Manual entry below mirrors S4 (confirm details)
/// and S5 (the one question).
///
/// Editorial Brief: paper white, ruled rows, black square buttons.
/// Every field carries a persistent label above it, never a
/// placeholder alone.
struct AddTicketView: View {
    @State private var number = ""
    @State private var zone = ""
    @State private var location = ""
    @State private var plate = ""
    @State private var code = "821"
    @State private var issueDate = Date()
    @State private var paidAnswer: PaidAnswer = .paid

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
            AppPrimaryButton(title: "Check my case", systemImage: "checkmark.shield.fill") {}
            Text("Saving and the case check arrive in the next update. Nothing is saved from this screen yet.")
                .font(.footnote)
                .foregroundStyle(.ink.opacity(0.7))
        }
    }
}

#Preview {
    AddTicketView()
}
