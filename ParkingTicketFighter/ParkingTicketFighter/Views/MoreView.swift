import SwiftUI

/// More / Resources. The Detroit filing routes with the exact facts,
/// plus an index of every approved screen (S1 to S21) so the porting
/// order is visible. Screens that are not ported yet open their stub.
///
/// Editorial Brief: paper white, ruled rows, kickers, serif headlines.
struct MoreView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        accountSection
                        filingSection
                        howItWorksSection
                        aboutSection
                    }
                    .padding()
                }
                .contentMargins(.bottom, 16)
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var accountSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Account")
                    .padding(.bottom, 8)
                NavigationLink {
                    AccountView()
                } label: {
                    HStack {
                        Label("Account", systemImage: "apple.logo")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.ink.opacity(0.5))
                    }
                    .foregroundStyle(.ink)
                }
            }
        }
    }

    private var filingSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "Detroit filing routes")
                    .padding(.bottom, 8)
                ForEach(DetroitFacts.filingRoutes, id: \.title) { route in
                    RuledRow(label: route.title) {
                        Text(route.detail).font(.subheadline)
                    }
                }
                RuledRow(label: "Phone") {
                    Text(DetroitFacts.phone).font(.subheadline)
                }
                Text(DetroitFacts.resultByMailNote)
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                    .padding(.top, 8)
            }
        }
    }

    private var howItWorksSection: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 0) {
                Kicker(text: "How it works")
                    .padding(.bottom, 8)
                NavigationLink {
                    HowItWorksStub()
                } label: {
                    HStack {
                        Label("How it works", systemImage: "list.number")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.ink.opacity(0.5))
                    }
                    .foregroundStyle(.ink)
                }
                .padding(.vertical, 8)
                Divider()
                    .background(Color.ink.opacity(0.2))
                NavigationLink {
                    FilingInstructionsStub()
                } label: {
                    HStack {
                        Label("Filing instructions", systemImage: "doc.text.fill")
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.ink.opacity(0.5))
                    }
                    .foregroundStyle(.ink)
                }
                .padding(.vertical, 8)
            }
        }
    }

    private var aboutSection: some View {
        Text("Native scaffold mirroring the approved web version. Detroit only. No payment is processed, no card is stored, and the app never files anything for you: you file your own packet, the app prepares it. Guidance only, not legal advice.")
            .font(.footnote)
            .foregroundStyle(.ink.opacity(0.7))
    }
}

/// S2, How it works. Real copy from the approved flow, kept simple here
/// until the first launch flow (S1 and S2) ports as its own pass.
struct HowItWorksStub: View {
    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BriefPanel {
                        VStack(alignment: .leading, spacing: 12) {
                            Kicker(text: "How it works")
                            stepRow(icon: "camera.fill", title: "Snap the ticket", detail: "Take a photo, upload one, or type the ticket number.")
                            stepRow(icon: "folder.fill", title: "Add your proof", detail: "Your paid session, your card charge, anything else that shows you paid.")
                            stepRow(icon: "doc.richtext.fill", title: "Get your packet", detail: "A clean packet with your statement and evidence, plus exactly where and by when to file it in Detroit.")
                        }
                    }
                    StubBanner(note: "The welcome and how-it-works screens arrive in the first launch pass.")
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func stepRow(icon: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.ink)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail).font(.subheadline).foregroundStyle(.ink.opacity(0.7))
            }
        }
    }
}

/// S12, Filing instructions. The exact Detroit steps, in order.
struct FilingInstructionsStub: View {
    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BriefPanel {
                        VStack(alignment: .leading, spacing: 8) {
                            Kicker(text: "File your packet one of three ways")
                            ForEach(Array(DetroitFacts.filingRoutes.enumerated()), id: \.offset) { index, route in
                                Text("\(index + 1). \(route.title): \(route.detail)")
                                    .font(.subheadline)
                            }
                            Text("Questions: \(DetroitFacts.phone).")
                                .font(.subheadline)
                            Text("Keep your confirmation or mailing receipt photo with the ticket. Filing freezes penalties while the review is pending.")
                                .font(.footnote)
                                .foregroundStyle(.ink.opacity(0.7))
                        }
                    }
                    StubBanner(note: "The per-ticket filing checklist and mark-as-filed step arrive with the packet pass.")
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("Filing")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MoreView()
}
