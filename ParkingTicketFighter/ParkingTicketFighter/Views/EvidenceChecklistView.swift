import PhotosUI
import SwiftUI
import SwiftData

/// Evidence checklist (S7). Guided one item at a time, each with
/// where-to-find-it help: ticket photo, parking app proof, card or
/// bank charge, optional signs or meter photos, plus any defense
/// items the defense checker found. The session check runs live:
/// the app checks the session covers the ticket time and the zone
/// matches, and warns immediately when it does not. Each item can be
/// marked "I do not have this"; the case check updates and the
/// checklist shows what the packet will say without it.
struct EvidenceChecklistView: View {
    @Environment(\.modelContext) private var modelContext

    let ticket: Ticket

    private var orderedEvidence: [EvidenceItem] {
        let order: [EvidenceKind] = [.ticketPhoto, .sessionProof, .cardCharge, .signOrMeter, .defense, .other]
        return ticket.evidence.sorted {
            let a = order.firstIndex(of: $0.kind) ?? order.count
            let b = order.firstIndex(of: $1.kind) ?? order.count
            return a < b
        }
    }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    BriefPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Kicker(text: "Evidence for ticket \(ticket.number)")
                            Text("Add exactly the proof that wins. Anything you do not have, mark as not having it, and the packet will say so honestly.")
                                .font(.subheadline)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                    }
                    ForEach(orderedEvidence) { item in
                        EvidenceRowView(item: item, ticket: ticket)
                    }
                    AppSecondaryButton(title: "Add another evidence photo", systemImage: "plus") {
                        let item = EvidenceItem(
                            kind: .other,
                            label: "Extra evidence",
                            help: "Anything else that helps your case.",
                            ticket: ticket
                        )
                        modelContext.insert(item)
                        try? modelContext.save()
                    }
                    Text("Guidance only, not legal advice.")
                        .font(.footnote)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("Evidence")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One checklist row: the item, its photo slot, its session fields
/// for the session proof item, and the "I do not have this" toggle.
private struct EvidenceRowView: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var item: EvidenceItem
    let ticket: Ticket

    @State private var showingCamera = false
    @State private var libraryItem: PhotosPickerItem?

    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Label(item.label, systemImage: stateIcon)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    StatusCaps(text: stateText)
                }
                Text(item.help)
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                if item.kind == .sessionProof, let matchText = item.sessionMatchText(for: ticket) {
                    Text(matchText)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(item.sessionMatch(for: ticket) == .covers ? .ink : .signal)
                }
                if item.state != .missing {
                    if item.kind == .sessionProof {
                        sessionFields
                    }
                    photoSection
                }
                if item.state == .missing {
                    Text("The packet will say this item is not available.")
                        .font(.footnote)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                Button(item.state == .missing ? "I have this after all" : "I do not have this") {
                    item.state = item.state == .missing ? .notSet : .missing
                    if item.state == .missing {
                        item.photoData = nil
                        item.sessionStart = nil
                        item.sessionEnd = nil
                        item.sessionZone = ""
                    }
                    save()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.ink)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(
                onPick: { image in
                    showingCamera = false
                    attachPhoto(image)
                },
                onCancel: { showingCamera = false }
            )
            .ignoresSafeArea()
        }
        .onChange(of: libraryItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    await MainActor.run { attachPhoto(image) }
                }
            }
        }
    }

    private var stateIcon: String {
        switch item.state {
        case .present: return "checkmark.square.fill"
        case .missing: return "xmark.square.fill"
        case .notSet: return "square"
        }
    }

    private var stateText: String {
        switch item.state {
        case .present: return "Attached"
        case .missing: return "Do not have"
        case .notSet: return "Not yet"
        }
    }

    /// Session start, end, and zone for the session proof item. The
    /// match text above updates live as these change.
    private var sessionFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            DatePicker(
                "Session start",
                selection: Binding(
                    get: { item.sessionStart ?? ticket.issueDate },
                    set: { item.sessionStart = $0; item.state = .present; save() }
                )
            )
            DatePicker(
                "Session end",
                selection: Binding(
                    get: { item.sessionEnd ?? ticket.issueDate },
                    set: { item.sessionEnd = $0; item.state = .present; save() }
                )
            )
            HStack {
                Text("Session zone")
                    .font(.subheadline)
                TextField("Zone", text: Binding(
                    get: { item.sessionZone },
                    set: { item.sessionZone = $0; save() }
                ))
                .keyboardType(.numberPad)
                .autocorrectionDisabled()
                .multilineTextAlignment(.trailing)
            }
        }
        .font(.subheadline)
    }

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let photoData = item.photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .border(Color.ink.opacity(0.2), width: 1)
            }
            HStack(spacing: 12) {
                if cameraAvailable {
                    AppSecondaryButton(title: item.photoData == nil ? "Take a photo" : "Retake", systemImage: "camera.fill") {
                        showingCamera = true
                    }
                }
                PhotosPicker(selection: $libraryItem, matching: .images) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle")
                        Text(item.photoData == nil ? "Choose from library" : "Choose a different photo")
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
        }
    }

    private func attachPhoto(_ image: UIImage) {
        item.photoData = PhotoStorage.jpegData(for: image)
        item.state = .present
        save()
    }

    /// Saves and re-runs the case check, so the verdict always
    /// reflects the evidence actually present.
    private func save() {
        ticket.refreshVerdict()
        try? modelContext.save()
    }
}

#Preview {
    NavigationStack {
        EvidenceChecklistView(ticket: SampleData.appFailureTicket)
    }
    .modelContainer(for: [Ticket.self, EvidenceItem.self], inMemory: true)
}
