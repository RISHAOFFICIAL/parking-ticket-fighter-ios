# Beat the Meter — Project Docs

Start here. This folder holds the design and product docs for the app. The code lives in the repo root.

## The app

Beat the Meter (formerly Parking Ticket Fighter) helps Detroit drivers fight parking tickets. Snap a photo of your ticket, the app checks your case, writes your statement, and builds your evidence packet. Free during launch.

## Read in this order

1. **persona.md** — Who we build for. Primary: Denise, a driver who paid and still got ticketed. Secondary: Marcus, a small fleet owner.
2. **user-stories.md** — 20 user stories, approved Oct 12, 2026.
3. **user-flow.md** — 21 screens S1-S21, error and empty states, reminders engine. No account wall upfront; account creation is asked only at packet download.
4. **build-spec.md** — What v1 does and does not do. Honest limits: no real payment, no filing submitted by the app, in-app reminders only, Detroit only.
5. **ai-spec.md** — Full AI chosen Oct 13, 2026. Guardrails: AI never invents facts, user confirms all AI-read fields, verified Detroit facts override AI text, outputs labeled guidance not legal advice.

## Also in this repo (root)

- **functionality-list.md** — The target feature list. This is the goal, not the current state.
- **notifications-plan.md** — Local notifications via UNUserNotificationCenter.
- **hig-notes.md** — Apple Human Interface Guidelines audit notes and design tokens.
- **xcode-tonight-checkpoint.md** — Where the Xcode work stands.

## Detroit facts that matter

- Contest deadline is issue date + 30 days.
- $45 is the standard fine, due within 30 days. There is NO general early-payment discount.
- $22.50 (50% off) is ONLY for the Detroit Discount program: driver lives in Detroit AND plate is registered in Detroit AND no more than one unpaid ticket AND paid within 5 days. It is AND, not OR.
- Administrative Review via parkdetroit.us. Mail: Parking Violations Bureau, P.O. Box 2549, Detroit, MI 48231-2549. In person: 1001 Tenth Street, Detroit, MI 48216. Phone: (313) 963-9630.
- No penalties accrue during review. Results by US mail in about 30 days.

## Design

Current design direction is Apple Sleek, in PenPot (file "Beat the Meter"). Five main screens are designed: Home, My Tickets, Add Ticket, Ticket Detail, More. The remaining flow screens (welcome, case check, packet preview, filing, tracking, fleet) are not designed yet.

## Current state (Nov 12, 2026)

The native app is a scaffold. It builds and runs on the iPhone 17 Pro simulator. Saving, OCR, AI, payments, and notifications are NOT wired up yet. Sample tickets stand in. The landing page and waitlist are live at https://rishaofficial.github.io/parking-ticket-fighter-landing-page/
