import Foundation
import UIKit
import Vision

/// The fields read off a ticket photo. Every field is optional: the
/// user confirms or corrects every field on Confirm Details (S4)
/// before anything is saved, and a missing field is typed by hand.
struct ParsedTicketFields {
    var number: String?
    var issueDate: Date?
    /// The raw date text as read, kept when the date could not be
    /// parsed so the confirm screen can show what was seen.
    var issueDateText: String?
    /// True when a date was found but it is impossible (a future date,
    /// or a year that cannot be right). The confirm screen flags it.
    var issueDateInvalid: Bool = false
    var zone: String?
    var location: String?
    var plate: String?
    var fineAmount: Double?
    var rawLines: [String] = []

    var anyFieldFound: Bool {
        number != nil || issueDate != nil || zone != nil
            || location != nil || plate != nil || fineAmount != nil
    }
}

/// The result of reading one or two ticket photos.
struct OCRReading: Identifiable {
    let id = UUID()
    var fields: ParsedTicketFields
    /// True when the photo looks like a parking ticket at all.
    /// When false, the app shows the not-a-ticket message.
    var looksLikeTicket: Bool

    /// True when the photo looks like a ticket but nothing useful
    /// could be read from it. The app shows the unreadable message.
    var isUnreadable: Bool {
        looksLikeTicket && !fields.anyFieldFound
    }
}

/// On-device ticket reading with Apple's Vision text recognition.
/// Free, private, no server: the photo never leaves the phone.
/// The reader only drafts fields; the user confirms every field on
/// Confirm Details (S4) before anything is saved.
///
/// Honest limit, stated in the docs too: do not claim OCR works until
/// it is verified with a real ticket photo. See
/// 07-native/ocr-verification-checklist.md for the test steps.
enum TicketOCR {

    /// Reads the text off the given photos (front, then back) and
    /// parses the ticket fields. Runs off the main thread.
    static func recognize(images: [UIImage]) async -> OCRReading {
        let lines = await Task.detached(priority: .userInitiated) {
            images.flatMap { recognizeLines(in: $0) }
        }.value
        let fields = parse(lines: lines)
        return OCRReading(fields: fields, looksLikeTicket: looksLikeTicket(lines: lines, fields: fields))
    }

