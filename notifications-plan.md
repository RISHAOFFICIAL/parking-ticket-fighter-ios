# Parking Ticket Fighter, Native Push Notifications Plan
Decision by Risha November 2, 2026: real phone notifications ship with the native iPhone app, once the scaffold is in Xcode and compiling. The web artifact cannot send phone push notifications, so this was never a web feature.

## Approach: local notifications, no server needed
- Use UNUserNotificationCenter local notifications. No push server, no APNs certificate, no backend.
- Request notification permission once, at the moment the first ticket is saved (not on first launch).
- Schedule per ticket, at save time and on any edit of the issue date:
  - Discount deadline minus 3 days: "Discount ends in 3 days. Settle ticket {number} for $22.50 by {date}, if your plate is registered in the Detroit Discount program."
  - The $22.50 in that alert only applies for Detroit residents with a plate registered in the Detroit Discount program.
  - Contest deadline minus 5 days: "5 days left to fight ticket {number}. Your contest deadline is {date}. {amount} is at risk."
  - Contest deadline minus 1 day: "Tomorrow is the last day to contest ticket {number}. {amount} is at risk."
  - Not filed within 3 days of adding: "Ticket {number} is ready to file. Filing freezes the penalties, so file soon. {amount} is at risk."
  - Filed but no result at day 30: "Did your letter arrive for ticket {number}? Open Beat the Meter to record the result. {amount} was at stake."
  - Upheld payment deadline minus 3 days: "Payment for ticket {number} is due in 3 days. You owe {amount}. Pay by {date} to avoid more fees."
  - Every reminder names the ticket number and the exact dollar amount at risk. Reminders fire at 9:00 a.m. local time. Past dates are skipped.
- Cancel and reschedule a ticket's notifications when it is edited, filed, or deleted, and when a result is recorded. A launch refresh reschedules every ticket's reminders from its current deadlines and status.
- Reminder list in the app stays the source of truth; notifications mirror it.

## Correction (Nov 18, 2026)
- This plan previously said contest deadline minus 3 days and contest
  deadline day morning. The approved flow (Stage 3) and the
  functionality list both say contest deadline minus 5 days and minus
  1 day, so the plan is corrected to match, and the not-filed nudge,
  day-30 result check, and upheld payment reminders are added. The
  implementation (Services/NotificationManager.swift) follows this
  corrected schedule.

## Implemented (Nov 18, 2026)
- NotificationManager schedules and cancels per ticket as above.
  Permission is asked at first ticket save (AddTicketView). Delete
  cancels (TicketDetailView). Filing, result check-in, and the pay
  path reschedule. ContentView refreshes all reminders at launch.
  Not yet verified on a device: confirm a reminder fires with the
  right ticket number and amount (see the testing notes in
  functionality-list.md).

## Xcode prerequisites (still open, from October 2026)
- The one-time Xcode Cloud workflow step, App Store Connect agreement check, her iPhone model and iOS version. Bundle ID is decided: com.hghmanagementgroup.parkingticketfighter. App name is decided: Parking Ticket Fighter. Supabase project creation is deferred, it is not needed for the first TestFlight build of the scaffold, only when saving is wired up.
- Scaffold at 07-native/ is not compile verified; expect a small fix pass on first build. Discount deadline corrected Nov 8, 2026 from 14 days to 5 days, and the $22.50 wording now carries the Detroit Discount registration and residency conditions.

## Copy rules
- No em dashes. Plain language, ticket number and dates in every alert.
- Notifications are reminders, not legal advice.
