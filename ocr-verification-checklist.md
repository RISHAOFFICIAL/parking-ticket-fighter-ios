# Beat the Meter, OCR Verification Checklist
Written Nov 18, 2026, with the on-device Vision OCR build. The reader
is NOT claimed as working until the real ticket photo test below
passes. The reader only drafts fields; the user confirms every field
on Confirm Details (S4) before anything is saved.

## What the reader does

- On-device Apple Vision text recognition (VNRecognizeTextRequest,
  accurate level, en-US). Free, private, no server: the photo never
  leaves the phone.
- Reads front and back, then parses: ticket number, date and time
  issued, zone, location, plate, fine amount.
- Two digit years are read as 20xx. A date in the future, or with a
  year before 2020, is flagged as impossible instead of returned.
- Ticket-likeness check: a ticket number (Y plus 8 digits) on its own,
  or at least two ticket words (Detroit, parking, violation, ticket,
  meter, Park Detroit, City of, fine, expired).
- Unreadable photo: "We could not read that clearly. Try again in
  better light, or type the ticket number instead."
- Not a ticket: "That does not look like a parking ticket. Retake, or
  continue typing details by hand."
- A photo that cannot be read stays attached as evidence either way.

## Test 1: real ticket photo, the deciding test

Needs: a real Detroit parking ticket, a real iPhone (camera), and
Risha or a tester holding the phone.

1. Add Ticket, take a photo of the front of the ticket in good light.
2. Confirm Details opens with the read fields. Record field by field:
   ticket number, date, time, zone, location, plate, fine amount.
   Mark each right, wrong, or missing.
3. Take a photo of the back. Confirm the read still opens Confirm
   Details and the back text does not overwrite good front fields
   with worse ones.
4. Fix any wrong field by hand, tap "These are right", save the
   ticket. Confirm the saved ticket shows the corrected values and
   both photos are attached on ticket detail.
5. Pass bar: ticket number, date, zone, and plate read correctly on a
   clear photo, or the wrong fields are obvious enough on Confirm
   Details that the user fixes them before saving. If the reader
   misreads silently (a wrong value that looks right), that is a fail:
   record which field and which ticket.

Known ticket for a repeat test: Y18776021, Zone 105, Cadillac Sq,
issued Oct 9, 2026 at 8:47 a.m., plate 7PAC20, Code 821, $45. The
web build's one live OCR test on this ticket (Nov 2, 2026) read
correctly except a two digit year, so the year handling is the
specific thing to watch.

## Test 2: blurry photo

1. Photograph a ticket out of focus or in dim light.
2. Expect the unreadable message, and the photo still attached as
   evidence on the saved ticket after typing the details by hand.

## Test 3: not a ticket

1. Photograph something that is not a ticket: a receipt, a street
   sign, a blank wall.
2. Expect the not-a-ticket message. Confirm no ticket fields are
   filled in from it.

## Test 4: impossible date

1. Photograph a ticket, then on Confirm Details check the date row.
2. If the photo gave no usable date, the date field is flagged in
   place ("We need the issue date to calculate your deadline") and
   "These are right" stays disabled until a date is picked.
3. If a date is read, confirm the deadlines on the saved ticket are
   issue plus 5 days (discount) and issue plus 30 days (contest).

## Test 5: parser unit checks (no camera needed)

The parser (`TicketOCR.parse(lines:)`) is a pure function, so it can
be checked against typed text without a photo. Feed it these lines
and confirm the parsed fields:

- ["CITY OF DETROIT", "PARKING VIOLATION", "TICKET Y18776021",
  "DATE 10/09/2026", "TIME 8:47 AM", "ZONE 105",
  "LOCATION CADILLAC SQ", "PLATE 7PAC20", "FINE $45.00"]
  Expect: number Y18776021, date Oct 9 2026 8:47 a.m., zone 105,
  location Cadillac Sq, plate 7PAC20, fine 45.00, looks like ticket.
- Same lines with "DATE 10/09/26": expect year 2026, not 1926.
- Same lines with "DATE 13/40/2026": expect no date, flagged invalid.
- ["GROCERY RECEIPT", "TOTAL $12.34"]: expect not a ticket.

## Results log

| Date | Tester | Test | Result |
| ---- | ------ | ---- | ------ |
|      |        |      |        |

Do not mark OCR as working in any user-facing copy, store listing, or
status update until Test 1 passes and the results log has an entry.
