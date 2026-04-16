# Phase 5b — Cyberpunk Chrome plan

- **Spec:** `docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md` §Phase 5b
- **Branch:** `feat/phase-5b-cyberpunk-chrome`

## The referent (internalized before writing CSS)

"Partially corrupted holographic interface." The key: these interfaces
were designed to work PERFECTLY. Corporate-clean, engineered, precise.
What we see is the DEGRADATION — the holographic projector is aging,
the signal has interference, the framebuffer has bad sectors. The
aesthetic is not "broken from birth" but "built to spec, now failing."

This means every utility should start from a place of engineered
geometry and THEN introduce the corruption:
- The panel clip-path is precise geometry with one corner that's
  been clipped too aggressively — the manufacturing spec was symmetric,
  the render is not.
- The glitch is RGB channel separation — the display still shows the
  right content but the color channels have drifted apart, like a
  projector with misaligned optics.
- The shear is a holographic tilt — the projection surface isn't
  quite perpendicular to the viewer's angle.
- The labels are system HUD annotations — diagnostic data the system
  is exposing because the UI layer has partially failed.

## Deliverables

| Class | Visual | Auto-applied? |
|-------|--------|---------------|
| `.ng-cyberpunk-panel` | Asymmetric clip-path: top-right heavily notched, bottom-right lightly notched, left side square | Yes — on `.neon-cyberpunk .ng-card` |
| `.ng-cyberpunk-glitch` | RGB channel-split text-shadow (red left, cyan right) with flicker animation on hover | Yes — on `.neon-cyberpunk .ng-card h1-h3` (hover only) |
| `.ng-cyberpunk-shear` | `skewX(-1deg)` holographic tilt | No — opt-in |
| `.ng-cyberpunk-label` | Tiny monospace HUD annotation in palette display-alt font | No — opt-in |

## Implementation notes

### Panel clip-path
Deliberately asymmetric: top-right corner gets a 1.5rem notch
(the "heavy" clip). Bottom-right gets a 0.5rem notch (subtle).
Left side stays square. This reads as "manufactured rectangular,
rendering distorted on one side."

clip-path WILL clip .ng-border-glow pseudo-elements too (they're
children of the clipped element). The glow conforms to the panel
shape — which reads correctly: a holographic panel's glow follows
its frame, doesn't extend past it.

### Glitch text-shadow
Static offset alone reads as "colored shadow," not "glitch." Real
glitches flicker. The implementation uses:
- `--ng-glitch-offset` custom property (default 2px, tuneable)
- `@keyframes ng-cyberpunk-glitch-flicker` with `steps(1)` timing
  (instant transitions, not smooth — glitches SNAP, they don't ease)
- Applied on `:hover` only (constant glitch is exhausting per spec)
- `prefers-reduced-motion` fallback: static offset, no animation

### Shear
`skewX(-1deg)` — barely perceptible. The holographic projection
is slightly off-axis. Opt-in because skewing a card shifts its
bounding box and can create layout surprises.

### Label
Uses --ng-font-display-alt (resolves to Rubik Glitch under Cyberpunk).
The glitch artifacts on tiny HUD labels reinforce "the system's UI
layer is degrading." Palette primary color at reduced opacity.

## Gotcha awareness

- Pseudo-element collisions: NO pseudo-elements used. Panel = clip-path
  on the element. Glitch = text-shadow + animation. Scanlines (if wanted
  later) = background-image. Lesson from Phases 4 and 5a.
- `prefers-reduced-motion`: animation disabled, static fallback shown.
- clip-path + ng-border-glow: glow clips to panel shape. Intentional.
