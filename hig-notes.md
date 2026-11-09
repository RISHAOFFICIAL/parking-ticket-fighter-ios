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
