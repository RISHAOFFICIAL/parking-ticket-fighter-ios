# Beat the Meter, Stage 6: Build Spec
Renamed Nov 9, 2026: the app is now called Beat the Meter (was Parking Ticket Fighter).
Hi-fi approved by Risha October 13, 2026. Stage 6 build started same day on her direction.
Source of truth: Stage 2 user stories (20), Stage 3 flow (S1 to S21), Stage 5 hi-fi prototype (artifact slug parking-ticket-fighter-hi-fi-prototype).

## What Stage 6 is
- A working app, not a click-through prototype. Data entered must save and persist, statuses must update, deadlines must calculate from the issue date entered, and the packet must assemble from the actual ticket, evidence notes, and statement in the record.
- Built as a private fullstack web app in Muse for Risha to test and use. It is not published, not in the App Store, and not public. A native iOS build, App Store submission, real payment processing, and real city filing are separate later steps that each need Risha's explicit approval and accounts.
- Design carries the approved hi-fi exactly: forest, ivory, brass, Liquid Glass on buttons, floating tab bar, toolbar, and key control panels. No em dashes in copy.

## Must work (tested against Stage 2 must haves 1 to 10)
1. Add a ticket by typing details (ticket number, issue date and time, zone, location, plate, code, fine). Photo upload is recorded as an evidence item; automatic reading of a photo (OCR) is not claimed unless it actually works in the build. Never claim OCR that is not there.
2. The one question first: paid, tried to pay but app or meter failed, or did not pay. Routing follows Stage 3.
3. Case check with a plain language verdict (Strong, Worth filing, Weak) and the reason, driven by the answers and evidence present.
4. Evidence checklist per ticket, items can be added, checked, or marked as not having it, with a case note when a session covers the ticket time and zone.
5. Statement drafted automatically from the ticket facts, editable, with the warning to sign only what is true.
6. Packet view that assembles cover summary, statement, ticket details, and evidence list in one clean printable view (browser print to PDF). That is the v1 packet. Do not claim a generated server PDF unless the build actually produces one.
7. Deadlines calculated and shown: discount deadline and contest deadline from the issue date, with the $22.50 to $45 step up where Code 821 applies, and a plain warning when a deadline has passed.
8. Reminders list generated from deadlines (discount minus 3 days, contest minus 5 and minus 1, result check at day 30 after filing, upheld payment reminder). Reminders are in app records in v1. No push or text sends unless a real service is connected later with approval.
9. Status tracking per ticket: Not filed, Packet built, Filed and waiting, Dismissed, Upheld, Paid. Home shows open tickets, money at risk, and money saved.
10. $19 pay gate recorded per ticket at packet stage. V1 records a test or manual payment confirmation only. No real card is charged and no payment method is stored until a real processor (for example Stripe or Apple Pay) is connected with Risha's approval.

## Should have and nice to have in v1, honest scope
- S16 duplicate charge review: user can record suspected duplicate charges side by side and save a dispute summary. No bank contact.
- Vehicles saved so a second ticket is faster. Payment methods are NOT saved in v1 for safety.
- Weak case honest math screen: pay $22.50 by the discount date (Detroit Discount, registered Detroit plates only, driver must live in Detroit) versus risk $45 plus late fees.
- Fleet: fleet setup, vehicles and drivers, dashboard sorted by deadline urgency, bulk packet selection list, monthly report totals from the saved records.
- Past tickets by zone list (a simple list, not a map) and a repeat zone warning when a new ticket matches a prior zone.
- Other cities: Detroit only in v1, with the city field present. Do not claim Chicago or Cleveland support.

## Data model (minimum)
- Tickets: number, issue date and time, zone, location, plate, code, fine now, fine later, paid answer, verdict, status, filed date and method, result, created and updated.
- Evidence items per ticket: type, label, note, present or missing.
- Statements per ticket: draft text, edited text.
- Reminders per ticket: type, date, ticket number, amount at risk, done or open.
- Fleet: business name, vehicles (plate, nickname, driver), driver names for ticket assignment.
- Duplicate charges per ticket or standalone: amount, date, provider, note, confirmed or not.

## Detroit filing content (must be exact, from Stage 2)
- Administrative Review at parkdetroit.us, or mail to Parking Violations Bureau, P.O. Box 2549, Detroit, MI 48231-2549, or in person at 1001 Tenth Street, Detroit, MI 48216. Phone (313) 963-9630.
- Filing freezes penalties while review is pending. Results by mail, usually within about 30 days.

## HIG recheck before build is called finished (playbook rule)
- Rechecked at Stage 6 start, October 13, 2026, from the Stage 5 review notes: Materials (glass on functional layer only, sparingly), Tab Bars (navigation only, labeled, visible), Buttons (44 by 44 pt, press states), Color (color sparingly, legibility), Layout (controls distinct from content), Accessibility (sized controls, not color alone), Toolbars (actions for current view).
- Known limit carried from Stage 5: two Apple pages (Materials, Toolbars) were reviewed from Apple search summaries because direct page fetch returned no extractable content. Do not claim a full page read for those two.
- A second recheck happens after the build audit, before the build is presented as finished.

