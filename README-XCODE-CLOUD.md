# Parking Ticket Fighter, Native iOS Scaffold and Xcode Cloud

Written for Risha, October 15, 2026.

## What this is

This folder holds a native iPhone version of Parking Ticket Fighter, built as a real Xcode project you can open on your Mac. It mirrors the approved design from the web version: the same flow, the same screen numbers (S1 to S21), the same Detroit facts, and the same forest, ivory, and brass look with Apple Liquid Glass on the buttons and key panels.

What is real in this scaffold:

- The app opens to four tabs: Home, My Tickets, Add Ticket, and More (resources).
- Home shows open tickets, the money at risk, and the next contest deadline.
- My Tickets lists tickets with their status, sorted by deadline.
- Tapping a ticket shows the full detail: the case verdict, both deadlines, the drafted statement, the evidence checklist, and the exact Detroit filing routes.
- Deadline math is built in and checked against your real tickets: pay the discounted fine within 5 days of the ticket date, contest within 30 days. The $22.50 reduced fine only applies for Detroit residents with a plate registered in the City's Detroit Discount program. A ticket written October 8, 2026 gets a discount deadline of October 13, 2026 and a contest deadline of November 7, 2026, which matches the approved build record.
- The sample tickets inside are your three real October tickets (Y18973750, Y18981274, Y18776021), the same examples the approved design used.

What is marked as a stub: every screen that is not ported yet shows a clear "Stub screen" label with its screen number and what it will do. Nothing in this scaffold pretends to be finished work.

## The one time setup only you can do

These steps need your Apple ID and your Mac. Nobody else can do them for you, and nothing here has been enrolled in, connected, or paid for yet.

1. **Join the Apple Developer Program.** DONE, enrolled September 11, 2026 under erishasmith0723@gmail.com. It costs $99 a year, paid to Apple. This is what unlocks Xcode Cloud builds and TestFlight.
2. **Put this project in your GitHub.** The project folder is `ParkingTicketFighter` inside `07-native`. It goes into a repository under your GitHub account (RISHAOFFICIAL), the same account your other projects use. Pushed from this workspace November 8, 2026 to RISHAOFFICIAL/parking-ticket-fighter-ios.
3. **Open the project on your Mac.** Open `ParkingTicketFighter.xcodeproj` in Xcode. If Xcode asks about signing, sign in with your Apple ID and let it manage signing automatically. No development team is preset in the project on purpose, so it will use yours.
4. **Create the first Xcode Cloud workflow.** In Xcode, use the Xcode Cloud flow (Integrate menu, then Xcode Cloud, then Create Workflow). Pick the Parking Ticket Fighter scheme. This first workflow is a one time thing and it has to start from your Xcode, signed in as you.
5. **Connect GitHub if Xcode asks.** Xcode Cloud builds from your repository, so it may ask you to authorize the connection between App Store Connect and GitHub. Approve it with your accounts.

That is the whole list. After step 4, your part is done until you want to look at a build.

## What happens after setup

- Every time code is pushed to the repository, Xcode Cloud builds the app on Apple's machines. Your Mac does not have to be on, and you do not have to open Xcode.
- A passing build can be sent straight to TestFlight, so the app lands on your iPhone for you to tap through, the same way you reviewed the web version.
- Build results, pass or fail, show up in App Store Connect and in Xcode, so a failed build tells us exactly what to fix.

## The honest limits

- **This is a scaffold, not the full app.** It mirrors the approved design and carries the structure, the facts, and the deadline math. It is not the full 21 screen port.
- **The full port proceeds screen by screen**, with your approval at each stage, the same design first process the web version followed: core fight flow first, then tracking, then duplicate review, then the fleet screens.
- **Saving is not wired up yet.** The sample tickets stand in for saved records. Real saving, the packet builder, and the $19 pay gate port in later passes. No payment is processed and no card is stored anywhere in this scaffold.
- **Photo reading (OCR) and the AI features port later**, and only once each is verified working, the same honest limit the web build carries. The app never claims to read a ticket photo until that is proven with a real photo.
- **Detroit only.** Other cities are not supported and are not claimed anywhere in the app.
- **The app never files anything for you.** It prepares the packet and tells you exactly where to file it: parkdetroit.us (Administrative Review), by mail to Parking Violations Bureau, P.O. Box 2549, Detroit, MI 48231-2549, or in person at 1001 Tenth Street, Detroit, MI 48216. Phone: (313) 963-9630.
- The bundle ID in the project, com.hghmanagementgroup.parkingticketfighter, is a placeholder. It can be changed before anything ships, and changing it later is a normal step.

## What is in the folder

- `ParkingTicketFighter/ParkingTicketFighter.xcodeproj` is the Xcode project.
- `ParkingTicketFighter/ParkingTicketFighter/` holds the Swift code: the app entry, the four tabs, the ticket model, the Detroit facts, the sample data, the Liquid Glass components, and the stub screens.
- `ParkingTicketFighter/ParkingTicketFighter/Assets.xcassets` holds the placeholder app icon and the accent color.
- `ParkingTicketFighter/ci_scripts/ci_post_clone.sh` is the small script Xcode Cloud runs after it copies the project. The project has no outside dependencies yet, so the script just confirms the checkout is in place.
- `ParkingTicketFighter/.gitignore` keeps build clutter out of the repository.