    /// Runs one Vision text recognition pass over one image and
    /// returns the recognized lines, top to bottom.
    private static func recognizeLines(in image: UIImage) -> [String] {
        guard let cgImage = image.cgImage else { return [] }
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["en-US"]
        request.usesLanguageCorrection = true
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return []
        }
        guard let observations = request.results else { return [] }
        return observations.compactMap { $0.topCandidates(1).first?.string }
    }

    // MARK: - Field parsing (pure, testable without a photo)

    /// Parses ticket fields out of recognized text lines. Pure function:
    /// the verification checklist tests it against known ticket text
    /// without needing a camera or a photo.
    static func parse(lines: [String]) -> ParsedTicketFields {
        var fields = ParsedTicketFields(rawLines: lines)
        let joined = lines.joined(separator: "\n")
        let upper = joined.uppercased()

        fields.number = firstMatch(in: upper, patterns: [
            #"Y\d{8}"#,
            #"\b[A-Z]\d{7,9}\b"#
        ])

        fields.zone = firstCapture(in: upper, pattern: #"ZONE\s*#?\s*(\d{1,4})"#)
        fields.plate = firstCapture(in: upper, patterns: [
            #"PLATE\s*[:#]?\s*([A-Z0-9]{2,8})"#,
            #"LIC(?:ENSE)?\s*[:#]?\s*([A-Z0-9]{2,8})"#
        ])
        fields.location = parseLocation(lines: lines)
        fields.fineAmount = parseFine(lines: lines)

        let (date, dateText, invalid) = parseDate(from: upper)
        fields.issueDate = date
        fields.issueDateText = dateText
        fields.issueDateInvalid = invalid
        return fields
    }

    /// Decides whether the photo looks like a parking ticket at all.
    /// A ticket number is decisive on its own; otherwise at least two
    /// ticket words must appear. A photo of a receipt, a sign, or a
    /// random document should fail this check.
    static func looksLikeTicket(lines: [String], fields: ParsedTicketFields) -> Bool {
        if fields.number != nil { return true }
        let upper = lines.joined(separator: " ").uppercased()
        let signals = ["DETROIT", "PARKING", "VIOLATION", "TICKET", "METER",
                       "PARK DETROIT", "CITY OF", "FINE", "EXPIRED"]
        let hits = signals.filter { upper.contains($0) }.count
        return hits >= 2
    }

    // MARK: - Individual field parsers

    private static func parseLocation(lines: [String]) -> String? {
        for line in lines {
            let upper = line.uppercased()
            guard let range = upper.range(of: #"LOC(?:ATION)?\s*[:#]?\s*"#, options: .regularExpression) else { continue }
            let rest = String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
            let suffixes = [" ST", " AVE", " AVENUE", " BLVD", " SQ", " RD", " DR", " WAY", " PL"]
            if suffixes.contains(where: { rest.uppercased().contains($0) }) {
                return rest
            }
        }
        return nil
    }

    /// The fine amount: the first dollar amount on a line that talks
    /// about the fine, the amount due, or the total. Amounts on other
    /// lines (a session price, a meter number) are ignored.
    private static func parseFine(lines: [String]) -> Double? {
        for line in lines {
            let upper = line.uppercased()
            guard upper.contains("FINE") || upper.contains("AMOUNT") || upper.contains("DUE") || upper.contains("TOTAL") else { continue }
            if let amount = firstCapture(in: line, pattern: #"\$?\s*(\d{1,3}\.\d{2})"#),
               let value = Double(amount) {
                return value
            }
        }
        return nil
    }

    /// Parses the issue date and time. Handles 10/08/2026, 10/08/26,
    /// and OCT 8 2026 styles, plus a time like 8:47 AM on any line.
    /// Two digit years are read as 20xx (the web build's one live OCR
    /// test read a two digit year wrong, so this is explicit).
    /// A date in the future, or with a year before 2020, is impossible
    /// and flagged instead of returned.
    private static func parseDate(from upper: String) -> (Date?, String?, Bool) {
        let now = Date()
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: now)

        var components: DateComponents?
        var rawText: String?

        let numericPatterns = [
            #"(\d{1,2})/(\d{1,2})/(\d{2,4})"#,
            #"(\d{1,2})-(\d{1,2})-(\d{2,4})"#
        ]
        for pattern in numericPatterns {
            if let match = firstMatchGroups(in: upper, pattern: pattern), match.count == 3,
               let month = Int(match[0]), let day = Int(match[1]) {
                var year = Int(match[2]) ?? 0
                if year < 100 { year += 2000 }
                components = DateComponents(year: year, month: month, day: day)
                rawText = match.joined(separator: "/")
                break
            }
        }
        if components == nil {
            let months = ["JAN": 1, "FEB": 2, "MAR": 3, "APR": 4, "MAY": 5, "JUN": 6,
                          "JUL": 7, "AUG": 8, "SEP": 9, "OCT": 10, "NOV": 11, "DEC": 12]
            if let match = firstMatchGroups(in: upper, pattern: #"([A-Z]{3,9})\.?\s+(\d{1,2}),?\s+(\d{2,4})"#),
               match.count == 3,
               let month = months[String(match[0].prefix(3))],
               let day = Int(match[1]) {
                var year = Int(match[2]) ?? 0
                if year < 100 { year += 2000 }
                components = DateComponents(year: year, month: month, day: day)
                rawText = match.joined(separator: " ")
            }
        }

        guard var dateComponents = components, let text = rawText else {
            return (nil, nil, false)
        }
        if let time = firstMatchGroups(in: upper, pattern: #"(\d{1,2}):(\d{2})\s*(AM|PM)"#),
           time.count == 3,
           var hour = Int(time[0]), let minute = Int(time[1]) {
            if time[2] == "PM", hour < 12 { hour += 12 }
            if time[2] == "AM", hour == 12 { hour = 0 }
            dateComponents.hour = hour
            dateComponents.minute = minute
        }

        guard let year = dateComponents.year,
              year >= 2020, year <= currentYear,
              let date = calendar.date(from: dateComponents),
              date <= now else {
            return (nil, text, true)
        }
        return (date, text, false)
    }

    // MARK: - Regex helpers

    private static func firstMatch(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let found = firstMatch(in: text, pattern: pattern) { return found }
        }
        return nil
    }

    private static func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else { return nil }
        return String(text[range])
    }

    private static func firstCapture(in text: String, patterns: [String]) -> String? {
        for pattern in patterns {
            if let found = firstCapture(in: text, pattern: pattern) { return found }
        }
        return nil
    }

    private static func firstCapture(in text: String, pattern: String) -> String? {
        firstMatchGroups(in: text, pattern: pattern)?.first
    }

    private static func firstMatchGroups(in text: String, pattern: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) else { return nil }
        var groups: [String] = []
        for index in 1..<match.numberOfRanges {
            let range = match.range(at: index)
            guard range.location != NSNotFound, let swiftRange = Range(range, in: text) else { return nil }
            groups.append(String(text[swiftRange]))
        }
        return groups.isEmpty ? nil : groups
    }
}
