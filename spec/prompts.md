# Prompts for Antigravity (Gemini Flash)

Put all 7 spec files in the new repo under `spec/` before starting. Paste the prompts below one at a time. Wait for each CHECKPOINT report before pasting the next phase prompt.

## 0. Kickoff (paste once)
```
You are building a Flutter (Android + iOS) port of the desktop music app Freebify (https://github.com/govu/freebify).
Before writing any code, read these files fully, in order: spec/README.md, spec/constitution.md, spec/spec.md, spec/plan.md, spec/ui.md, spec/tasks.md.

Rules:
- The constitution overrides everything. Use only the packages it lists.
- Work through spec/tasks.md strictly in order, ONE task at a time. Do not skip ahead, do not merge tasks.
- For each task: read the cited spec sections and the cited upstream source file in ../freebify-ref; change only the listed files; run the task's Verify command; fix until it passes; tick it in docs/PROGRESS.md; commit "T-xx: <title>".
- Never invent features. If something is ambiguous, choose the simplest option consistent with the spec, write it in docs/DECISIONS.md, and continue.
- Never weaken a test to make it pass. Never commit secrets.
- All UI strings go in ARB files (en, es, ar). Use directional paddings only (RTL).
- Stop at every CHECKPOINT and give me the evidence it asks for.
Start now with Phase 0 (T-01 to T-06), then stop at CHECKPOINT A.
```

## 1. Phase 1: Design system
```
Checkpoint A approved. Continue with Phase 1 (T-07 to T-12) from spec/tasks.md, following spec/ui.md §1–§3 exactly (Liquid Glass tokens, dark + light, reduce-transparency fallback, RTL). One task at a time, verify each. Stop at CHECKPOINT B and show the golden images.
```

## 2. Phase 2: Data layer
```
Checkpoint B approved. Do Phase 2 (T-13 to T-27). Port logic from the cited upstream files in ../freebify-ref (storage.ts, library.ts, electron/youtube.cjs, audius.ts, deezer.cjs) instead of guessing. Innertube parsers must be tested against recorded fixtures only and must never throw on missing fields (use dig()). Stop at CHECKPOINT C.
```

## 3. Phase 3: Player
```
Checkpoint C approved. Do Phase 3 (T-28 to T-37) per spec/plan.md §5 and §7. Keep a single PlayerController as source of truth; resolve stream URLs lazily per track; implement the 3-failure circuit breaker and the Audius fallback. Port stats.ts and rewind.ts with their tests. Stop at CHECKPOINT D with on-device evidence.
```

## 4. Phase 4: Screens
```
Checkpoint D approved. Do Phase 4 (T-38 to T-54). Each screen follows its spec/ui.md section exactly, has loading (skeleton), empty, error (Retry) and data states, widget tests per state, and goldens in dark-en, light-en, dark-ar. Respect the anti-slop design rules in spec/constitution.md §6. Stop at CHECKPOINT E.
```

## 5. Phase 5: Lyrics
```
Checkpoint E approved. Do Phase 5 (T-55 to T-60). Source order: YouTube Music timed lyrics, then Musixmatch, then LRCLIB, then plain. Port the LRCLIB selection rules from ../freebify-ref/src/components/NowPlaying.tsx. Long-press a line pins it to the current time, stored per track + sheet fingerprint.
```

## 6. Phase 6: Import, downloads, backup
```
Phase 5 done. Do Phase 6 (T-61 to T-67). Port electron/spotify.cjs and src/store/resolve.ts faithfully (instant pending rows, background matching in order, concurrency 3, cache, drop after one retry). Downloads go to the app documents folder, max 2 at a time. Stop at CHECKPOINT F with device evidence.
```

## 7. Phase 7: Polish & release
```
Checkpoint F approved. Do Phase 7 (T-68 to T-70). App name: <FILL IN FROM Q1>. Package id: <FILL IN>. Keep the attribution line "Based on Freebify by govu — https://github.com/govu/freebify" in Settings → About and in README/NOTICE. Stop at CHECKPOINT G with artifacts and the list of still-open questions.
```

## Recovery prompt (if the agent drifts)
```
Stop. Re-read spec/constitution.md and spec/tasks.md. Tell me which task ID you are on, what its DoD and Verify command are, and whether Verify currently passes. Revert any change not listed in that task's files, then continue with that task only.
```

---

## Repository & publishing (decided)

- GitHub repo: https://github.com/awadyeg/Awady-Music (public, GPL-3.0, already created; this spec lives in `spec/`).
- App name: **Awady Music**.
- Work on branch `main`. After EVERY completed phase/checkpoint: `git add -A && git commit -m "<phase>: <summary>" && git push origin main`.
- Keep `spec/STATUS.md` updated after each task: done / left / next.
- At the end, push the final code, tag `v1.0.0`, and make sure `README.md` credits "Freebify by govu" (license requirement).
