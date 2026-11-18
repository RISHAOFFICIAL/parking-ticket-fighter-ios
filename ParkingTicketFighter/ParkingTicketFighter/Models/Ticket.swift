import Foundation
import SwiftData

/// The answer to the one question on screen S5 of the approved flow:
/// "When this ticket was written, had you paid for parking?"
enum PaidAnswer: String, Codable, CaseIterable, Identifiable {
    case paid = "Yes, I paid"
    case triedToPay = "I tried to pay but the app or meter failed"
    case didNotPay = "No"

    var id: String { rawValue }
}

/// Plain language case check verdicts from screen S6 of the approved flow.
enum CaseVerdict: String, Codable, CaseIterable {
    case strong = "Strong"
    case worthFiling = "Worth filing"
    case weak = "Weak"
}

/// Ticket lifecycle, matching the Stage 6 build spec status tracking.
enum TicketStatus: String, Codable, CaseIterable {
    case notFiled = "Not filed"
    case packetBuilt = "Packet built"
    case filedWaiting = "Filed, waiting on result"
    case dismissed = "Dismissed"
    case upheld = "Upheld"
    case paid = "Paid"

    /// Open means the ticket still needs attention or a result.
    var isOpen: Bool {
        switch self {
        case .notFiled, .packetBuilt, .filedWaiting:
            return true
        case .dismissed, .upheld, .paid:
            return false
        }
    }
}

/// How a packet was filed with the City of Detroit (screen S13).
enum FilingMethod: String, Codable, CaseIterable {
    case online = "Online at parkdetroit.us"
    case mail = "By mail"
    case inPerson = "In person"
}

/// One parking ticket. Field set matches the minimum data model in the
/// Stage 6 build spec (06-build/build-spec.md).
///
/// This is a SwiftData model (`@Model`), so tickets are saved on the
/// device and survive app relaunches. The enums above are `String,
/// Codable`, so SwiftData stores them as their raw values. Computed
/// properties (deadlines, statement draft) are not stored; they are
/// recalculated from the stored fields every time they are read.
/// `@Model` provides Identifiable and Hashable, so `Ticket` still
/// works with `ForEach`, `NavigationLink(value:)`, and
/// `navigationDestination(for:)` exactly as the struct did.
@Model
final class Ticket {
    var id: UUID = UUID()
    var number: String
    var issueDate: Date
    var zone: String
    var location: String
    var plate: String
    var code: String
    /// What the fine costs if paid inside the discount window.
    /// The reduced fine only applies for Detroit residents with a plate
    /// registered in the City's Detroit Discount program.
    var fineNow: Double
    /// What the fine steps up to after the discount window (Code 821 in Detroit).
    var fineLater: Double
    var paidAnswer: PaidAnswer
    var verdict: CaseVerdict
    var status: TicketStatus
    var filedDate: Date?
    var filedMethod: FilingMethod?
    var city: String
    /// When the ticket was added. Drives the "file within 3 days" nudge.
    var createdAt: Date
    /// Front and back photos of the ticket, attached as evidence.
    /// A photo that cannot be read stays attached either way.
    /// Stored outside the database file so the store stays small.
    @Attribute(.externalStorage) var frontPhotoData: Data?
    @Attribute(.externalStorage) var backPhotoData: Data?
    /// Photo of the filing confirmation or mailing receipt (S12/S13).
    @Attribute(.externalStorage) var filingReceiptData: Data?
    /// The statement in the user's own words (S8). Nil means the
    /// generated draft is in use; see `statement`.
    var statementText: String?
    /// The evidence checklist (S7). Deleted with the ticket.
    @Relationship(deleteRule: .cascade, inverse: \EvidenceItem.ticket)
    var evidence: [EvidenceItem] = []
    /// Result check-in (S15): "Not yet" snoozes the check by 2 weeks.
    var resultCheckSnoozedUntil: Date?
    /// Upheld result: what is now owed and the deadline to pay it,
    /// taken from the result letter.
    var resultAmountOwed: Double?
    var resultPaymentDeadline: Date?

    init(
        id: UUID = UUID(),
        number: String,
        issueDate: Date,
        zone: String,
        location: String,
        plate: String,
        code: String,
        fineNow: Double,
        fineLater: Double,
        paidAnswer: PaidAnswer,
        verdict: CaseVerdict,
        status: TicketStatus,
        filedDate: Date? = nil,
        filedMethod: FilingMethod? = nil,
        city: String = "Detroit",
        createdAt: Date = Date(),
        frontPhotoData: Data? = nil,
        backPhotoData: Data? = nil,
        filingReceiptData: Data? = nil,
        statementText: String? = nil,
        resultCheckSnoozedUntil: Date? = nil,
        resultAmountOwed: Double? = nil,
        resultPaymentDeadline: Date? = nil
    ) {
        self.id = id
        self.number = number
        self.issueDate = issueDate
        self.zone = zone
        self.location = location
        self.plate = plate
        self.code = code
        self.fineNow = fineNow
        self.fineLater = fineLater
        self.paidAnswer = paidAnswer
        self.verdict = verdict
        self.status = status
        self.filedDate = filedDate
        self.filedMethod = filedMethod
        self.city = city
        self.createdAt = createdAt
        self.frontPhotoData = frontPhotoData
        self.backPhotoData = backPhotoData
        self.filingReceiptData = filingReceiptData
        self.statementText = statementText
        self.resultCheckSnoozedUntil = resultCheckSnoozedUntil
        self.resultAmountOwed = resultAmountOwed
        self.resultPaymentDeadline = resultPaymentDeadline
    }

