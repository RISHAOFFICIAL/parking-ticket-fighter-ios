import Foundation

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
struct Ticket: Identifiable, Codable, Hashable {
    var id: UUID
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
        city: String = "Detroit"
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

    /// The written statement drafted from the facts, mirroring screen S8.
    /// The user edits this in their own words before anything is filed.
    /// The app never files anything; the user files the packet themselves.
    var statementDraft: String {
        let time = issueDate.formatted(date: .omitted, time: .shortened)
        switch paidAnswer {
        case .paid:
            return "I paid for parking through the Park Detroit app for zone \(zone). The ticket was issued at \(time), inside that paid window. A copy of my session receipt and card charge is attached."
        case .triedToPay:
            return "I tried to pay for parking through the Park Detroit app for zone \(zone), but the payment did not go through. The ticket was issued at \(time). Screenshots of the app errors and my payment attempts are attached."
        case .didNotPay:
            return "I am contesting ticket \(number) issued in zone \(zone). My reasons and supporting evidence are attached."
        }
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
