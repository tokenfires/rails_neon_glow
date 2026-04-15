# Phase 3 — Per-theme font pass (spec)

- **Date:** 2026-04-15
- **Status:** Approved, in progress
- **Branch:** `feat/phase-3-per-theme-fonts`
- **Depends on:** Phase 2 (typography architecture), Phase 2.5 (`.ng-neon-tube`)

## Why

Every palette currently uses `Inter` for display and body, except Nixie (B612 Mono + Montserrat Underline). The palettes with strong physical or cultural referents — decade aesthetics, hardware objects — can feel more *themselves* with typography tuned to that referent. A retrowave palette in Inter reads as "purple rectangle." A retrowave palette in Orbitron reads as "1986 title card."

Phase 2.5 gave every palette a consistent neon-signage voice via `.ng-neon-tube`. Phase 3 gives each palette its own *regular-text* voice. The two coexist cleanly: tube utility pins Montserrat Underline explicitly, so it overrides per-palette display fonts when applied.

## Non-goals

- **12 unique fonts.** Diminishing visual return + load weight. Classic palettes (abstract color stories) stay on Inter.
- **Body-font changes across every palette.** Body type is where readability lives; only change body when the referent demands it (VFD, Nixie).
- **Per-theme utility overrides.** `.ng-neon-tube` pins its font explicitly; per-theme changes happen on `--ng-font-display` / `--ng-font-body` tokens only.

## Tier split

**Tier A — stay on Inter (no change).**
Rainbow, Unicorn, Cinematic, Pink. Abstract color palettes without era/object referents. Inter is the correct default.

**Tier B — era/object-tuned display fonts.** Seven palettes, delivered in three batches grouped by typographic family:

### Batch 1 — Geometric sans (wide, tall, technical)
- **Retrowave** → `Orbitron` display. 80s sci-fi title-card geometry. Body stays Inter.
- **Y2K** → `Syncopate` display. Wide tall neutral sans, early-2000s chrome-era feel. Body stays Inter.
- **Cherenkov** → `Space Grotesk` display. Clean technical sans; reads as modern scientific instrument typography. Body stays Inter.

### Batch 2 — Monospace-adjacent (technical, terminal)
- **Cyberpunk** → `Share Tech Mono` display. Monospace display that reads as corporate-dystopian UI text. Body stays Inter.
- **VFD** → `VT323` display. Pixel-terminal type that matches the segmented-display referent. Body stays Inter (VFD's body readability matters at small sizes).

### Batch 3 — Character pieces (statements about *how* type is chosen)
- **Grunge** → `Special Elite` display. Typewriter-photocopy zine aesthetic. Body stays Inter.
- **Social** → native system font stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`) for *both* display and body. The 2010s platform-native ethos: your device chooses the font. Distinct from every other palette for being the *non-choice* choice.

**Tier C — already locked.**
Nixie (B612 Mono body + Montserrat Underline H1/H2, shipped Phase 2).

## Font loading

Each new font added to both:
- `@import url(...)` at top of `tokens.css` (for non-Tailwind consumers)
- `<link rel="stylesheet">` in `application.html.erb` (Tailwind v4 strips the @import — see CLAUDE.md)

All chosen fonts are Google Fonts, OFL-licensed, free for commercial use.

## Per-batch deliverables

Each batch is one branch commit including:
1. Google Fonts URL additions (both `@import` and `<link>`)
2. `--ng-font-display` (and `--ng-font-body` where applicable) overrides inside palette blocks in `tokens.css`
3. System tests asserting computed `font-family` contains the expected face when the palette is active
4. README Typography section update (per-theme overrides table)

## Visual-review loop

After each batch: pause, TK reviews all affected palettes across home page + Bootstrap + Tailwind kitchen sinks, tunes or confirms. Next batch only starts after sign-off.

## Out of scope (deferred)

- Font pairing for display-alt slot (future per-palette subhead voice)
- Custom font variants per intensity level (may not make sense as a concept)
- Font weight/size tuning per palette — Phase 3 changes the face, not the treatment
- Era Chrome (decorative elements beyond typography) — Phase 5

## Risks

- **Load weight.** Each new Google Font family adds to the font-loading payload. Mitigation: only `wght@400;700` per family. If total payload grows past reason, revisit.
- **Cross-theme coherence.** Too many distinct type personalities could make the library feel like a font sampler rather than a design system. Mitigation: shared body font (Inter) across all Tier B palettes anchors the system.
- **`.ng-neon-tube` conflict.** Phase 2.5's utility pins Montserrat Underline. If a palette's display font is compelling enough that users want the tube to use it too, that's a future feature, not a Phase 3 change.