    /// Discount deadline: 5 days after the issue date.
    /// This is the City of Detroit's Detroit Discount window for
    /// registered Detroit plates: pay within 5 calendar days of issue.
    /// A ticket issued October 8, 2026 has a discount deadline of
    /// October 13, 2026. A ticket issued October 9, 2026 has a
    /// discount deadline of October 14, 2026.
    var discountDeadline: Date {
        Calendar.current.date(byAdding: .day, value: DeadlineRules.discountWindowDays, to: issueDate) ?? issueDate
    }

    /// Contest deadline: 30 days after the issue date.
    /// Verified against the approved build record: a ticket issued
    /// October 8, 2026 has a contest deadline of November 7, 2026.
    var contestDeadline: Date {
        Calendar.current.date(byAdding: .day, value: DeadlineRules.contestWindowDays, to: issueDate) ?? issueDate
    }

    /// True when a deadline that still matters has already passed,
    /// which routes the ticket to the honest "deadline passed" state
    /// from the approved flow instead of the contest path.
    var contestDeadlinePassed: Bool {
        status.isOpen && contestDeadline < Date()
    }

    /// Money still at risk while the ticket is open.
    var amountAtRisk: Double {
        status.isOpen ? fineLater : 0
    }

    /// Money saved when Detroit dismisses the ticket: the fine that
    /// would otherwise have been owed. Feeds the lifetime total on Home.
    var amountSaved: Double {
        status == .dismissed ? fineLater : 0
    }

    /// The session proof item, when the ticket has one.
    var sessionEvidence: EvidenceItem? {
        evidence.first { $0.kind == .sessionProof }
    }

    /// Defenses found by the defense checker (S10).
    var defenseEvidence: [EvidenceItem] {
        evidence.filter { $0.kind == .defense && $0.state == .present }
    }

    /// The statement as it will go in the packet: the user's edited
    /// words when they have edited it, otherwise the generated draft.
    var statement: String {
        statementText ?? statementDraft
    }

    /// The written statement drafted from the facts, mirroring screen S8.
    /// The user edits this in their own words before anything is filed.
    /// The app never files anything; the user files the packet themselves.
    /// When the paid session is on record, the draft names its window;
    /// facts the app does not have are never invented.
    var statementDraft: String {
        let time = issueDate.formatted(date: .omitted, time: .shortened)
        switch paidAnswer {
        case .paid:
            if let session = sessionEvidence,
               let start = session.sessionStart,
               let end = session.sessionEnd {
                let startText = start.formatted(date: .omitted, time: .shortened)
                let endText = end.formatted(date: .omitted, time: .shortened)
                return "I paid for parking through the Park Detroit app for zone \(zone). My session ran \(startText) to \(endText). The ticket was issued at \(time), inside that paid window. A copy of my session receipt and card charge is attached."
            }
            return "I paid for parking through the Park Detroit app for zone \(zone). The ticket was issued at \(time), inside that paid window. A copy of my session receipt and card charge is attached."
        case .triedToPay:
            return "I tried to pay for parking through the Park Detroit app for zone \(zone), but the payment did not go through. The ticket was issued at \(time). Screenshots of the app errors and my payment attempts are attached."
        case .didNotPay:
            if let defense = defenseEvidence.first {
                return "I am contesting ticket \(number) issued in zone \(zone). \(defense.note) Supporting evidence is attached."
            }
            return "I am contesting ticket \(number) issued in zone \(zone). My reasons and supporting evidence are attached."
        }
    }

    /// Recomputes the verdict from the full S6 case check (answers,
    /// evidence present or missing, session match, defenses found).
    /// Call after any evidence change or answer change, then save.
    func refreshVerdict() {
        verdict = CaseCheck.evaluate(self).verdict
    }

    /// The day-30 result check date (S15), counted from filing.
    var resultCheckDate: Date? {
        guard let filedDate else { return nil }
        return Calendar.current.date(
            byAdding: .day,
            value: DeadlineRules.resultCheckDaysAfterFiling,
            to: filedDate
        )
    }

    /// True when the day-30 "Did your letter arrive?" check-in is due:
    /// filed and waiting, 30 days past filing, and not snoozed.
    var resultCheckDue: Bool {
        guard status == .filedWaiting, let checkDate = resultCheckDate else { return false }
        if let snoozedUntil = resultCheckSnoozedUntil, snoozedUntil > Date() { return false }
        return checkDate <= Date()
    }
}

/// The deadline rules, kept in one place so every screen agrees.
enum DeadlineRules {
    static let discountWindowDays = 5
    static let contestWindowDays = 30
    /// Results come by mail, usually within about 30 days of filing.
    static let resultCheckDaysAfterFiling = 30
    /// Reminder offsets from the approved flow's reminders engine.
    static let discountReminderDaysBefore = 3
    static let contestReminderDaysBefore = [5, 1]
}
