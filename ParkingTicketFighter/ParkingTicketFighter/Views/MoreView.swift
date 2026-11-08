import SwiftUI

/// More / Resources. The Detroit filing routes with the exact facts,
/// plus an index of every approved screen (S1 to S21) so the porting
/// order is visible. Screens that are not ported yet open their stub.
struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Detroit filing routes") {
                    ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(route.title).font(.headline)
                            Text(route.detail).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phone").font(.headline)
                        Text(DetroitFacts.phone).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Text(DetroitFacts.resultByMailNote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("How it works") {
                    NavigationLink {
                        HowItWorksStub()
                    } label: {
                        Label("How it works (S2)", systemImage: "list.number")
                    }
                    NavigationLink {
                        FilingInstructionsStub()
                    } label: {
                        Label("Filing instructions (S12)", systemImage: "doc.text.fill")
                    }
                }

                Section("Screens still to port") {
                    ForEach(StubCatalog.remaining, id: \.screenID) { stub in
                        NavigationLink {
                            StubScreenView(stub: stub)
                        } label: {
                            Label("\(stub.screenID) \(stub.title)", systemImage: "hammer.fill")
                        }
                    }
                }

                Section("About this scaffold") {
                    Text("Native scaffold mirroring the approved web version. Detroit only. No payment is processed, no card is stored, and the app never files anything for you: you file your own packet, the app prepares it. Guidance only, not legal advice.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("More")
        }
    }
}

/// S2, How it works. Real copy from the approved flow, kept simple here
/// until the first launch flow (S1 and S2) ports as its own pass.
struct HowItWorksStub: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                stepRow(icon: "camera.fill", title: "Snap the ticket", detail: "Take a photo, upload one, or type the ticket number.")
                stepRow(icon: "folder.fill", title: "Add your proof", detail: "Your paid session, your card charge, anything else that shows you paid.")
                stepRow(icon: "doc.richtext.fill", title: "Get your packet", detail: "A clean packet with your statement and evidence, plus exactly where and by when to file it in Detroit.")
                StubBanner(note: "First launch flow (S1 Welcome and S2) ports as its own pass.")
            }
            .padding()
        }
        .background(Color.ivory.opacity(0.55))
        .navigationTitle("How it works")
    }

    private func stepRow(icon: String, title: String, detail: String) -> some View {
        IvoryCard {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.forest)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.headline)
                    Text(detail).font(.subheadline).foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// S12, Filing instructions. The exact Detroit steps, in order.
struct FilingInstructionsStub: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                IvoryCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("File your packet one of three ways").font(.headline)
                        ForEach(Array(DetroitFacts.filingRoutes.enumerated()), id: \.offset) { index, route in
                            Text("\(index + 1). \(route.title): \(route.detail)")
                                .font(.subheadline)
                        }
                        Text("Questions: \(DetroitFacts.phone).")
                            .font(.subheadline)
                        Text("Keep your confirmation or mailing receipt photo with the ticket. Filing freezes penalties while the review is pending.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                StubBanner(note: "Stub: the per ticket filing checklist and the mark as filed step (S13) port with the packet pass.")
            }
            .padding()
        }
        .background(Color.ivory.opacity(0.55))
        .navigationTitle("Filing instructions")
    }
}

#Preview {
    MoreView()
}
