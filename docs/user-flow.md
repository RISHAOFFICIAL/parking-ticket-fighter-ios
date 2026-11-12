# Parking Ticket Fighter, Stage 3: User Flows
Drafted October 13, 2026. Persona and user stories approved by Risha October 12, 2026. Awaiting Risha's approval before Stage 4 (lo-fi prototype).

Screens are numbered so Stage 4 wireframes can be built directly from this document.

## Flow A: First launch (Denise, new user)

1. **S1 Welcome.** One line of promise: "Got a parking ticket you already paid for? Fight it in about 10 minutes." Two buttons: "Fight a ticket" and "I run vehicles for a business" (routes to Flow F).
2. **S2 How it works.** Three steps with icons: snap the ticket, add your proof, get your packet. Button: "Start."
3. No account wall yet. Account creation is asked only at Flow D step 4 (packet download), so a new user reaches value before any sign up.
4. **Empty state (Home, no tickets yet):** friendly screen, "No tickets yet. Good. When one shows up, start here," with a single "Add a ticket" button.

## Flow B: New ticket, core fight flow (Denise)

1. **S3 Add ticket.** Big button: "Take a photo of the ticket." Secondary: "Upload a photo" and "Type the ticket number instead."
   - *Error: blurry or unreadable photo.* "We could not read that clearly. Try again in better light, or type the ticket number instead." Photo is never discarded; it stays attached as evidence either way.
   - *Error: photo is not a ticket.* "That does not look like a parking ticket. Retake, or continue typing details by hand."
2. **S4 Confirm details.** The app shows what it read: ticket number, date and time issued, zone and location, plate, fine amount. Every field is editable. Button: "These are right."
   - *Validation:* if the issue date is missing or impossible, that field is flagged in place with "We need the issue date to calculate your deadline."
3. **S5 The one question.** "When this ticket was written, had you paid for parking?" Three answers: "Yes, I paid" / "I tried to pay but the app or meter failed" / "No."
   - "No" routes to Flow C step 3 (other defenses check).
4. **S6 Case check.** The app scores the case in plain language and shows one of three verdicts:
   - **Strong:** "You paid, and the time and zone line up. Tickets like this get dismissed when the proof is filed right."
   - **Worth filing:** "Your proof is partial. Here is what would make it stronger," with the specific gap listed.
   - **Weak:** routes to Flow C step 4 (honest advice).
   The verdict screen always shows the two deadlines up front: the discount deadline (pay $22.50 by this date) and the contest deadline.
5. **S7 Evidence checklist.** Guided one item at a time, each with "where to find it" help:
   - Ticket photo (already attached from S3, shown as done).
   - Parking app proof: screenshot of the paid session, or upload from photos. The app checks the session time covers the ticket time and the zone matches, and says so: "This session covers your ticket time. Zone matches."
   - Card or bank charge screenshot showing the parking payment.
   - Optional: photos of signs or the meter, anything else.
   - *Mismatch warning:* if the screenshot's zone or time does not cover the ticket, the app flags it immediately ("This session ended 20 minutes before your ticket was written") and asks for a different session instead of letting a bad packet get built.
   - *Missing item:* each item can be marked "I do not have this." The case check updates and the checklist shows what the packet will say without it.
6. **S8 Your statement.** The app drafts the written statement from the facts: "I paid for parking through the Park Detroit app for zone [X]. My session ran [start] to [end]. The ticket was issued at [time], inside that paid window. A copy of my session receipt and card charge is attached." Denise can edit it in her own words. Plain language warning: "Sign only what is true."
7. **S9 Packet preview.** The full packet as it will be filed: cover summary, statement, ticket photo, evidence pages, deadlines page. Button: "This looks right."
8. Flow continues in Flow D (pay and file).

## Flow C: Other defenses and honest advice

