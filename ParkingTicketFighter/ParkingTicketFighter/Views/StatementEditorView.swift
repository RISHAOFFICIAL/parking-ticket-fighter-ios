import SwiftUI
import SwiftData

/// Your statement (S8). The app drafts the written statement from the
/// facts, and the user edits it in their own words. The warning stays
/// on screen: "Sign only what is true." Resetting clears the edited
/// text and goes back to the generated draft.
struct StatementEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket

    @State private var text: String
    @State private var saved = false

    init(ticket: Ticket) {
        self.ticket = ticket
        _text = State(initialValue: ticket.statement)
    }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    BriefPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Kicker(text: "Your statement")
                            Text("Sign only what is true.")
                                .font(.subheadline.weight(.semibold))
                            Text("This is the statement that goes in your packet, in your own words. Edit anything. The draft uses only the facts on your ticket, and never invents a detail.")
                                .font(.subheadline)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                    }
                    BriefPanel {
                        TextEditor(text: $text)
                            .font(.subheadline)
                            .frame(minHeight: 220)
                            .scrollContentBackground(.hidden)
                    }
                    AppPrimaryButton(title: "Save statement", systemImage: "checkmark") {
                        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        ticket.statementText = trimmed.isEmpty ? nil : trimmed
                        try? modelContext.save()
                        saved = true
                    }
                    if saved {
                        Text("Saved. This is the statement your packet will use.")
                            .font(.footnote.weight(.semibold))
                    }
                    Button("Reset to the draft") {
                        ticket.statementText = nil
                        text = ticket.statementDraft
                        try? modelContext.save()
                        saved = false
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.ink)
                    Text("Guidance only, not legal advice.")
                        .font(.footnote)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("Your statement")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StatementEditorView(ticket: SampleData.appFailureTicket)
    }
    .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
