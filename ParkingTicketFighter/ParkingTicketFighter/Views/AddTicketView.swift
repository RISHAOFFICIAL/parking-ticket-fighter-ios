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
            Form {
                Section {
                    GlassSecondaryButton(title: "Take a photo of the ticket", systemImage: "camera.fill") {}
                    GlassSecondaryButton(title: "Upload a photo", systemImage: "photo.on.rectangle") {}
                    Text("The photo stays attached as evidence either way. If the app cannot read it clearly, you can type the details instead. Photo reading arrives in a later pass and will only be switched on once it is verified.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Start with the ticket (S3)")
                }

                Section {
                    TextField("Ticket number", text: $number)
                    DatePicker("Date and time issued", selection: $issueDate)
                    TextField("Zone", text: $zone)
                    TextField("Location", text: $location)
                    TextField("Plate", text: $plate)
                    TextField("Code", text: $code)
                } header: {
                    Text("Or type the details (S4)")
                } footer: {
                    Text("We need the issue date to calculate your deadline. Deadlines: pay the discounted fine within \(DeadlineRules.discountWindowDays) days, contest within \(DeadlineRules.contestWindowDays) days. The discounted fine is only for Detroit residents with a plate registered in the City's Detroit Discount program.")
                }

                Section {
                    Picker("Had you paid?", selection: $paidAnswer) {
                        ForEach(PaidAnswer.allCases) { answer in
                            Text(answer.rawValue).tag(answer)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("The one question (S5)")
                } footer: {
                    Text("When this ticket was written, had you paid for parking?")
                }

                Section {
                    GlassPrimaryButton(title: "Check my case", systemImage: "checkmark.shield.fill") {}
                    Text("Stub: saving and the case check (S6) port in the next pass. Nothing is saved from this screen yet.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Ticket")
        }
    }
}

#Preview {
    AddTicketView()
}
