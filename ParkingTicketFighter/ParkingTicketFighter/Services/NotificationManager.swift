import Foundation
import UserNotifications

/// Local notifications, no server needed (see
/// 07-native/notifications-plan.md). Every reminder names the ticket
/// number and the exact dollar amount at risk. Permission is asked
/// once, at the moment the first ticket is saved, never on first
/// launch. Reminders are rescheduled when a ticket is edited or filed,
/// and cancelled when a ticket is deleted or resolved.
///
/// Schedule, per ticket:
/// - Discount deadline minus 3 days (the $22.50 rate, with the Detroit
///   Discount registration and residency condition in the copy).
/// - Contest deadline minus 5 days and minus 1 day.
/// - 3 days after adding, if still not filed (filing freezes penalties).
/// - Filed but no result at day 30.
/// - Upheld payment deadline minus 3 days.
/// Reminders fire at 9:00 a.m. local time. Past dates are skipped.
enum NotificationManager {

    private static let permissionAskedKey = "notificationsPermissionAsked"

    /// Asks for notification permission once, at first ticket save.
    /// Later saves do nothing: the system prompt only ever shows once.
    static func requestPermissionIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: permissionAskedKey) else { return }
        UserDefaults.standard.set(true, forKey: permissionAskedKey)
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Cancels a ticket's old reminders and schedules the current set
    /// from its deadlines and status. Call after saving, editing,
    /// filing, or recording a result. Safe to call when permission was
    /// denied: it schedules nothing.
    static func schedule(for ticket: Ticket) async {
        cancel(for: ticket)
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        for reminder in reminders(for: ticket) {
            let content = UNMutableNotificationContent()
            content.title = "Beat the Meter"
            content.body = reminder.body
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: morningComponents(for: reminder.date),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: identifier(for: ticket, suffix: reminder.suffix),
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// Cancels every pending reminder for one ticket. Call on delete
    /// and before rescheduling.
    static func cancel(for ticket: Ticket) {
        let center = UNUserNotificationCenter.current()
        let prefix = "btm-\(ticket.id.uuidString)-"
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix(prefix) }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    /// Reschedules reminders for every ticket. Runs at launch as a
    /// safety net so reminders stay right even if a save was missed.
    static func rescheduleAll(_ tickets: [Ticket]) async {
        for ticket in tickets {
            await schedule(for: ticket)
        }
    }

    // MARK: - Reminder list

    private struct Reminder {
        let suffix: String
        let date: Date
        let body: String
    }

    private static func reminders(for ticket: Ticket) -> [Reminder] {
        var list: [Reminder] = []
        let calendar = Calendar.current
        let now = Date()
        let amount = Money.format(ticket.fineLater)

        func add(_ suffix: String, _ date: Date?, _ body: String) {
            guard let date, date > now else { return }
            list.append(Reminder(suffix: suffix, date: date, body: body))
        }

        switch ticket.status {
        case .notFiled, .packetBuilt:
            let discountDate = ticket.discountDeadline.formatted(date: .abbreviated, time: .omitted)
            add("discount", calendar.date(byAdding: .day, value: -3, to: ticket.discountDeadline),
                "Discount ends in 3 days. Settle ticket \(ticket.number) for \(Money.format(ticket.fineNow)) by \(discountDate), if your plate is registered in the Detroit Discount program.")
            let contestDate = ticket.contestDeadline.formatted(date: .abbreviated, time: .omitted)
            add("contest-5", calendar.date(byAdding: .day, value: -5, to: ticket.contestDeadline),
                "5 days left to fight ticket \(ticket.number). Your contest deadline is \(contestDate). \(amount) is at risk.")
            add("contest-1", calendar.date(byAdding: .day, value: -1, to: ticket.contestDeadline),
                "Tomorrow is the last day to contest ticket \(ticket.number). \(amount) is at risk.")
            add("file-nudge", calendar.date(byAdding: .day, value: 3, to: ticket.createdAt),
                "Ticket \(ticket.number) is ready to file. Filing freezes the penalties, so file soon. \(amount) is at risk.")
        case .filedWaiting:
            if let checkDate = ticket.resultCheckDate {
                add("result-check", checkDate,
                    "Did your letter arrive for ticket \(ticket.number)? Open Beat the Meter to record the result. \(amount) was at stake.")
            }
        case .upheld:
            if let deadline = ticket.resultPaymentDeadline {
                let owed = Money.format(ticket.resultAmountOwed ?? ticket.fineLater)
                let due = deadline.formatted(date: .abbreviated, time: .omitted)
                add("upheld-pay", calendar.date(byAdding: .day, value: -3, to: deadline),
                    "Payment for ticket \(ticket.number) is due in 3 days. You owe \(owed). Pay by \(due) to avoid more fees.")
            }
        case .dismissed, .paid:
            break
        }
        return list
    }

    private static func identifier(for ticket: Ticket, suffix: String) -> String {
        "btm-\(ticket.id.uuidString)-\(suffix)"
    }

    /// 9:00 a.m. on the reminder date, local time.
    private static func morningComponents(for date: Date) -> DateComponents {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 9
        components.minute = 0
        return components
    }
}
