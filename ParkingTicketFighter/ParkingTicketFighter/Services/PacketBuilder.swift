import Foundation
import UIKit

/// Builds the contest packet (S9) as a PDF the user can file: cover
/// summary, statement, ticket photo, evidence pages, deadlines page.
/// The packet is free during launch; no payment step is involved.
/// The app never files anything itself; the user files the packet
/// with the City of Detroit using the filing instructions inside it.
enum PacketBuilder {

    private static let pageSize = CGSize(width: 612, height: 792)
    private static let margin: CGFloat = 48

    private static let titleFont = UIFont(name: "Georgia-Bold", size: 22) ?? .boldSystemFont(ofSize: 22)
    private static let headingFont = UIFont(name: "Georgia-Bold", size: 15) ?? .boldSystemFont(ofSize: 15)
    private static let bodyFont = UIFont.systemFont(ofSize: 12)
    private static let smallFont = UIFont.systemFont(ofSize: 10)
    private static let ink = UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1)
    private static let signal = UIColor(red: 0.784, green: 0.063, blue: 0.180, alpha: 1)

    /// Renders the full packet PDF for a ticket.
    static func buildPDF(for ticket: Ticket) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = [
            kCGPDFContextTitle as String: "Beat the Meter contest packet, ticket \(ticket.number)",
            kCGPDFContextAuthor as String: "Beat the Meter"
        ]
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: pageSize), format: format)
        return renderer.pdfData { context in
            drawCover(ticket, in: context)
            drawStatement(ticket, in: context)
            drawTicketPhotos(ticket, in: context)
            drawEvidence(ticket, in: context)
            drawDeadlines(ticket, in: context)
        }
    }

    /// Writes the packet PDF to a temp file and returns its URL, for
    /// ShareLink and Save to Files. Returns nil if the write fails.
    static func packetURL(for ticket: Ticket) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("BeatTheMeter-Packet-\(ticket.number).pdf")
        do {
            try buildPDF(for: ticket).write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Pages

    private static func drawCover(_ ticket: Ticket, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = margin
        y = drawText("BEAT THE METER", font: titleFont, at: y, in: context)
        y = drawText("Contest packet, City of Detroit", font: headingFont, at: y + 4, in: context)
        y = drawRule(at: y + 8, in: context)
        y += 12
        y = drawText("Ticket \(ticket.number)", font: headingFont, at: y, in: context)
        y += 8
        y = drawRow("Issued", ticket.issueDate.formatted(date: .abbreviated, time: .shortened), at: y, in: context)
        y = drawRow("Zone", ticket.zone, at: y, in: context)
        y = drawRow("Location", ticket.location.isEmpty ? "Not recorded" : ticket.location, at: y, in: context)
        y = drawRow("Plate", ticket.plate, at: y, in: context)
        y = drawRow("Code", ticket.code, at: y, in: context)
        y = drawRow("City", ticket.city, at: y, in: context)
        y = drawRow("You said", ticket.paidAnswer.rawValue, at: y, in: context)
        y = drawRow("Case check", ticket.verdict.rawValue, at: y, in: context)
        y += 12
        y = drawText("Deadlines", font: headingFont, at: y, in: context)
        y = drawText("Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted)) (Detroit Discount rate, registered Detroit plates only).", font: bodyFont, at: y + 4, in: context, color: signal)
        y = drawText("Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted)).", font: bodyFont, at: y + 4, in: context, color: signal)
        y += 16
        y = drawText("File this packet one of three ways: online at \(DetroitFacts.reviewWebsiteDisplay); by mail to \(DetroitFacts.mailRecipient), \(DetroitFacts.mailAddress); or in person at \(DetroitFacts.inPersonAddress). Questions: \(DetroitFacts.phone).", font: bodyFont, at: y, in: context)
        y += 12
        _ = drawText("Guidance only, not legal advice. Beat the Meter prepares your packet. You file it.", font: smallFont, at: y, in: context)
    }

    private static func drawStatement(_ ticket: Ticket, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = margin
        y = drawText("Your statement", font: headingFont, at: y, in: context)
        y = drawRule(at: y + 8, in: context)
        y += 12
        y = drawText(ticket.statement, font: bodyFont, at: y, in: context)
        y += 24
        y = drawText("Sign only what is true.", font: bodyFont, at: y, in: context)
        y += 24
        _ = drawText("Signature: ______________________________________     Date: ________________", font: bodyFont, at: y, in: context)
    }

    private static func drawTicketPhotos(_ ticket: Ticket, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = margin
        y = drawText("Ticket photos", font: headingFont, at: y, in: context)
        y = drawRule(at: y + 8, in: context)
        y += 12
        var drewPhoto = false
        if let front = ticket.frontPhotoData, let image = UIImage(data: front) {
            y = drawText("Front of ticket", font: bodyFont, at: y, in: context)
            y = drawImage(image, at: y + 4, in: context)
            drewPhoto = true
        }
        if let back = ticket.backPhotoData, let image = UIImage(data: back) {
            y = drawText("Back of ticket", font: bodyFont, at: y + 12, in: context)
            y = drawImage(image, at: y + 4, in: context)
            drewPhoto = true
        }
        if !drewPhoto {
            _ = drawText("No ticket photo attached. Add one from the ticket detail screen.", font: bodyFont, at: y, in: context)
        }
    }

    private static func drawEvidence(_ ticket: Ticket, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = margin
        y = drawText("Evidence", font: headingFont, at: y, in: context)
        y = drawRule(at: y + 8, in: context)
        y += 12
        let items = ticket.evidence.filter { $0.kind != .ticketPhoto }
        if items.isEmpty {
            _ = drawText("No evidence items recorded.", font: bodyFont, at: y, in: context)
            return
        }
        for item in items {
            switch item.state {
            case .present:
                y = drawText(item.label, font: headingFont, at: y, in: context)
                if item.kind == .sessionProof, let text = item.sessionMatchText(for: ticket) {
                    y = drawText(text, font: bodyFont, at: y + 2, in: context)
                }
                if let photoData = item.photoData, let image = UIImage(data: photoData) {
                    y = drawImage(image, at: y + 4, in: context)
                } else {
                    y = drawText("Recorded as present. No photo attached.", font: bodyFont, at: y + 2, in: context)
                }
            case .missing:
                y = drawText("\(item.label): not available. The user does not have this item.", font: bodyFont, at: y, in: context)
            case .notSet:
                y = drawText("\(item.label): not recorded.", font: bodyFont, at: y, in: context)
            }
            y += 12
            if y > pageSize.height - margin - 80 {
                context.beginPage()
                y = margin
            }
        }
    }

    private static func drawDeadlines(_ ticket: Ticket, in context: UIGraphicsPDFRendererContext) {
        context.beginPage()
        var y = margin
        y = drawText("Deadlines and filing", font: headingFont, at: y, in: context)
        y = drawRule(at: y + 8, in: context)
        y += 12
        y = drawText("Pay \(Money.format(ticket.fineNow)) by \(ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted)).", font: bodyFont, at: y, in: context, color: signal)
        y = drawText("The \(Money.format(ticket.fineNow)) rate is only for Detroit residents with a plate registered in the City's Detroit Discount program. After the discount date the fine steps up to \(Money.format(ticket.fineLater)). \(DetroitFacts.code821LateFeeNote)", font: bodyFont, at: y + 4, in: context)
        y = drawText("Contest by \(ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted)).", font: bodyFont, at: y + 8, in: context, color: signal)
        y += 12
        y = drawText("Where to file", font: headingFont, at: y, in: context)
        for route in DetroitFacts.filingRoutes {
            y = drawText("\(route.title): \(route.detail)", font: bodyFont, at: y + 4, in: context)
        }
        y = drawText("Phone: \(DetroitFacts.phone)", font: bodyFont, at: y + 4, in: context)
        y += 12
        _ = drawText(DetroitFacts.resultByMailNote, font: bodyFont, at: y, in: context)
    }

    // MARK: - Drawing helpers

    private static var contentWidth: CGFloat { pageSize.width - margin * 2 }

    /// Draws wrapped text starting at y and returns the y below it.
    @discardableResult
    private static func drawText(
        _ text: String,
        font: UIFont,
        at y: CGFloat,
        in context: UIGraphicsPDFRendererContext,
        color: UIColor = ink
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let height = attributed.boundingRect(
            with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height
        attributed.draw(in: CGRect(x: margin, y: y, width: contentWidth, height: height))
        return y + height + 4
    }

    @discardableResult
    private static func drawRow(_ label: String, _ value: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        drawText("\(label): \(value)", font: bodyFont, at: y, in: context)
    }

    @discardableResult
    private static func drawRule(at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let cgContext = context.cgContext
        cgContext.setFillColor(ink.cgColor)
        cgContext.fill(CGRect(x: margin, y: y, width: contentWidth, height: 6))
        return y + 6
    }

    /// Draws a photo scaled to fit the content width, at most 320 points
    /// tall, and returns the y below it.
    @discardableResult
    private static func drawImage(_ image: UIImage, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let maxHeight: CGFloat = 320
        let aspect = image.size.height / max(image.size.width, 1)
        let height = min(contentWidth * aspect, maxHeight)
        let width = height / max(aspect, 0.01)
        image.draw(in: CGRect(x: margin, y: y, width: width, height: height))
        return y + height + 4
    }
}
