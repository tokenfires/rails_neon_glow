# Phase 5a — Retrowave Chrome plan

- **Spec:** `docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md` §Phase 5a
- **Branch:** `feat/phase-5a-retrowave-chrome`

## The vocabulary

80s synthwave album-cover geometry. Everything should read as "1986 title
card" or "gatefold inner sleeve." The chrome text is the centerpiece; the
scanlines and grid/horizon are environmental support.

## Deliverables

Four palette-agnostic utility classes + Retrowave auto-application:

| Class | Visual | Auto-applied? |
|-------|--------|---------------|
| `.ng-retrowave-chrome` | Metallic text-shadow stack: layered silver/cyan/magenta shadows | Yes — on `.neon-retrowave .ng-card h1, h2` |
| `.ng-retrowave-scanlines` | Repeating horizontal scanline overlay via `::after` | Yes — on `.neon-retrowave .ng-card` |
| `.ng-retrowave-grid` | Perspective grid floor (vanishing to horizon) via `background-image` | No — opt-in (full-background element) |
| `.ng-retrowave-horizon` | Hard-edged horizon-split gradient with setting sun | No — opt-in (full-background element) |

## Implementation notes

### Chrome text effect
Layered text-shadow stack. Multiple shadow offsets in silver, cyan, and
magenta produce the classic metallic 80s chrome-title look. The shadows
use palette tokens where possible (--ng-primary-rgb, --ng-secondary-rgb)
so the chrome picks up palette colors. Fixed metallic accent layers
(silver/white) provide the reflective highlights.

### Scanlines
Repeating-linear-gradient on a ::after pseudo-element. Alternating 1px
opaque / 1px transparent black lines at very low opacity (0.08-0.12) to
simulate CRT scanlines without hurting readability. Same ::after collision
concern as Phase 4 with ng-border-glow — need to verify and handle.

**Key decision:** scanlines go on ::after (not ::before) because Phase 4
showed us ng-border-glow already uses ::before. Under Retrowave,
ng-border-glow's ::before is NOT suppressed (unlike VFD which suppresses
it) — the gradient border glow fits the Retrowave aesthetic. So scanlines
must use ::after. BUT ng-border-glow also uses ::after for the blur layer.
Solution: suppress only the ::after blur under Retrowave (the soft outer
blur is redundant with the scanline overlay) and use ::after for scanlines.

### Perspective grid
Pure CSS background-image trick: layered linear-gradients creating a
receding grid floor. Controlled via CSS custom properties for line spacing,
color, and horizon position. This is a full-element background effect,
not a pseudo-element, so no collision issues.

### Horizon
A single element with a gradient split: dark sky above, grid below, with
a bright horizontal line at the split point representing the sun touching
the horizon. Opt-in because it's a hero/background element.

## Execution order

1. Implement `.ng-retrowave-chrome` text-shadow stack.
2. Implement `.ng-retrowave-scanlines` with ::after.
3. Handle ng-border-glow ::after collision under Retrowave.
4. Implement `.ng-retrowave-grid` background.
5. Implement `.ng-retrowave-horizon` gradient.
6. Auto-apply chrome + scanlines inside `.neon-retrowave`.
7. Demo placement (home page Retrowave card gets something, kitchen sinks show all four).
8. Tests.
9. README.

## Visual review cues

- Switch to Retrowave: card headings gain metallic chrome outline. Cards
  gain subtle scanline texture.
- Switch away: both effects vanish. No leaks.
- Compare Retrowave cards to a real 80s synthwave album cover. The
  headings should evoke the same chrome-text register.
- The grid and horizon are opt-in: they won't appear unless you add the
  class to an element. Kitchen sink demo shows both.