1. Reached from S5 ("No, I did not pay") or a weak S6 verdict.
2. **S10 Defense checker.** Short questions, one at a time: Was the meter broken? Was the sign missing, hidden, or wrong? Were you loading or unloading? Was this a medical emergency? Wrong plate or vehicle on the ticket? Each yes attaches the matching evidence item to the checklist and updates the case check.
3. If a real defense surfaces, return to S7 with that defense's evidence list.
4. **Weak case screen.** "Honest answer: this one is unlikely to be dismissed." Shows the math: pay the discounted $22.50 by the discount date versus contesting and risking $45 plus late fees. Two buttons: "Pay it (we show you where)" and "Contest anyway." Contesting anyway continues to S7 with eyes open; the app never blocks a user from filing.

## Flow D: Pay, file, and track

1. **S11 Pay $19.** Shown only at packet completion. Copy: "Your packet is built. $19 to download and file it. If Detroit dismisses your ticket, you saved the fine and the late fee."
2. Payment by card or Apple Pay / Google Pay.
   - *Error: payment fails.* "Your card was not charged. Try a different card." The packet stays built and waiting; nothing is lost.
3. **S12 Filing instructions.** Step by step for Detroit, in order: go to parkdetroit.us and choose Administrative Review, or mail the packet to Parking Violations Bureau, P.O. Box 2549, Detroit, MI 48231-2549, or take it to 1001 Tenth Street. Includes exactly what to upload or enclose, and "Keep your confirmation or mailing receipt photo here" with an upload slot.
4. **S13 Mark as filed.** Denise taps "I filed it" and picks the date and method. The ticket moves to Filed status on Home. If she has not filed within 3 days, a reminder nudges her (filing freezes the penalties, so speed matters).
5. **S14 Tracking.** Ticket detail shows status timeline: Added, Packet built, Filed, Waiting on result. Copy: "Results come by mail, usually within about 30 days. Penalties are frozen while you wait."
6. **S15 Result.** A check in at day 30 asks: "Did your letter arrive?" Buttons: "Dismissed" (celebration screen showing money saved, running total on Home), "Upheld" (shows what is now owed and the deadline to pay it, so an upheld ticket never becomes a bigger problem), "Not yet" (snoozes the check in by 2 weeks).

## Flow E: Duplicate parking charges (should have)

1. Trigger: during S7, when a card statement screenshot shows two charges for the same session, or from Home, "Check for duplicate charges."
2. **S16 Duplicate review.** Lists suspected duplicates side by side (same amount, same day, same provider) and asks Denise to confirm.
3. Output: a short dispute summary she can take to her bank, saved to the ticket or standalone. The app does not contact the bank for her.

## Flow F: Fleet flow (Marcus)

1. **S17 Fleet setup.** Business name, vehicles (plate, nickname, assigned driver). Plan selection: per vehicle monthly.
2. **S18 Driver invite.** Marcus sends a link; the driver joins with no payment step and sees only "Add a ticket."
3. Driver runs a stripped version of Flow B steps 1 to 2 (photo and confirm). The ticket lands on Marcus's dashboard instantly.
4. **S19 Fleet dashboard.** Every ticket: vehicle, driver, issue date, discount deadline, contest deadline, case check verdict, status. Sorted by deadline urgency. Red flags on anything inside 5 days of a deadline.
5. **S20 Bulk packets.** Marcus selects the winnable tickets; packets build in one batch; he reviews each statement (Flow B step 7 content) and approves; Flow D filing instructions apply per ticket.
6. **S21 Monthly report (nice to have).** Fines paid, fines dismissed, fees spent, money saved.

## Reminders engine (applies to all flows)

Push or text reminders at: discount deadline minus 3 days, contest deadline minus 5 days and minus 1 day, filed but no result at day 30, upheld result payment deadline minus 3 days. Every reminder names the ticket number and the exact dollar amount at risk. Users can mute a ticket's reminders only by marking it paid, dismissed, or upheld.

## Global empty and error states

- **Home, no tickets:** see Flow A step 4.
- **Home, all tickets resolved:** "All clear. Nothing open." plus the lifetime money saved total.
- **Offline:** photos and details save on the phone and packet building resumes when connection returns; a banner says "Saved on this phone, will finish when you are back online."
- **Deadline already passed when a ticket is added:** the app says so plainly, shows what is owed now, and offers the pay instructions path instead of the contest path.
