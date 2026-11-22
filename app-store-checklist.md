# Beat the Meter: App Store Pre-Submission Checklist

Built Nov 22, 2026, from the actual state of the repo, not from a guess.

## The short answer

The idea is fine. Apps that fight tickets are already on the App Store (DoNotPay is the big one). Apple would reject this build for the unfinished pieces, not the concept. Fix the list below, in this order, then submit.

## The order of work

1. TestFlight first. Get the app in testers' hands and prove it works outside the simulator.
2. Fix the list. The items below.
3. Submit for review.

## Phase 1: TestFlight (do this first)

- [ ] App Store Connect access. Ashton needs a Developer role, and the access to upload has to come from Risha's accounts. This is the only step that needs Risha directly.
- [ ] First upload. Either the first Xcode Cloud build, or archive from her Mac and upload to App Store Connect.
- [ ] Install on a real iPhone. Add internal TestFlight testers, install the build on a real phone, and run the full fight flow once outside the simulator.

## Phase 2: The fix list (Apple would reject for these)

### Release blockers

- [ ] Remove the sample ticket seed. The three sample tickets (Y18973750, Y18981274, Y18776021, plate 7PAC20) load on first launch. A real user must never see someone else's tickets. (ContentView.swift, seedSampleTicketsIfNeeded. Delete before release.)
- [ ] Finish or hide the placeholder screens. Apple rejects apps with unfinished screens you can tap into. The stubs today: S1 Welcome, S11 Pay, S16 Duplicate review, S17 Fleet setup, S18 Driver invite, S19 Fleet dashboard, S20 Bulk packets, S21 Monthly report. Either build them or remove the routes to them before submission.
- [ ] Fix the Add Ticket photo buttons. "Take a photo" and "Choose from library" sit side by side and the labels wrap badly ("Choo se from li- brary"). Fix prepared Nov 22: stack them full-width, one above the other. (PhotoCapture.swift. The change is ready on the VM, uncommitted. It needs her yes to commit, push, and verify on her Mac.)

### Must prove before claiming it works

- [ ] Test OCR on a real ticket photo. OCR has only ever run on typed entries, plus one live photo test (Nov 2, ticket Y18776021, year bug fixed). Photograph a real ticket in the app and confirm the number, date, and code fill in correctly.
- [ ] Run the full fight flow on a real iPhone, not just the simulator. Add a ticket, case check, evidence, statement, packet PDF, mark filed, result check-in.

### Store listing (needed to submit)

- [ ] App Store screenshots in the required iPhone sizes.
- [ ] Description, keywords, and a support URL. The landing page can serve as the support URL.
- [ ] Privacy policy. Required, because the app photographs tickets and uses Sign in with Apple.
- [ ] App icon. Already in place (AppIcon-1024.png).

### Small cleanups

- [ ] Clear the "Update to recommended settings" project warning in Xcode. Cosmetic, not a rejection reason.

## Already in good shape (verified)

- Core fight flow works end to end for one driver and one ticket (verified Nov 19 on her Mac). Photo and OCR path, confirm details, case check, evidence, statement, packet PDF, filing, tracking, result.
- Saving works (SwiftData). Tickets survive closing and reopening the app.
- Sign in with Apple is in place under More, never blocking the front door.
- Build is clean, no errors, runs on the iPhone 17 Pro simulator.
- Dark panels (Option A) verified on screen Nov 22.
- Tab bar runs to the bottom edge. Fixed and verified Nov 22.

## Still open, not an Apple blocker

- Detroit Discount sign-up inside the app. Risha directed this Nov 9. It only lives in the PenPot designs, not in the code yet.
- Pay (S11) stays out while the packet is free during launch. Charging needs her approval and the App Store version first. Trigger: 100 waitlist signups or 25 packets built.
