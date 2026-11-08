# Parking Ticket Fighter, Native Push Notifications Plan
Decision by Risha November 2, 2026: real phone notifications ship with the native iPhone app, once the scaffold is in Xcode and compiling. The web artifact cannot send phone push notifications, so this was never a web feature.

## Approach: local notifications, no server needed
- Use UNUserNotificationCenter local notifications. No push server, no APNs certificate, no backend.
- Request notification permission once, at the moment the first ticket is saved (not on first launch).
- Schedule per ticket, at save time and on any edit of the issue date:
  - Discount deadline minus 3 days: "Discount ends in 3 days. Settle ticket {number} for $22.50 by {date}, if your plate is registered in the Detroit Discount program."
  - The $22.50 in that alert only applies for Detroit residents with a plate registered in the Detroit Discount program.
  - Contest deadline minus 3 days: "3 days left to fight ticket {number}. Your contest packet is ready."
  - Contest deadline day morning: "Today is the last day to contest ticket {number}."
- Cancel and reschedule a ticket's notifications when it is edited or deleted.
- Reminder list in the app stays the source of truth; notifications mirror it.

## Xcode prerequisites (still open, from October 2026)
- The one-time Xcode Cloud workflow step, App Store Connect agreement check, her iPhone model and iOS version. Bundle ID is decided: com.hghmanagementgroup.parkingticketfighter. App name is decided: Parking Ticket Fighter. Supabase project creation is deferred, it is not needed for the first TestFlight build of the scaffold, only when saving is wired up.
- Scaffold at 07-native/ is not compile verified; expect a small fix pass on first build. Discount deadline corrected Nov 8, 2026 from 14 days to 5 days, and the $22.50 wording now carries the Detroit Discount registration and residency conditions.

## Copy rules
- No em dashes. Plain language, ticket number and dates in every alert.
- Notifications are reminders, not legal advice.
