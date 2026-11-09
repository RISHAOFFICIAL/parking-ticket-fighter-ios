# Beat the Meter, functionality list
Renamed Nov 9, 2026: the app is now called Beat the Meter (was Parking Ticket Fighter).

What the app should do, from the approved design: Stage 2 user stories (20),
Stage 3 flow (S1 to S21), Stage 6 build spec. Written Nov 8, 2026, after Risha
asked for the full list. Prices and the discount rule use the current plan:
packet is free during launch; the recorded plan after launch is $15 per packet,
first ticket free. The $22.50 rate is only for Detroit residents with a plate
registered in the City's Detroit Discount program.

## The photo (how a ticket gets into the app)

- Take a photo of the ticket with the iPhone camera, front and back. The back
  matters too, it carries the violation details.
- Upload a photo from the photo library instead.
- Type the ticket number instead, for anyone who would rather type or whose
  photo cannot be read.
- The app reads the text off the photo (OCR) and fills in ticket number, date
  and time issued, zone, location, plate, and fine amount.
- Confirm details (S4): the app shows what it read, every field is editable,
  and the user taps "These are right." If the issue date is missing or
  impossible, that field is flagged in place.
- Blurry or unreadable photo: "We could not read that clearly. Try again in
  better light, or type the ticket number instead." The photo is never
  discarded, it stays attached as evidence either way.
- Photo is not a ticket: "That does not look like a parking ticket. Retake,
  or continue typing details by hand."
- Status Nov 8, 2026: the two photo buttons in the first native build are
  placeholders and do nothing yet. OCR is not built in the native app or in
  the web app. The native plan is Apple's on-device Vision text recognition
  (free, private, no server), reading front and back, verified with a real
  ticket photo before it is claimed. The web app's one live OCR test (ticket
  Y18776021, Nov 2, 2026) read correctly except a two-digit year.

## The core fight flow

- The one question (S5): "When this ticket was written, had you paid for
  parking?" Three answers: Yes, I paid / I tried to pay but the app or meter
  failed / No. Answering No routes to the defense checker.
- Case check (S6): a plain language verdict, Strong, Worth filing, or Weak,
  with the reason in words and both deadlines up front.
- Evidence checklist (S7), guided one item at a time with where-to-find-it
  help: ticket photo (already attached, shown as done), parking app proof
  (screenshot of the paid session), card or bank charge screenshot, and
  optional photos of signs or the meter.
- Session check: the app checks the paid session covers the ticket time and
  the zone matches, and says so. Mismatch warning if the session ended before
  the ticket time or the zone is wrong, and it asks for a different session
  instead of letting a bad packet get built.
- Missing item: each item can be marked "I do not have this." The case check
  updates and the checklist shows what the packet will say without it.
- Your statement (S8): the app drafts the written statement from the facts,
  the user can edit it in their own words. Warning: "Sign only what is true."
- Defense checker (S10): short questions, one at a time. Was the meter
  broken? Was the sign missing, hidden, or wrong? Were you loading or
  unloading? Was this a medical emergency? Wrong plate or vehicle on the
  ticket? Each yes attaches the matching evidence item and updates the case
  check.
- Weak case, honest advice: "Honest answer: this one is unlikely to be
  dismissed." Shows the math, pay the discounted $22.50 by the discount date
  (Detroit Discount, registered Detroit plates only, driver must live in
  Detroit) versus contesting and risking $45 plus late fees. Buttons: "Pay it
  (we show you where)" and "Contest anyway." The app never blocks a user
  from filing.
- Packet preview (S9): the full packet as it will be filed, cover summary,
  statement, ticket photo, evidence pages, deadlines page. Button: "This
  looks right."
- Pay (S11): shown only at packet completion. Packet is free during launch.
  The recorded plan after launch is $15 per packet, first ticket free, paid
  by card or Apple Pay. If a payment fails, the card is not charged and the
  packet stays built and waiting.
- Filing instructions (S12): the exact Detroit steps, in order. Online at
  parkdetroit.us, choose Administrative Review. Or mail to Parking Violations
  Bureau, P.O. Box 2549, Detroit, MI 48231-2549. Or in person at 1001 Tenth
  Street, Detroit, MI 48216. Phone (313) 963-9630. Includes exactly what to
  upload or enclose, and a slot to keep the confirmation or mailing receipt
  photo.
- Mark as filed (S13): the user taps "I filed it" and picks the date and
  method. The ticket moves to Filed status. If not filed within 3 days, a
  reminder nudges, because filing freezes the penalties.
- Tracking (S14): ticket detail shows the status timeline, Added, Packet
  built, Filed, Waiting on result. "Results come by mail, usually within
  about 30 days. Penalties are frozen while you wait."
- Result check-in (S15): at day 30 the app asks "Did your letter arrive?"
  Dismissed shows a celebration screen with the money saved and a running
  total on Home. Upheld shows what is now owed and the deadline to pay it.
  Not yet snoozes the check-in by 2 weeks.

