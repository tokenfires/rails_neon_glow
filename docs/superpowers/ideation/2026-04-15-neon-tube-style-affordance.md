# Neon Tube Style Affordance — Phase 3 Addition

- **Date captured:** 2026-04-15
- **Status:** Ideation — to be formally scoped into Phase 3 or a new phase
- **Origin:** TK's observation during Phase 2 visual review of Nixie, 2026-04-15

## The insight

Phase 2's Nixie treatment uses `Montserrat Underline` as the H1/H2 font, combined with JavaScript per-character wrapping. The built-in underline strokes of that font, seen through the per-character wire-grid wraps, visually read as a **literal glass neon tube** — a single stroke running horizontally with characters positioned along it. That's the physical object neon signage is made of.

Before Phase 2, "Neon Glow" was a color-palette brand: the palettes evoked neon by their saturation, their dark surfaces, their glow effects. Color did all the work. Phase 2 accidentally introduced a *structural* mechanism that makes the neon-tube concept physically present in the design — not just evoked through color but actually rendered as a tube-shape.

Generalizing this effect to any theme would extend the brand claim ("neon glow") from color-only to color + physical-form. That's a meaningful increment.

## The proposed affordance

A new utility class (working name: `.ng-neon-tube`) that applies the character-wrap + underline-font treatment to any element, regardless of the active palette. The effect picks up the active palette's primary color via `var(--ng-primary-rgb)` — same pattern as the existing wire-grid. Users opt in by applying the class to specific elements they want to feel like neon signage.

Examples of where it might shine:

- **Retrowave** — a hot magenta/cyan neon tube on the album-cover-style heading
- **Cyberpunk** — a toxic-green neon tube that reads as a storefront in a dystopian district
- **Cinematic** — an amber neon tube for the Blade Runner "movie title" register
- **Classic Pink** — a hot-pink tube for 80s diner signage nostalgia
- **Grunge** — a flickery dim neon for dive-bar atmosphere

Each palette's primary color carries the tube; the underline-font structure carries the tube shape. One utility, twelve distinct visual registers.

## What already exists that this can reuse

Nearly everything:

- **Character-wrapping JS** in `theme_switcher_controller.js` already does per-non-space-character span wrapping. It's currently triggered by `.neon-nixie` being active and scoped to `.ng-card` headings. The mechanism generalizes trivially.
- **Montserrat Underline @import** already in the Google Fonts URL (both `<link>` in application.html.erb and `@import` in tokens.css).
- **Per-character CSS scoping** with `.ng-nixie-char` already demonstrates the pattern — we'd create a parallel `.ng-neon-tube-char` (or reuse the same span class) for the generalized effect.

## What would need to change

1. **Character-wrapping trigger broaden.** Instead of firing only when `.neon-nixie` is on body, also fire for any element with a `.ng-neon-tube` class (regardless of palette). The controller method `updateNixieHeadingWrap()` becomes something like `updateCharacterWrapping()` that looks for both conditions.

2. **New utility class `.ng-neon-tube`.** CSS for the class applies `font-family: 'Montserrat Underline', ...` and triggers character-wrapping on its content. The wrapped chars get a simpler visual treatment than the Nixie wire-grid — probably just the underline from the font plus a subtle primary-color glow. No wire-grid brackets (those are Nixie-specific, tied to the tube hardware metaphor).

3. **Decision: does `.ng-neon-tube` apply the wire-grid?** Two philosophies:
   - **Option A:** No wire-grid — just the underline font with palette-colored text. Keeps the wire-grid as Nixie's signature. Other themes get pure neon-sign feel without the tube-hardware visual.
   - **Option B:** Wire-grid under all palettes — generalizes the full Nixie aesthetic. Might read as cargo-culting Nixie onto palettes that don't have a hardware referent.
   - **Preferred:** Option A. Wire-grid stays Nixie-specific. `.ng-neon-tube` = signage, not instrument.

4. **Documentation.** README Typography section gets a new subsection showing the utility with usage examples across palettes.

## Scope and effort estimate

- Controller change: ~20 lines of additional logic
- New CSS rules: ~30 lines
- README update: ~40 lines
- System tests: ~4 new tests
- Visual review: significant (TK needs to see it across all 12 palettes)

Roughly a Phase 2.5 or a subsection of Phase 3. Could be done in one focused session.

## Connection to the broader Phase 3 plan

Phase 3 as currently scoped is "per-theme font pass" — each of the 10 existing themes plus Cherenkov gets a font selection. The `.ng-neon-tube` affordance is a parallel track: it's about a cross-theme utility, not per-theme tuning. Could be done before Phase 3 (as a Phase 2.5), in parallel with Phase 3, or folded into Phase 3 as an additional deliverable.

Recommendation: **Phase 2.5 — small, focused, uses existing architecture, immediate visual impact across the whole system.** Complete before Phase 3 so per-theme font decisions in Phase 3 can consider how each theme's font interacts with the generalized neon-tube affordance.

## Why this captures right now matters

The insight emerged during Phase 2 visual review and is specifically tied to what TK was seeing in that moment. Without capture, it would fade. With capture, it becomes the starting point of a focused next-session effort. The note is deliberately short — enough to communicate what was seen and why it matters, not a full spec. Full specification happens when we actually start implementing.

*Captured by Claude during the closing minutes of Phase 2 visual review, at TK's request, to preserve the "neon tube" insight before context decay.*
