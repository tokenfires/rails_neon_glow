# Phase 3 — Per-theme font pass (plan)

- **Spec:** `docs/superpowers/specs/2026-04-15-phase3-per-theme-fonts-spec.md`
- **Branch:** `feat/phase-3-per-theme-fonts`

## Execution order

Three batches, each a discrete commit, each gated by visual review before the next starts.

## Batch 1 — Geometric sans

**Fonts to add:** Orbitron, Syncopate, Space Grotesk (all Google Fonts, OFL, 400+700 weights).

**Steps:**
1. Extend Google Fonts URL in `tokens.css` `@import` and `application.html.erb` `<link>` with the three new families.
2. In `tokens.css`, inside `.neon-retrowave` block, override `--ng-font-display` to `'Orbitron', system-ui, sans-serif`.
3. In `tokens.css`, inside `.neon-y2k` block, override `--ng-font-display` to `'Syncopate', system-ui, sans-serif`.
4. In `tokens.css`, inside `.neon-cherenkov` block, override `--ng-font-display` to `'Space Grotesk', system-ui, sans-serif`.
5. In `test/system/hardware_palettes_test.rb` (or new `typography_test.rb` if it grows too large), add three tests asserting computed `font-family` on a display element (H2 on home page is convenient) contains the expected face name when each palette is active.
6. Update README Typography → per-theme overrides section with the three new entries.
7. Commit with descriptive message. Wait for TK visual review.

**Review cue for TK:** on each of the three palettes, does the H1/H2 treatment across home page + kitchen sinks feel *of its referent*? Retrowave should feel 1986. Y2K should feel 2002. Cherenkov should feel like a scientific instrument.

## Batch 2 — Monospace-adjacent

**Fonts to add:** Share Tech Mono, VT323.

**Steps:**
1. Extend Google Fonts URL with the two new families.
2. Override `--ng-font-display` in `.neon-cyberpunk` → Share Tech Mono.
3. Override `--ng-font-display` in `.neon-vfd` → VT323.
4. Tests: 2 new system tests.
5. README update.
6. Commit, review.

**Review cue for TK:** does Cyberpunk read as a corporate dystopia UI? Does VFD read as an actual vacuum-fluorescent segmented display with its new typeface? Watch especially that VT323 on VFD headings isn't so pixelated that the VFD palette's hue adjustability gets overshadowed.

## Batch 3 — Character pieces

**Fonts to add:** Special Elite. (Social uses native system stack, no download.)

**Steps:**
1. Extend Google Fonts URL with Special Elite.
2. Override `--ng-font-display` in `.neon-grunge` → Special Elite.
3. Override `--ng-font-display` AND `--ng-font-body` in `.neon-social` → native system stack.
4. Tests: 2 new system tests (Grunge font-family + Social using native stack, which requires testing for absence of Inter rather than presence of a named face).
5. README update.
6. Commit, review.

**Review cue for TK:** does Grunge read like a xeroxed flyer? Does Social feel unmistakably mobile-first / platform-native? Check Social body text especially — this is the one palette where BODY font changes, not just display.

## Rollback strategy

Each batch is a single commit. If a batch's visual review fails, either tune in a follow-up commit on the same branch, or `git revert <batch-commit>` and re-approach.

## Merge

After all three batches pass review: fast-forward merge to main (pattern from Phases 1, 1.5, 2, 2.5).

## Out-of-scope cleanups noticed during Phase 3 (log them for Phase 3.1)

Any stylistic inconsistencies surfaced by the font pass (e.g. a heading-size assumption that works for Inter but breaks for Orbitron) should be captured here, not fixed inline, unless they make a palette ship broken.
