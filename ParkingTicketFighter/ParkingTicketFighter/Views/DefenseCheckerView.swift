import SwiftUI
import SwiftData

/// Defense checker (S10). Short questions, one at a time, for the did
/// not pay path and for weak cases. Each yes attaches the matching
/// evidence item to the checklist and updates the case check. If no
/// defense is found, the honest weak case screen still shows.
struct DefenseCheckerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let ticket: Ticket

    @State private var step = 0
    @State private var found: [Defense] = []
    @State private var finished = false

    private struct Defense {
        let question: String
        let label: String
        let help: String
        let note: String
    }

    private static let defenses: [Defense] = [
        Defense(
            question: "Was the meter broken?",
            label: "Broken meter",
            help: "A photo of the broken meter, or the meter number and what it showed.",
            note: "The meter was broken, so I could not pay for parking."
        ),
        Defense(
            question: "Was the sign missing, hidden, or wrong?",
            label: "Sign missing, hidden, or wrong",
            help: "A photo of the sign, or of where the sign should be.",
            note: "The parking sign was missing, hidden, or wrong."
        ),
        Defense(
            question: "Were you loading or unloading?",
            label: "Loading or unloading",
            help: "What you were loading or unloading, and for how long.",
            note: "I was loading or unloading when the ticket was written."
        ),
        Defense(
            question: "Was this a medical emergency?",
            label: "Medical emergency",
            help: "What happened, in your own words. No medical records are needed in the packet.",
            note: "This was a medical emergency."
        ),
        Defense(
            question: "Is the plate or vehicle wrong on the ticket?",
            label: "Wrong plate or vehicle",
            help: "A photo of your plate and registration, showing the ticket has it wrong.",
            note: "The plate or vehicle on the ticket is wrong."
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if finished {
                            summaryPanel
                        } else {
                            questionPanel
                        }
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("Defense checker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var questionPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Question \(step + 1) of \(Self.defenses.count)")
                Text(Self.defenses[step].question)
                    .font(.briefHeadline(22, relativeTo: .title3))
                AppButtonPair(
                    primaryTitle: "Yes",
                    secondaryTitle: "No",
                    primaryAction: { answer(true) },
                    secondaryAction: { answer(false) }
                )
            }
        }
    }

    private var summaryPanel: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Defenses found")
                if found.isEmpty {
                    Text("No defense found from these questions.")
                        .font(.subheadline)
                    Text("The honest advice still stands: paying the discounted amount may cost less than contesting. You can still contest anyway from the case check screen.")
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                } else {
                    Text("We found \(found.count) possible \(found.count == 1 ? "defense" : "defenses"). Each one is now on your evidence checklist.")
                        .font(.subheadline)
                    ForEach(found, id: \.label) { defense in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(defense.label)
                                .font(.subheadline.weight(.semibold))
                            Text(defense.help)
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                    }
                    Text("Your case check now says Worth filing. Add the evidence for each defense from the checklist.")
                        .font(.subheadline)
                }
                AppPrimaryButton(title: "Done", systemImage: "checkmark") {
                    dismiss()
                }
            }
        }
    }

    private func answer(_ yes: Bool) {
        if yes {
            let defense = Self.defenses[step]
            found.append(defense)
            let item = EvidenceItem(
                kind: .defense,
                label: defense.label,
                help: defense.help,
                state: .present,
                note: defense.note,
                ticket: ticket
            )
            // Setting item.ticket fills the inverse (ticket.evidence)
            // automatically; do not append as well.
            modelContext.insert(item)
        }
        if step + 1 < Self.defenses.count {
            step += 1
        } else {
            ticket.refreshVerdict()
            try? modelContext.save()
            finished = true
        }
    }
}

#Preview {
    DefenseCheckerView(ticket: SampleData.appFailureTicket)
        .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
