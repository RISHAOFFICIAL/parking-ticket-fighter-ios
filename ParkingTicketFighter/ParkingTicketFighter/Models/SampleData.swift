import Foundation

/// Sample tickets for previews and the scaffold's first run.
/// These use only the verified facts already recorded in the project
/// files (real tickets from October 2026, plate 7PAC20, all Code 821).
/// They are the same examples the approved hi-fi prototype used.
enum SampleData {

    private static func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int, _ minute: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components) ?? Date()
    }

    /// Ticket 2 from the project record. Zone 103, Brush St.
    /// The Park Detroit app showed "Payment has not been processed"
    /// errors that morning. Filed October 12, 2026.
    static let appFailureTicket = Ticket(
        number: "Y18981274",
        issueDate: date(2026, 10, 8, 8, 32),
        zone: "103",
        location: "Brush St",
        plate: "7PAC20",
        code: "821",
        fineNow: 22.50,
        fineLater: 45.00,
        paidAnswer: .triedToPay,
        verdict: .worthFiling,
        status: .filedWaiting,
        filedDate: date(2026, 10, 12, 8, 39),
        filedMethod: .online
    )

    /// Ticket 3 from the project record. Zone 105, Cadillac Sq.
    /// The cleanest case: a paid session from 8:01 to 10:01 a.m. covers
    /// the 8:47 a.m. ticket time, and the zone matches.
    static let paidSessionTicket = Ticket(
        number: "Y18776021",
        issueDate: date(2026, 10, 9, 8, 47),
        zone: "105",
        location: "Cadillac Sq",
        plate: "7PAC20",
        code: "821",
        fineNow: 22.50,
        fineLater: 45.00,
        paidAnswer: .paid,
        verdict: .strong,
        status: .filedWaiting,
        filedDate: date(2026, 10, 12, 8, 42),
        filedMethod: .online
    )

    /// Ticket 1 from the project record. Zone 105.
    /// Written during a paid session (10:03 a.m. to 12:03 p.m.).
    /// Filed October 8, 2026.
    static let firstTicket = Ticket(
        number: "Y18973750",
        issueDate: date(2026, 10, 6, 11, 2),
        zone: "105",
        location: "Zone 105 metered parking",
        plate: "7PAC20",
        code: "821",
        fineNow: 22.50,
        fineLater: 45.00,
        paidAnswer: .paid,
        verdict: .worthFiling,
        status: .filedWaiting,
        filedDate: date(2026, 10, 8, 9, 0),
        filedMethod: .online
    )

    static let tickets: [Ticket] = [appFailureTicket, paidSessionTicket, firstTicket]

    /// The default evidence checklist from screen S7, one ticket at a time.
    static let evidenceChecklist: [(label: String, help: String, isDone: Bool)] = [
        ("Ticket photo", "Already attached when you add the ticket.", true),
        ("Parking app proof", "Screenshot of the paid session. The app checks the session covers the ticket time and the zone matches.", false),
        ("Card or bank charge", "Screenshot of the parking payment on your card or bank statement.", false),
        ("Signs or meter photos (optional)", "Anything else that helps: sign photos, a broken meter, the curb.", false)
    ]

    /// Money totals for the Home summary, computed from the sample set
    /// the same way the finished app computes them from saved records.
    static var totalAtRisk: Double {
        tickets.reduce(0) { $0 + $1.amountAtRisk }
    }
}
