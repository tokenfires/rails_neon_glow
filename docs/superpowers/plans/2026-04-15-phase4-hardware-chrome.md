# Phase 4 — Hardware Chrome (VFD-only) plan

- **Spec:** `docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md` §Hardware Chrome
- **Branch:** `feat/phase-4-hardware-chrome`

## Deliverables (from spec)

Five palette-agnostic utility classes + VFD-specific auto-application:

| Class | Visual | Notes |
|-------|--------|-------|
| `.ng-instrument-frame` | Hard-edged bezel, recessed inset shadow | The core transform: soft card → instrument panel |
| `.ng-chamfer` | 45° clipped corners via `clip-path` | The 70s-80s approximation of radius |
| `.ng-vfd-separator` | Hairline horizontal rule, hard edges | Divides display regions |
| `.ng-vfd-label` | Tiny all-caps mono label | The "TREBLE" / "BASS" / "VOL" labels |
| `.ng-vu-segment` | Trapezoidal fan-out segment | For VU-meter-style indicators |

Auto-application inside `.neon-vfd`:
- `.ng-card` gains instrument-frame behavior automatically (zero user classes needed)
- `data-vfd-label` attribute on any `.ng-card` renders a tiny label in the top-left via `::before`
- `.ng-card` under VFD needs `position: relative` for the label pseudo-element to land

Also riding along: fix VFD's `--ng-text-inverse` override (pre-existing Phase 1 bug).

## Execution order

1. Add the five utility classes to components.css (new section after Nixie wire-grid).
2. Add the `.neon-vfd .ng-card` auto-apply block.
3. Fix `--ng-text-inverse` in VFD palette block in tokens.css.
4. Add `data-vfd-label` attributes to VFD card on home page + kitchen-sink demos.
5. System tests: instrument-frame computed styles under VFD, label renders, non-VFD unaffected.
6. README: new "Hardware Chrome" section documenting utilities + usage.
7. Full test suite green → commit → visual review.

## Visual review cues

- Switch to VFD: every card on the page should snap from rounded-edge soft card to hard-edged instrument panel with recessed shadow.
- If a card has `data-vfd-label="DISPLAY"`, a tiny monospace label should appear in the top-left corner.
- Switch away from VFD: cards return to their soft-edge default. No chrome leaks.
- Try VFD hue slider: the chrome should hold across all hues (the utilities use palette tokens, not hardcoded colors).

## Constraints from spec

- CSS-only. No canvas, no SVG.
- Palette-agnostic primitives. Auto-application scoped to VFD. Users can apply `.ng-instrument-frame` etc. on any palette manually.
- Does NOT apply to Nixie or Cherenkov (per spec: Nixie = individual glass envelopes, not panels. Cherenkov = no device. VFD = the only palette whose physical referent lives inside bezeled hardware.)
