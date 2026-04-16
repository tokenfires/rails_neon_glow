# Phase 5c — Grunge Chrome plan

- **Spec:** `docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md` §Phase 5c
- **Branch:** `feat/phase-5c-grunge-chrome`

## The referent (internalized)

90s zine culture. Photocopied flyers stapled to telephone poles outside
venues. Hand-cut and cut-and-paste layouts. Xerox halation. Black-and-
white photographs weathered by bad printing. Pearl Jam's "Ten" album
inserts, Nirvana's handwritten liner notes, KEXP 90.3 flyers for
shows in warehouses. Tape, staples, rubber stamps, ink bleeding
through cheap paper.

The central design tension the spec names: "polished grunge is a
contradiction." CSS produces clean geometry by default. Every
deliberate choice should introduce IMPRECISION — non-round rotation
angles, asymmetric values, noise overlays, hand-drawn SVG paths
instead of geometric polygons. The goal is "deliberately rough,"
not "broken" — those are adjacent lines.

## What grunge ISN'T

- A soft outward glow (that's neon — too clean, too uniform)
- Symmetric anything (kills the handmade feel)
- Round rotation numbers like 2° or -5° (too designed; humans stapling
  flyers don't align to integers)
- Dropshadows with perfect Gaussian blur (too digital; grunge's
  shadows are paper-on-wall, hard-edged)

## Design decisions

### Suppress border-glow under Grunge

Same mechanical reason as Cyberpunk (rotation via transform creates
a stacking context → ng-border-glow::before becomes a visible gradient
fill over the card background → illegible text). Same aesthetic reason
too: grunge cards aren't lit from within. They're paper objects in
dim rooms.

### Replace with paper-on-wall shadow

Hard-edged offset `box-shadow` (no blur) suggests a paper card casting
a shadow on the wall behind it. Physical, low-fidelity, grunge.

### Noise overlay via SVG feTurbulence

SVG filter generates procedural noise. Inlined as data URI (no external
assets). Applied as `background-image` layer (Gotcha #8 — no pseudo-
element collisions). Low opacity (~0.08-0.12) so it reads as texture,
not as visual static that hurts readability.

### Rotation via nth-child, non-round angles

Four rotation angles cycled across cards: -1.2°, 0.7°, -0.5°, 1.5°.
Irrational-looking numbers, never repeating the same value twice in a
row. The effect: a wall of flyers, none quite straight, the pattern
obviously not geometric.

### Torn edge via SVG mask

CSS clip-path polygons look too regular for torn paper. SVG paths
allow hand-drawn nodes with varying tooth sizes. Opt-in — tearing
every card's bottom would be visual noise. Users apply to specific
cards they want to read as "literally torn."

### Stamp utility

Rubber-stamped text on paper: rough border, rotated, ink-uneven.
Opt-in for headline/label use.

## Deliverables

| Class | Visual | Auto-applied? |
|-------|--------|---------------|
| `.ng-grunge-noise` | SVG noise overlay via background-image | Yes — on `.neon-grunge .ng-card` |
| `.ng-grunge-rotate` | Custom-property-driven rotation (`--ng-grunge-angle`) | Yes — nth-child cycles four angles |
| `.ng-grunge-torn` | SVG mask-image for irregular torn bottom edge | No — opt-in (disruptive) |
| `.ng-grunge-stamp` | Rough border + rotation + ink-uneven via noise overlay | No — opt-in |

## Demo content

Kitchen sink Grunge Chrome section: a card with torn edge, stamp
utility showing "DIY OR DIE / ZINE VOL. 03 / 1992," and enough body
text to show the noise overlay at body-text scale. Zine-culture
reference, not band-specific — the flyer is more universally grunge
than any specific album.

## Gotchas in play

- Transform creates stacking context → border-glow must be suppressed
  (same lesson as Cyberpunk, different reason pointing to same fix)
- Noise overlay via background-image (not pseudo-element) per Gotcha #8
- prefers-reduced-motion: rotation is static, no animation, no need
  for fallback