## Build result (October 13, 2026)
- Working app built (artifact slug parking-ticket-fighter, private fullstack, not shared). Audit passed with no console errors, broken assets, text issues, or mobile overflow. Server actions verified with a test ticket issued October 8, 2026: discount deadline October 22, 2026, contest deadline November 7, 2026, default evidence checklist created, reminders created October 19, November 2, and November 6, 2026, and a Yes I paid answer produced a Worth filing verdict with reason.
- Unresolved finding, stated plainly: User Story 1 photo reading (OCR extraction of ticket number, date, time, zone, and fine from a photo) is NOT implemented in v1. Entry is manual, the app says so, and the welcome wording about starting from the ticket must not be read as an OCR claim. Closing this gap needs a real OCR step and a verification test with a real ticket photo, as a separate fix pass approved by Risha.
- HIG post build recheck: design carries the approved hi-fi (glass toolbar, buttons, floating tab bar, forest, ivory, brass, correct empty state on desktop and mobile screenshots). No new HIG issues reported in the audit.

## Hard limits, say them plainly to Risha when presenting
- No real payment charged, no card stored.
- No filing submitted to Detroit by the app. The user files, the app prepares.
- No push or text reminders sent. In app reminders only.
- No OCR claim unless verified working.
- Not public, not shared, not in any app store.

## Detroit Discount program link (added Nov 7, 2026)
- The app links to the City of Detroit's Detroit Discount (Parking Fine Reduction Program) signup page: https://prdwmq.etimspayments.com/pbw/include/detroit/discount_request.jsp
- Program facts (verified live Nov 7, 2026 on the City's registration page): 50% off Expired Meter and No Parking fines, active since Nov 1, 2019. Eligibility: the driver must live in the City of Detroit; plate registered in the City of Detroit; no more than one unpaid ticket on the owner's record including the current ticket; ticket paid within 5 calendar days of issuance. Registration takes about 60 minutes to process. Both conditions are required, it is AND not OR (corrected Nov 8, 2026).
- The section sits on the dashboard/home and in the filing instructions, styled Editorial Brief. It states plainly that registering does not contest a ticket, it is for paying one at half price, and that it is the City's program, not the app's.
- Open question flagged to Risha Nov 7, 2026: the program's 5-day pay window vs the app's 14-day discount deadline. The app's deadline math was NOT changed; the program section states the City's own 5-day rule.

## Monetization plan (recorded Nov 7, 2026, Risha approved recording it)
- Status: a plan to revisit, NOT a decision to charge now. Free launch stands until the trigger below.
- Free forever (the hook): Detroit Discount registration link, deadline calculator, reminders. Never charge for the City's discount link.
- Pay per packet: $15 per contest packet (case check, statement, packet PDF). First ticket free so people feel the value. Original price was $19 per packet (kept behind FREE_LAUNCH); $15 chosen for better conversion.
- Fleet plan: $29/month for up to 5 vehicles, unlimited tickets, deadline tracking, bulk contesting, monthly report. This is the recurring revenue path.
- Math to about $500/month: 34 packets at $15 is $510; 18 fleets at $29 is $522; mixed, 10 fleets ($290) plus 15 packets ($225) is $515.
- Trigger to turn payments on: 100 waitlist signups OR 25 packets built. Revisit then; do not charge before traction.
- Prerequisite: the native App Store version ships first, because "download" is the positioning and a web page cannot be downloaded.
- Payments: Stripe on web (existing Lexis Sapphire setup); Apple takes 15% under the Small Business Program on iOS in-app purchases.
- Never: in-app ads (tiny money, cheapens a tool people trust with a legal fight), selling user data, charging for the discount link.

## Discount deadline correction (Nov 7, 2026)
- Discount deadline is issue date + 5 calendar days, NOT +14. Source: City of Detroit's Detroit Discount program (50% off, pay within 5 days, registered Detroit plate), confirmed live Nov 7, 2026 on the City's registration page and in the City's Nov 15, 2019 release; Risha's own tickets also state $22.50 / $45 after 5 days. No official source supports 14 days.
- Contest deadline stays issue date + 30 days.
- The 5-day window is the Detroit Discount window for registered Detroit plates. Fix applied Nov 7, 2026 to the app math, saved tickets, reminders, and copy, plus the landing page and the LinkedIn post.
- Wording correction Nov 8, 2026 (Risha approved): the $22.50 rate is ONLY for Detroit residents with a plate registered in the Detroit Discount program. The app's "Two deadlines" explainer, coach math, and discount deadline framing were fixed to carry the condition, and the Discount section gained a live-in-Detroit condition row. The 5-day math itself did not change.
