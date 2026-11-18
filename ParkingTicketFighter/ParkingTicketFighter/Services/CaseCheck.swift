import Foundation

/// The full case check result (S6): the verdict, the reason in plain
/// words, and the one evidence gap that would most improve the case.
/// The verdict screen always shows both deadlines up front alongside
/// this result; the deadlines live on the ticket itself.
struct CaseCheckResult {
    let verdict: CaseVerdict
    let reason: String
    /// The specific gap that would most improve the case, or nil when
    /// there is no major gap. Shown as "Here is what would make it
    /// stronger" on the Worth filing screen.
    let topGap: String?
}

/// The full S6 case check. Goes beyond the first-pass rule (paid means
/// Strong, tried to pay means Worth filing, did not pay means Weak)
/// by weighing the evidence actually present: the paid session and
/// whether it covers the ticket time and zone, the card charge, and
/// any defense the defense checker found. A missing item lowers the
/// verdict and names the gap; a session that does not cover the ticket
/// warns instead of letting a bad packet get built.
///
/// The verdict is guidance only, not legal advice, and the app never
/// promises a dismissal. The app also never blocks a user from filing:
/// a Weak verdict still offers "Contest anyway."
enum CaseCheck {

    static func evaluate(_ ticket: Ticket) -> CaseCheckResult {
        switch ticket.paidAnswer {
        case .paid:
            return evaluatePaid(ticket)
        case .triedToPay:
            return evaluateTriedToPay(ticket)
        case .didNotPay:
            return evaluateDidNotPay(ticket)
        }
    }

    // MARK: - Paid

    private static func evaluatePaid(_ ticket: Ticket) -> CaseCheckResult {
        let session = ticket.sessionEvidence
        let card = ticket.evidence.first { $0.kind == .cardCharge }
        let cardPresent = card?.state == .present

        switch session?.state {
        case .present:
            guard let session else { break }
            switch session.sessionMatch(for: ticket) {
            case .covers:
                if cardPresent {
                    return CaseCheckResult(
                        verdict: .strong,
                        reason: "You paid, and the time and zone line up. Tickets like this get dismissed when the proof is filed right.",
                        topGap: nil
                    )
                }
                return CaseCheckResult(
                    verdict: .worthFiling,
                    reason: "Your proof is partial. The paid session covers your ticket time and the zone matches, but the card charge is still missing.",
                    topGap: "Add the card or bank charge screenshot for that session."
                )
            case .endedBefore, .startsAfter, .wrongZone:
                let detail = session.sessionMatchText(for: ticket) ?? "This session does not cover your ticket."
                return CaseCheckResult(
                    verdict: .worthFiling,
                    reason: "Your proof is partial. \(detail)",
                    topGap: "Add a session that covers the ticket time and matches zone \(ticket.zone)."
                )
            case .unknown:
                return CaseCheckResult(
                    verdict: .worthFiling,
                    reason: "Your proof is partial. Add the session times and zone so the app can check it covers your ticket.",
                    topGap: "Add the session start, end, and zone for your parking app proof."
                )
            }
        case .missing:
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "Your proof is partial. You paid, but the parking app proof is missing, so the packet will say so.",
                topGap: "The parking app proof is marked as not having it. Add it if you can find it."
            )
        case .notSet, .none:
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "Your proof is partial. You paid, but the parking app proof is not attached yet.",
                topGap: "Add the parking app proof: a screenshot of the paid session."
            )
        }
        return CaseCheckResult(
            verdict: .worthFiling,
            reason: "Your proof is partial. The evidence checklist shows what would make it stronger.",
            topGap: "Add the parking app proof: a screenshot of the paid session."
        )
    }

    // MARK: - Tried to pay

    private static func evaluateTriedToPay(_ ticket: Ticket) -> CaseCheckResult {
        let attempt = ticket.sessionEvidence
        switch attempt?.state {
        case .present:
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "You tried to pay and have the app errors to show it. The packet will show you tried before the ticket was written.",
                topGap: nil
            )
        case .missing:
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "Your proof is partial. You tried to pay, but the app error screenshots are missing, so the packet will say so.",
                topGap: "The payment attempt proof is marked as not having it. Add it if you can find it."
            )
        case .notSet, .none:
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "Your proof is partial. You tried to pay, but the app error screenshots are not attached yet.",
                topGap: "Add screenshots of the app errors or failed payment attempts."
            )
        }
    }

    // MARK: - Did not pay

    private static func evaluateDidNotPay(_ ticket: Ticket) -> CaseCheckResult {
        if let defense = ticket.defenseEvidence.first {
            return CaseCheckResult(
                verdict: .worthFiling,
                reason: "You did not pay, but the defense checker found a real defense: \(defense.label.lowercased()). The packet will lead with it.",
                topGap: nil
            )
        }
        return CaseCheckResult(
            verdict: .weak,
            reason: "Honest answer: this one is unlikely to be dismissed. There is no paid session and no defense on record.",
            topGap: "Check the defense checker for a meter, sign, or plate problem."
        )
    }
}