## Deadlines, money, and reminders

- Deadline calculator on every ticket: discount deadline is the issue date
  plus 5 days, contest deadline is the issue date plus 30 days.
- Detroit Discount: the 50% rate ($22.50) only when the driver lives in the
  City of Detroit AND the plate is registered in the City's Detroit Discount
  program, plus no more than one unpaid ticket on the record and payment
  within 5 days. A link to register the plate with the City is in the app,
  and registering does not contest a ticket.
- Money at risk on Home: the total of open tickets. Money saved: the running
  total when tickets are dismissed. Home with all tickets resolved says "All
  clear. Nothing open." plus the lifetime money saved total.
- Reminders (local notifications on iPhone): discount deadline minus 3 days,
  contest deadline minus 5 days and minus 1 day, filed but no result at day
  30, upheld result payment deadline minus 3 days. Every reminder names the
  ticket number and the exact dollar amount at risk. Permission is asked at
  first ticket save. Reminders update if a ticket is edited or deleted.
- Deadline already passed when a ticket is added: the app says so plainly,
  shows what is owed now, and offers the pay instructions path instead of
  the contest path.
- Past tickets by zone list, and a repeat zone warning when a new ticket
  matches a prior zone.
- Saved vehicles and saved plates, so a second ticket is faster.

## Duplicate parking charges

- Duplicate review (S16): during the evidence step, when a card statement
  screenshot shows two charges for the same session, or from Home, "Check
  for duplicate charges." Lists suspected duplicates side by side (same
  amount, same day, same provider) and asks the user to confirm.
- Output: a short dispute summary the user can take to the bank, saved to
  the ticket or standalone. The app does not contact the bank.

## Fleet (for small business owners)

- Fleet setup (S17): business name, vehicles (plate, nickname, assigned
  driver). Plan selection per vehicle monthly.
- Driver invite (S18): the owner sends a link, the driver joins with no
  payment step and sees only "Add a ticket." The driver's tickets land on
  the owner's dashboard instantly.
- Fleet dashboard (S19): every ticket by vehicle and driver, with issue
  date, discount deadline, contest deadline, case check verdict, and status.
  Sorted by deadline urgency. Red flags on anything inside 5 days of a
  deadline.
- Bulk packets (S20): the owner selects the winnable tickets, packets build
  in one batch, the owner reviews each statement and approves, and the filing
  instructions apply per ticket.
- Monthly report (S21): fines paid, fines dismissed, fees spent, money
  saved.

## First launch and account

- Welcome (S1): one line of promise, "Got a parking ticket you already paid
  for? Fight it in about 10 minutes." Two buttons: "Fight a ticket" and "I
  run vehicles for a business" (routes to the fleet flow).
- How it works (S2): three steps with icons, snap the ticket, add your
  proof, get your packet. Button: "Start."
- No account wall upfront. Account creation is asked only at packet
  download, so a new user reaches value before any sign up.
- Home, no tickets yet: "No tickets yet. Good. When one shows up, start
  here," with a single "Add a ticket" button.
- Offline: photos and details save on the phone and packet building resumes
  when connection returns. A banner says "Saved on this phone, will finish
  when you are back online."

## Money plan (recorded, not a decision to charge now)

- Free forever: Detroit Discount registration link, deadline calculator,
  reminders. Never charge for the City's discount link.
- Pay per packet: $15 per contest packet (case check, statement, packet).
  First ticket free so people feel the value.
- Fleet plan: $29/month for up to 5 vehicles, unlimited tickets, deadline
  tracking, bulk contesting, monthly report. This is the recurring revenue
  path.
- Trigger to turn payments on: 100 waitlist signups OR 25 packets built.
  Revisit then, do not charge before traction. Prerequisite: the native App
  Store version ships first.
- Payments: Apple takes 15% under the Small Business Program on iOS.
- Never: in-app ads, selling user data, charging for the discount link.

## Hard limits (say them plainly)

- No filing is submitted to Detroit by the app. The user files, the app
  prepares.
- No real payment is charged and no card is stored until a real processor
  is connected with Risha's approval.
- No OCR claim unless verified working with a real ticket photo.
- Detroit only. Do not claim other cities.
- Guidance only, not legal advice. The app never invents facts, and the user
  confirms every field the app reads and can edit all text the app drafts.

## Status in the first native build (Nov 8, 2026)

- In the build: four tabs (Home, My Tickets, Add Ticket, More), sample
  tickets with real deadlines and verdicts, ticket detail with deadlines,
  statement draft, evidence checklist, and Detroit filing routes.
- Still to build: saving tickets, photo capture and OCR, evidence upload
  and session matching, statement editing, packet building, pay, mark as
  filed and result check-in, duplicate review, fleet, and local
  notifications.
