# Parking Ticket Fighter, Human Interface Guidelines notes

Standing rule (Risha, Oct 13, 2026): review Apple's Human Interface
Guidelines before and during design and build, including the pages for
the specific components used, with HIG checks at lo-fi, hi-fi, and
before a build is called finished. This file records which HIG pages
were reviewed and what changed because of them.

## Pages reviewed

Direct reads of the live Apple pages (Nov 8, 2026):
- Tab Bars, developer.apple.com/design/human-interface-guidelines/tab-bars
- Sign in with Apple, developer.apple.com/design/human-interface-guidelines/sign-in-with-apple

Component pages reviewed Nov 8, 2026 via HIG mirrors and references
that agree with each other (the live Apple pages could not be read
directly by the research agent; treat these as verified by consensus,
not as a direct read of the live pages):
- Buttons
- Navigation bars
- Lists and tables
- Text fields
- Materials (Liquid Glass)
- Typography
- Color

## What changed in the Nov 8 HIG pass

Glass is for the functional layer only. The tab bar is glass. Every
button, card, panel, and badge on a screen is solid now.
- GlassPrimaryButton became AppPrimaryButton, solid forest, using
  `.borderedProminent`. GlassSecondaryButton became
  AppSecondaryButton, standard `.bordered`. Both keep the 44 point
  minimum touch target and the forest brand color.
- GlassPanel (the Money at risk summary, the verdict panel, the stub
  header) became IvoryCard, solid ivory.
- GlassBadge became StatusBadge, a solid pill: dark text on a light
  tint wash, with the icon and words carrying the meaning, so color is
  never the only signal.
- StubBanner lost its glass effect and uses a solid brass tint wash.
- The center camera button is a navigation tab to Add Ticket, not an
  action that opens the camera. That follows the Tab Bars rule that
  the tab bar is for navigation, not actions. The camera itself lives
  on the Add Ticket screen.

Navigation titles, short and describing the view, never the app name:
- Home was "Parking Ticket Fighter" (22 characters, the app name).
  It is now "Home".
- Filing instructions (20 characters) is now "Filing".

Text fields on Add Ticket:
- Zone and Code use the number pad keyboard.
- Ticket number, Zone, Plate, and Code have autocorrect off.
- Ticket number and Plate use all-caps input, since ticket numbers
  and plates are uppercase.

## Contrast, verified Nov 8, 2026 (WCAG, 4.5:1 minimum for normal text)
- Forest on ivory: 9.92:1. Pass.
- White on forest (primary button text): 10.78:1. Pass.
- Urgent on ivory: 5.19:1. Pass.
- Success on ivory: 4.87:1. Pass.
- Brass on ivory: 3.17:1. Fail, so brass is never used as text.
  It is only a background tint. The StatusBadge keeps dark text on a
  light brass wash for this reason.

## Editorial Brief redesign (Nov 8, 2026, Risha: "Yes, rebuild it to the Editorial Brief")

