import Foundation
import SwiftData

/// What kind of proof an evidence item is (screen S7 of the approved flow).
enum EvidenceKind: String, Codable, CaseIterable {
    /// The ticket photo itself, attached when the ticket is added.
    case ticketPhoto
    /// Screenshot of the paid parking session, with its time window and zone.
    case sessionProof
    /// Screenshot of the parking payment on a card or bank statement.
    case cardCharge
    /// Optional photos of signs or the meter.
    case signOrMeter
    /// A defense found by the defense checker (S10), e.g. broken meter.
    case defense
    /// Any other photo the user adds.
    case other
}

/// Whether the user has an evidence item, does not have it, or has not
/// answered yet. Marking an item missing updates the case check and the
/// checklist shows what the packet will say without it.
enum EvidenceState: String, Codable {
    case notSet
    case present
    case missing
}

/// How a paid session lines up against the ticket it is meant to cover.
/// The session check (S7) says so in plain words, and a mismatch asks
/// for a different session instead of letting a bad packet get built.
enum SessionMatch: Equatable {
    /// No session times or zone entered yet.
    case unknown
    /// The session covers the ticket time and the zone matches.
    case covers
    /// The session ended before the ticket was written.
    case endedBefore(minutes: Int)
    /// The ticket was written before the session started.
    case startsAfter(minutes: Int)
    /// The session zone is not the ticket zone.
    case wrongZone(sessionZone: String, ticketZone: String)
}

/// One item on a ticket's evidence checklist (S7). Stored with the
/// ticket in SwiftData, so evidence survives app relaunches and is
/// deleted with the ticket (cascade delete rule on Ticket.evidence).
@Model
final class EvidenceItem {
    var id: UUID = UUID()
    var kind: EvidenceKind
    var label: String
    var help: String
    var state: EvidenceState
    var note: String
    /// Attached photo (screenshot or camera photo), stored outside the
    /// database file so the store stays small.
    @Attribute(.externalStorage) var photoData: Data?
    /// The paid session window, for the session proof item only.
    var sessionStart: Date?
    var sessionEnd: Date?
    var sessionZone: String
    var ticket: Ticket?

    init(
        id: UUID = UUID(),
        kind: EvidenceKind,
        label: String,
        help: String,
        state: EvidenceState = .notSet,
        note: String = "",
        photoData: Data? = nil,
        sessionStart: Date? = nil,
        sessionEnd: Date? = nil,
        sessionZone: String = "",
        ticket: Ticket? = nil
    ) {
        self.id = id
        self.kind = kind
        self.label = label
        self.help = help
        self.state = state
        self.note = note
        self.photoData = photoData
        self.sessionStart = sessionStart
        self.sessionEnd = sessionEnd
        self.sessionZone = sessionZone
        self.ticket = ticket
    }

    /// The session check for the session proof item: does the session
    /// cover the ticket time, and does the zone match?
    func sessionMatch(for ticket: Ticket) -> SessionMatch {
        guard kind == .sessionProof else { return .unknown }
        guard let start = sessionStart, let end = sessionEnd else { return .unknown }
        if !sessionZone.isEmpty, sessionZone != ticket.zone {
            return .wrongZone(sessionZone: sessionZone, ticketZone: ticket.zone)
        }
        if end < ticket.issueDate {
            let minutes = Int(ticket.issueDate.timeIntervalSince(end) / 60)
            return .endedBefore(minutes: max(minutes, 1))
        }
        if start > ticket.issueDate {
            let minutes = Int(start.timeIntervalSince(ticket.issueDate) / 60)
            return .startsAfter(minutes: max(minutes, 1))
        }
        return .covers
    }

    /// The session check in plain words, for the checklist row and the
    /// case check. Returns nil when there is nothing to say yet.
    func sessionMatchText(for ticket: Ticket) -> String? {
        switch sessionMatch(for: ticket) {
        case .unknown:
            return nil
        case .covers:
            return "This session covers your ticket time. Zone matches."
        case .endedBefore(let minutes):
            return "This session ended \(minutes) minutes before your ticket was written. Add a different session."
        case .startsAfter(let minutes):
            return "This session started \(minutes) minutes after your ticket was written. Add a different session."
        case .wrongZone(let sessionZone, let ticketZone):
            return "This session is for zone \(sessionZone), but your ticket is zone \(ticketZone). Add a different session."
        }
    }

    /// The default checklist for a new ticket, from the approved flow.
    /// The ticket photo shows as done when a photo is attached.
    /// The session proof label follows the one-question answer: for a
    /// failed payment it is the app errors, not a paid session.
    static func defaultItems(for ticket: Ticket) -> [EvidenceItem] {
        let ticketPhoto = EvidenceItem(
            kind: .ticketPhoto,
            label: "Ticket photo",
            help: "Already attached when you add the ticket.",
            state: ticket.frontPhotoData == nil ? .notSet : .present,
            ticket: ticket
        )
        let sessionHelp: String
        let sessionLabel: String
        switch ticket.paidAnswer {
        case .paid:
            sessionLabel = "Parking app proof"
            sessionHelp = "Screenshot of the paid session. The app checks the session covers the ticket time and the zone matches."
        case .triedToPay:
            sessionLabel = "Payment attempt proof"
            sessionHelp = "Screenshots of the app errors or failed payment attempts. Add the time you tried to pay and the zone."
        case .didNotPay:
            sessionLabel = "Parking app proof"
            sessionHelp = "Screenshot of the paid session, if you paid after all. The app checks the session covers the ticket time and the zone matches."
        }
        let sessionProof = EvidenceItem(
            kind: .sessionProof,
            label: sessionLabel,
            help: sessionHelp,
            ticket: ticket
        )
        let cardCharge = EvidenceItem(
            kind: .cardCharge,
            label: "Card or bank charge",
            help: "Screenshot of the parking payment on your card or bank statement.",
            ticket: ticket
        )
        let signs = EvidenceItem(
            kind: .signOrMeter,
            label: "Signs or meter photos (optional)",
            help: "Anything else that helps: sign photos, a broken meter, the curb.",
            ticket: ticket
        )
        return [ticketPhoto, sessionProof, cardCharge, signs]
    }
}
