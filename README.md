# Flutter mobile port of Freebify: spec kit

Source analysed: https://github.com/govu/freebify (`main`, last push 2026-10-31, v1.0.59, Electron + React 19 + TypeScript, GPL-3.0 + Freebify Attribution Clause).
Target: a Flutter app for Android and iOS. The working name is **"Awady Music"**, a placeholder (see Open Questions; the license forbids the Freebify name and logo).

This kit is written for an AI coding agent (Google Antigravity, Gemini Flash). Read the files in this order:

| # | File | What it is |
|---|------|------------|
| 1 | `constitution.md` | Non-negotiable rules: stack, packages, folder layout, lint, testing, licensing |
| 2 | `spec.md` | Product spec: every desktop feature mapped to mobile, user stories + acceptance criteria, non-functional reqs |
| 3 | `plan.md` | Architecture, Dart data models, service interfaces, desktop→mobile replacements, permissions, CI |
| 4 | `ui.md` | Every screen, navigation map, states, Liquid Glass design system (dark + light, RTL) |
| 5 | `tasks.md` | Ordered, numbered tasks in phases with checkpoints. Do them one at a time. |
| 6 | `prompts.md` | Ready-to-paste prompts for Antigravity: kickoff + one per phase |

`FREEBIFY-FLUTTER-SPEC.md` is all of the above concatenated into one file.

## Open questions (summary; details in spec.md §9)
1. App name and icon (cannot be "Freebify").
2. Distribution: sideload APK / AltStore only? Google Play and the App Store will likely reject a YouTube-audio-extraction app.
3. iOS: EQ/effects are not available through just_audio on iOS. Ship Android-only EQ, or drop it?
4. Keep the Audius fallback? (Recommended: yes, it is the legal/robust fallback.)
5. Distribution of auto-updates for sideloaded Android (in-app "new version" check against GitHub Releases?).


Awady Music is a Flutter mobile port based on Freebify by govu (GPL-3.0). Spec kit in spec/.
