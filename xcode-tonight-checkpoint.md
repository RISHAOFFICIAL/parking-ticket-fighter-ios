# Xcode Tonight Checkpoint, Parking Ticket Fighter iOS
Started Nov 8, 2026, evening. Goal: first Xcode compile and TestFlight build tonight.

## What was already true
- Scaffold built Oct 15, 2026 at 07-native/ParkingTicketFighter/. Tabs Home / My Tickets / Add Ticket / More. Bundle id com.hghmanagementgroup.parkingticketfighter. iOS 26.0 target. No development team set. Not compile verified, not pushed to GitHub.
- Apple Developer Program enrolled Sept 11, 2026 under erishasmith0723@gmail.com, so the README step 1 (join the program) is already done.
- gh CLI on this VM is signed in as RISHAOFFICIAL (used Nov 7 for the landing page repo), so the push from here works now.

## Bugs found in the scaffold before the build (must fix first)
- [x] Discount deadline math is 14 days, wrong. Must be issue + 5 days (Detroit Discount window). Oct 8, 2026 ticket: discount Oct 13, 2026 (not Oct 22). Oct 9 ticket: Oct 14. Oct 6 ticket: Oct 11. Contest stays issue + 30 days. FIXED Nov 8, 2026.
- [x] Discount wording presents $22.50 as available to anyone who pays early. Must carry the condition everywhere: only for Detroit residents with a plate registered in the City's Detroit Discount program. FIXED Nov 8, 2026.
- [x] Packet price is $19 in DetroitFacts. Web app is free during launch, so the native app matches: free during launch. Recorded plan is $15 per packet later, first ticket free. FIXED Nov 8, 2026.
- [x] README-XCODE-CLOUD.md still says 14 days and Oct 22. Fix to 5 days and Oct 13. FIXED Nov 8, 2026.
- [x] notifications-plan.md discount alert copy needs the same condition. FIXED Nov 8, 2026.

## Units, in order
1. Fix Ticket.swift (discountWindowDays 14 to 5, comments, fineNow doc). DONE.
2. Fix DetroitFacts.swift (discount comment, packet price to free during launch). DONE.
3. Fix TicketDetailView.swift (weak verdict reason, deadlines footnote, packet price text). DONE.
4. Fix AddTicketView.swift (footer condition). DONE.
5. Fix README-XCODE-CLOUD.md and notifications-plan.md. DONE.
6. Verify by grep: no 14-day discount math left, no bare $22.50 claim left. DONE Nov 8, 2026. Only 14-day mentions left are the historical notes in this checkpoint and the notifications plan saying it was corrected.
7. Push to GitHub as RISHAOFFICIAL/parking-ticket-fighter-ios. DONE Nov 8, 2026. Repo: https://github.com/RISHAOFFICIAL/parking-ticket-fighter-ios, main branch, pushed from this workspace.
8. Risha opens the project in Xcode on her Mac, signs in, automatic signing, first compile. IN PROGRESS Nov 8, 2026 evening. She cloned the repo and opened the project. Xcode showed the target as Mac only (Supported Destinations: Mac, run destination My Mac). Cause: the pbxproj has iOS settings (deployment target 26.0, device family 1,2) but no SDKROOT or SUPPORTED_PLATFORMS, so Xcode 27 defaulted the target to Mac. Fix: click + under Supported Destinations and add iPhone (and iPad). First compile then ran and produced 1 error (see unit 9).
9. Fix pass from the Xcode build log she sends. IN PROGRESS Nov 8, 2026 evening. First compile error: Type 'ShapeStyle' has no member 'forest' in MoreView (`.foregroundStyle(.forest)`). Same pattern also in HomeView (`.forest`) and TicketDetailView (`.urgent`). Cause: `foregroundStyle` takes a generic ShapeStyle, and a plain `Color` extension is not visible in that position. FIXED Nov 8, 2026: added `extension ShapeStyle where Self == Color` for all five brand colors (forest, ivory, brass, urgent, success) in Components/GlassComponents.swift. Pushed as commit 4da4b40. Risha pulls in Xcode and rebuilds. The "Update to recommended settings" warning is non-blocking, ignore for now.
10. Create the Xcode Cloud workflow in Xcode, first cloud build, TestFlight.

## Open questions for Risha (Mac session)
- What iPhone model and iOS version is she on? The project targets iOS 26.0.
- App Store Connect: is the paid apps agreement current (only matters when charging; TestFlight of a free app does not need it).
- Supabase project: deferred. Not needed for the first TestFlight build of the scaffold, only when saving is wired up.

## What this scaffold is not
- Not the full 21 screen port. Stubs are labeled. Saving is not wired up yet, sample tickets stand in for saved records. No OCR, no AI, no payment. Detroit only. The app never files anything.
