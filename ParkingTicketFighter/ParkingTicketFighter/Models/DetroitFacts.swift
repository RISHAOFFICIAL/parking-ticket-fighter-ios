import Foundation

/// Verified Detroit filing facts. These come from the approved Stage 2
/// stories and Stage 6 build spec, and they override anything generic.
/// Detroit only in v1. Do not present other cities as supported.
enum DetroitFacts {
    static let cityName = "Detroit"

    /// Route 1: Administrative Review online.
    static let reviewWebsite = "parkdetroit.us"
    static let reviewWebsiteDisplay = "parkdetroit.us, choose Administrative Review"

    /// Route 2: mail the packet.
    static let mailRecipient = "Parking Violations Bureau"
    static let mailAddress = "P.O. Box 2549, Detroit, MI 48231-2549"

    /// Route 3: in person.
    static let inPersonAddress = "1001 Tenth Street, Detroit, MI 48216"

    /// Parking Violations Bureau phone.
    static let phone = "(313) 963-9630"

    /// Filing freezes penalties while the review is pending, and results
    /// come by mail, usually within about 30 days.
    static let filingFreezesPenalties = true
    static let resultByMailNote = "Results come by mail, usually within about 30 days. Penalties are frozen while you wait."

    /// Code 821 fine step up used across Detroit meter tickets:
    /// the $22.50 reduced fine only applies for Detroit residents with
    /// a plate registered in the City's Detroit Discount program, paid
    /// within 5 calendar days of issue. Otherwise the fine is $45.
    static let code821DiscountFine = 22.50
    static let code821FullFine = 45.00
    static let code821LateFeeNote = "An unresolved $45 ticket can add a $69 late fee."

    /// The packet is free during launch, matching the web build.
    /// The recorded plan is $15 per packet later, first ticket free.
    /// In this scaffold no payment is processed and no card is stored.
    static let packetPrice = 0.00
    static let packetPriceNote = "Your packet is built. Free during launch. If Detroit dismisses your ticket, you saved the fine and the late fee."

    /// The three filing routes, in the order screen S12 presents them.
    static let filingRoutes: [(title: String, detail: String)] = [
        ("Online", reviewWebsiteDisplay),
        ("By mail", "\(mailRecipient), \(mailAddress)"),
        ("In person", inPersonAddress)
    ]
}