Risha said the app looked worse and asked where the hi-fi was. The
native scaffold still wore the old forest, brass, and glass look,
which the Editorial Brief (chosen by her Nov 2, 2026) had replaced.
The native screens were rebuilt to the Editorial Brief:
- Paper white (#ffffff), ink black (#111111), signal red (#c8102e)
  only for deadlines, money at risk, and urgent flags. No forest,
  no brass, no green, no glass, no blur, no shadows.
- Georgia serif headlines and the masthead nameplate
  ("PARKING TICKET FIGHTER"), small caps kickers, tabular numerals
  for money and dates.
- Buttons are solid black rectangles with white text and square
  corners. Status is small caps text, never pills. Deadlines are red
  marginalia, never badges. Panels are paper white with a thick
  black top rule and hairline dividers.
- The tab bar is a white bar with a black top rule and black text.
  The center camera button is a solid black square with a white
  camera icon. The tab bar sits in the layout flow below the TabView
  (a VStack), not overlaid, so content can never hide behind it.
  This fixes the overlap bug Risha flagged Nov 8, where the floating
  tab bar covered the bottom of every screen.
- The theme is locked to light (`.preferredColorScheme(.light)`),
  paper white always, even in device dark mode.
- The HIG glass rule and the Editorial Brief agree: glass belongs
  only in the functional layer, and the Brief removes glass from
  content entirely, so the tab bar is solid white, not glass.

## Deliberate brand choices (not oversights)
- Forest, ivory, and brass are Risha's approved brand palette, kept
  on purpose. They are custom colors, not Apple's semantic colors.
  Contrast is verified above for the text combinations in use.
- The app is locked to light mode. Custom colors do not yet carry
  dark variants in the asset catalog. That is a known gap; the tab
  bar glass adapts on its own, and no dark mode is shown.

## Known deviation, kept on purpose
- Top-level screens (Home, My Tickets, Add Ticket, More) use inline
  titles, not the large title HIG prefers for top-level screens.
  Inline is kept for layout consistency and because the large title
  contributed to the layout mess Risha flagged Nov 8. Pushed and
  detail screens correctly use inline titles.

## Clean and modern Figma redesign, HIG audit (Nov 9, 2026)

Risha asked whether the Figma redesign is based on Apple HIG, asked
for a crisp clean app as if senior UX and software designers built
it, and asked whether it covers all required functionality. She
picked "Clean and modern" over the warm and friendly first Figma
pass. The audit below was done against the HIG pages already on
record (Tab Bars, Sign in with Apple, Buttons, Navigation bars,
Lists and tables, Text fields, Typography, Color) plus the HIG
rules applied in the Nov 8 pass.

What the audit found and what changed for the clean modern pass:
- Font: the first Figma pass used Inter. HIG uses SF Pro, the iOS
  system font, and the native app renders SF Pro. The redesign
  switches all Figma text to SF Pro (Regular, Medium, Semibold,
  Bold). SF Pro availability was verified in Figma before the
  switch. Note the style name is "Semibold", not "Semi Bold".
- Touch targets: all buttons are 52pt tall, tab bar items fill
  their column, form fields are 48pt tall. All meet the 44pt
  minimum.
- Tab bar: every tab has an icon AND a short label (Home, My
  Tickets, Add Ticket, More). The center camera is a navigation tab
  to Add Ticket, not an action that opens the camera, per the Tab
  Bars rule. Selected tab is blue, unselected is gray.
- Navigation: top-level screens (Home, My Tickets, Add Ticket,
  More) use large titles (28pt Bold, left aligned), fixing the
  known deviation from the Nov 8 pass. Pushed and flow screens
  (Ticket Detail, S4 to S21) use a back chevron plus a centered
  inline title, which is the correct HIG pattern for detail
  screens. Pushed screens do not show the tab bar.
- Text fields: every field on Add Ticket and Confirm details has a
  persistent label above the box, never a placeholder alone.
- Color: blue (#2563EB) is the single accent for primary actions
  and links. Red (#DC2626) is reserved for urgent deadlines only.
  Status is always carried by words (WORTH FILING, DISMISSED),
  never by color alone.
- Sign in with Apple: stays in More, Account, per the approved
  no-account-wall flow and the HIG rule to delay sign-in until it
  gives value. The button is the system style, black, titled
  exactly "Sign in with Apple". Risha is still deciding the order;
  do not move sign-in until she says so.
- Sheets: full-screen navigation is the default. Sheets are used
  only where iOS uses them: the Detroit Discount sign-up opens as
  a modal sheet, and the photo picker is a native-style action
  sheet. Both are designed as separate frames in Figma.

## Contrast, verified Nov 9, 2026 (WCAG, 4.5:1 minimum for normal text)
Clean modern palette, computed:
- Ink #111827 on white: 17.74:1. Pass.
- Secondary #6B7280 on white: 4.83:1. Pass.
- Blue #2563EB on white: 5.17:1. Pass.
- White on blue #2563EB (primary button text): 5.17:1. Pass.
- Red #DC2626 on white: 4.83:1. Pass.
- White on red #DC2626: 4.83:1. Pass.
- Green #047857 on white: 5.48:1. Pass.
- Blue dark #1D4ED8 on white: 6.70:1. Pass.
- Blue dark on blue tint #EFF6FF: 6.16:1. Pass.
- Green on green tint #ECFDF5: 5.21:1. Pass.
- Blue on blue tint #EFF6FF: 4.75:1. Pass.
- Red #DC2626 on red tint #FEF2F2: 4.41:1. FAIL. Fixed: red text
  on a red tint uses dark red #B91C1C instead, 5.91:1. Pass. The
  status pill "WORTH FILING" uses #B91C1C on #FEF2F2. Plain #DC2626
  stays only for red text on white.
- Secondary #6B7280 on blue tint #EFF6FF: 4.44:1. FAIL. Fixed:
  secondary text is never used on a tinted background. Body text
  inside tinted cards uses ink (#111827), which passes at 16.30:1.

## Figma MCP rate limit, BLOCKED Nov 9, 2026
The clean modern restyle and the S1 to S21 build-out are BLOCKED.
Figma's MCP server allows 20 tool calls per month on the Starter
plan. The morning's Figma session (first redesign pass) plus this
pass used them up. Every use_figma call now returns "You have
reached the Figma MCP tool call limit on the Starter plan."
File state at the block: the 5 old warm screens were deleted and
the Home rebuild failed mid-script, leaving a PARTIAL Home screen
on the canvas. The file is mid-rebuild; do not judge it until the
restyle lands. Unblock by either (a) upgrading the Figma plan to
Professional, which allows 200 MCP tool calls per day, or (b)
waiting for the monthly reset, about Dec 1, 2026. When unblocked,
run in order: cleanup-partial.js, then the clean modern screen
scripts in /tmp/figma (lib2.js, c1 to c5, p1 to p11), then take a
composition screenshot and fix any overflow. The HIG audit and the
contrast fixes above are already recorded here and applied in the
scripts.
