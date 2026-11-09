import AuthenticationServices
import SwiftUI

/// Account, Sign in with Apple.
///
/// Per Apple's Human Interface Guidelines, sign-in is delayed until it
/// provides value and is never forced before the app is useful. Here it
/// exists so tickets and packets can be saved to an account. The app uses
/// the system Sign in with Apple button, asks for name and email, never
/// asks for a password, and shows "Using Sign in with Apple" once signed
/// in. Apple only shares the name and email on the first sign-in, so they
/// are stored the first time they arrive. A private relay email is shown
/// as it arrives and is never swapped for a personal email.
///
/// Editorial Brief: paper white, black square buttons, small caps status.
struct AccountView: View {
    @AppStorage("appleUserID") private var userID: String?
    @AppStorage("appleUserName") private var displayName: String?
    @AppStorage("appleUserEmail") private var email: String?
    @State private var signInError: String?

    private var isSignedIn: Bool { userID != nil }

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if isSignedIn {
                        signedInCard
                    } else {
                        signInCard
                    }
                    if let signInError {
                        Text(signInError)
                            .font(.footnote)
                            .foregroundStyle(.signal)
                    }
                }
                .padding()
            }
            .contentMargins(.bottom, 16)
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: refreshCredentialState)
    }

    private var signInCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Sign in to keep your tickets")
                Text("Sign in with Apple to save your tickets and packets to your account, so they are there on any device you use. Nothing is saved to an account until you sign in.")
                    .font(.subheadline)
                    .foregroundStyle(.ink.opacity(0.7))
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    handleSignIn(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
            }
        }
    }

    private var signedInCard: some View {
        BriefPanel {
            VStack(alignment: .leading, spacing: 12) {
                Kicker(text: "Using Sign in with Apple")
                if let displayName, !displayName.isEmpty {
                    Text(displayName)
                        .font(.briefHeadline(20, relativeTo: .title3))
                }
                if let email, !email.isEmpty {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.ink.opacity(0.7))
                }
                Text("Your tickets and packets save to this account.")
                    .font(.footnote)
                    .foregroundStyle(.ink.opacity(0.7))
                AppSecondaryButton(title: "Sign out", systemImage: "rectangle.portrait.and.arrow.right") {
                    signOut()
                }
            }
        }
    }

    private func handleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }
            userID = credential.user
            if let name = credential.fullName {
                let formatted = [name.givenName, name.familyName].compactMap { $0 }.joined(separator: " ")
                if !formatted.isEmpty { displayName = formatted }
            }
            if let email = credential.email, !email.isEmpty {
                self.email = email
            }
            signInError = nil
        case .failure(let error):
            if let authError = error as? ASAuthorizationError, authError.code == .canceled {
                return
            }
            signInError = error.localizedDescription
        }
    }

    private func signOut() {
        userID = nil
        displayName = nil
        email = nil
        signInError = nil
    }

    private func refreshCredentialState() {
        guard let userID else { return }
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, _ in
            if state == .revoked || state == .notFound {
                Task { @MainActor in
                    signOut()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
}
