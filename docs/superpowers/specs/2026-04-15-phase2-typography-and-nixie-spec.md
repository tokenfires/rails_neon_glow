# Phase 2 — Typography Architecture & Nixie Proof of Concept Design Spec

- **Date:** 2026-04-15 (evening)
- **Status:** Draft — ready for implementation in next session
- **Target branch (when we start):** `feat/phase-2-typography-nixie`
- **Authors:** Claude (design) + TK / TokenFires (direction, visual judgment gates)
- **Companion to:** `2026-04-10-hardware-themes-and-typography-design.md` (the parent design spec, which defined Phase 2 at a high level) and `2026-04-15-phase1.5-overdrive-intensity-design.md` (the adjacent Phase 1.5 spec for format reference).

## What this spec is

A tighter, ready-to-implement specification for Phase 2 — extracted from the parent design spec with specific font picks, exact CSS techniques, and locked-in architectural decisions. Writing this now so that tomorrow's implementation session can execute directly without requiring design re-derivation.

## Summary

Phase 2 does three things:

1. **Add a typography token layer** to `neon_glow`: `--ng-font-display`, `--ng-font-body`, `--ng-font-mono`, and an optional `--ng-font-display-alt` for themes that layer multiple display faces.
2. **Deliver fonts via Google Fonts `@import`** at the top of `tokens.css` — free, OFL-licensed, CDN-delivered, zero bundled files, identical behavior in the Rails demo, the gem, and the npm package.
3. **Ship one proof-of-concept font pairing** — Nixie gets the full treatment (font override + the signature wire-grid frame effect) so we can observe whether the typography architecture holds up end-to-end before committing to per-theme font picks across all 10 existing themes (which is Phase 3 scope).

After Phase 2, every palette other than Nixie continues using the neutral default fonts — no visible change to any other theme. Phase 2 is about validating the architecture, not about redesigning the whole set.

## Prerequisites

- Phase 1 merged to main ✓ (Cherenkov and Nixie palettes live)
- Phase 1.5 merged to main ✓ (Overdrive intensity and per-theme defaults live)
- No open Phase 1 or Phase 1.5 issues blocking typography work

## Design

### The typography token layer

Add these four tokens to the `:root` block in `tokens.css`:

```css
:root {
  /* ... existing color, surface, radius tokens ... */

  /* Typography — required defaults */
  --ng-font-display: 'Inter', system-ui, sans-serif;
  --ng-font-body:    'Inter', system-ui, sans-serif;
  --ng-font-mono:    'JetBrains Mono', ui-monospace, monospace;

  /* Typography — optional fourth slot, fallback to display when not overridden.
     Used by "messy" era themes (Retrowave, Cyberpunk, Grunge) in Phase 3
     to carry a secondary display face for sub-headline roles. */
  --ng-font-display-alt: var(--ng-font-display);
}
```

**Why these defaults:**
- `Inter` is a widely-available, OFL-licensed, humanist sans that disappears into content rather than competing with it. Industry-standard default choice for modern web typography.
- `JetBrains Mono` is an OFL-licensed mono designed specifically for code readability. Commonly paired with Inter.
- Both are on Google Fonts. Both have mature fallback stacks.
- `--ng-font-display-alt` defaults to `var(--ng-font-display)` so themes that don't use the alt slot get one display face everywhere. Themes that do use it (Phase 3's messy era themes) override both tokens to get a layered two-face hierarchy.

### Google Fonts `@import` delivery

Add this at the very top of `tokens.css`, before the `:root` block:

```css
/* Typography delivery — Google Fonts @import.
   See 2026-04-10 design spec for the delivery-mechanism reasoning
   (OFL-only, CDN-delivered, zero bundled font files, identical
   behavior across Rails/gem/npm distributions). */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;700&family=B612+Mono:wght@400;700&display=swap');
```

**What this pulls in:**
- **Inter** weights 400/500/600/700 — default display and body
- **JetBrains Mono** weights 400/700 — default mono
- **B612 Mono** weights 400/700 — Nixie display+body override (see below)

**Why `display=swap`:** text renders in the fallback font immediately and swaps to the Google Font when loaded. No FOIT (flash of invisible text) blocking the page.

**Why only three font families in Phase 2:** we're only overriding one theme (Nixie) so we need one additional font beyond defaults. Phase 3 will add more fonts to this URL as each theme gets its pick.

### Per-component font application

Add these selectors to `components.css`:

```css
/* ============================================================
   TYPOGRAPHY APPLICATION
   Headings/display text get --ng-font-display.
   Subheads and accent elements get --ng-font-display-alt
   (defaults to display unless a theme overrides it separately).
   Body text and paragraphs get --ng-font-body.
   Code/pre/kbd get --ng-font-mono.
   ============================================================ */

.ng-card h1,
.ng-hero,
.ng-display {
  font-family: var(--ng-font-display);
}

.ng-card h2,
.ng-card h3,
.ng-accent {
  font-family: var(--ng-font-display-alt);
}

.ng-card p,
body {
  font-family: var(--ng-font-body);
}

.ng-code,
pre,
code,
kbd,
samp {
  font-family: var(--ng-font-mono);
}
```

**The h1-vs-h2/h3 split is the mechanism for the alt slot.** Themes that override only `--ng-font-display` get one display face everywhere (because alt falls back to display). Themes that override both get a two-face hierarchy.

**`body` getting `--ng-font-body`** propagates the body font to all unstyled text. Headings override that because CSS cascade.

### Nixie font override

In the `.neon-nixie` block (currently in `tokens.css` around line 540+), add:

```css
.neon-nixie {
  /* ... existing color, surface, mercury tokens ... */

  /* Typography — immersion override.
     Nixie uses B612 Mono for both display AND body. The entire
     surface should feel like a continuous instrument readout;
     paragraphs and headings share the same instrument-font
     register. Mono stays default (JetBrains Mono) for code. */
  --ng-font-display: 'B612 Mono', 'Courier New', monospace;
  --ng-font-body:    'B612 Mono', 'Courier New', monospace;
}
```

**Why B612 Mono:** commissioned by Airbus, designed specifically for legibility on cockpit instrument displays. The brief to the designers was "be the font a pilot reads under stress without second-guessing." That design goal maps directly onto the emotional register of real Nixie tubes — 1960s scientific instrumentation, high-reliability readouts, warm trust-this-number feel. OFL-licensed, free, on Google Fonts, mature.

**Comparison candidates (if B612 Mono doesn't land during visual review):**
- **Share Tech Mono** — clean tech-register mono, decent numerals
- **Major Mono Display** — more geometric, good for display sizes specifically
- **Wallpoet** — hand-built sci-fi instrument feel; distinctive but may be too loud

**Fallback chain:** `'B612 Mono', 'Courier New', monospace` — if Google Fonts fails to load, text falls back to Courier New (ubiquitous) and finally to the generic monospace family.

**Why both display and body override:** Nixie is an "immersion theme" (same pattern as VFD will be in Phase 3). The whole surface should read as one continuous instrument. Having a character-specific display face on headings and a neutral body underneath would break the "I'm looking at a single tube readout" illusion.

### The wire-grid frame effect

This is the signature Nixie visual: the metal cathode bracket and vertical wire array behind the glowing digit. The referent is a real Nixie tube's cathode stack — 10 bent-wire numeral cathodes arranged at different depths inside the glass envelope, with support brackets at top and bottom. When one cathode is lit, the rest are visible as thin vertical wires behind and around it.

#### Implementation: CSS-only, no assets

Add to `components.css`:

```css
/* ============================================================
   NIXIE WIRE-GRID FRAME
   The signature Nixie visual: thin vertical cathode wires and
   horizontal support brackets behind the glowing digit. Recreates
   the cathode stack you see through the glass of a lit Nixie tube.

   Auto-applied to card h1/h2 headings inside .neon-nixie below;
   also available as a utility class .ng-nixie-digit for manual
   application to specific elements.
   ============================================================ */

.ng-nixie-digit {
  position: relative;
  display: inline-block;
  padding: 0.3em 0.5em 0.35em;
}

.ng-nixie-digit::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: repeating-linear-gradient(
    to right,
    rgba(var(--ng-primary-rgb), 0.22) 0,
    rgba(var(--ng-primary-rgb), 0.22) 1px,
    transparent 1px,
    transparent 6px
  );
  border-top:    1px solid rgba(var(--ng-primary-rgb), 0.35);
  border-bottom: 1px solid rgba(var(--ng-primary-rgb), 0.35);
  pointer-events: none;
  z-index: -1;
}

/* Auto-apply to card headings inside the Nixie palette */
.neon-nixie .ng-card h1,
.neon-nixie .ng-card h2,
.neon-nixie .ng-card .h1,
.neon-nixie .ng-card .h2,
.neon-nixie .ng-card .display-4,
.neon-nixie .ng-card .display-5 {
  position: relative;
  display: inline-block;
  padding: 0.3em 0.5em 0.35em;
}

.neon-nixie .ng-card h1::before,
.neon-nixie .ng-card h2::before,
.neon-nixie .ng-card .h1::before,
.neon-nixie .ng-card .h2::before,
.neon-nixie .ng-card .display-4::before,
.neon-nixie .ng-card .display-5::before {
  content: "";
  position: absolute;
  inset: 0;
  background-image: repeating-linear-gradient(
    to right,
    rgba(var(--ng-primary-rgb), 0.22) 0,
    rgba(var(--ng-primary-rgb), 0.22) 1px,
    transparent 1px,
    transparent 6px
  );
  border-top:    1px solid rgba(var(--ng-primary-rgb), 0.35);
  border-bottom: 1px solid rgba(var(--ng-primary-rgb), 0.35);
  pointer-events: none;
  z-index: -1;
}
```

**Design decisions and rationale:**

1. **Vertical hairlines via `repeating-linear-gradient`.** 1px opaque, 5px gap, 6px period. Visible but not dominant. Recreates the cathode wire array.

2. **Amber wire color at 0.22 alpha.** Using `--ng-primary-rgb` (the Nixie amber) rather than a neutral gray, because the wires in a real lit Nixie pick up the tube's glow through the glass. A true neutral gray would read "mechanical diagram" rather than "illuminated tube." Low alpha keeps the wires secondary to the digit itself.

3. **Horizontal brackets at 0.35 alpha (slightly more visible than the wires).** Real Nixie tubes have visible support hardware at top and bottom of the cathode stack. Single 1px borders top and bottom recreate this without cluttering.

4. **`z-index: -1` on the pseudo-element** puts the wire grid behind the parent's text content. This works because the parent is `position: relative` (creating a stacking context) and its rendered text defaults to z-index auto, which stacks above the `-1` pseudo-element within the same stacking context.

5. **Padding `0.3em 0.5em 0.35em`** creates breathing room around the glyph so the frame doesn't clip to the text baseline. Slightly more padding on the left/right (the wires extend past the character horizontally) than top/bottom (the brackets sit close).

6. **`display: inline-block`** ensures the pseudo-element positions correctly relative to the character and doesn't break inline flow.

7. **Bootstrap typography class coverage** (`.h1`, `.h2`, `.display-4`, `.display-5`) mirrors the pattern established in Phase 1's hardware heading glow work. Without these, the effect wouldn't apply to Bootstrap-themed headings on the bootstrap kitchen sink page.

#### Why `repeating-linear-gradient` and not SVG dot-matrix

Considered alternatives during design:

- **Inline SVG dot-matrix background** — more flexible, can do actual cathode connection points as dots rather than continuous wires. Rejected for v1: more complex to tune, introduces an inline SVG dependency in the CSS. Upgradeable to later if v1 doesn't land.
- **Actual SVG with hand-drawn bent wire paths** — most physically accurate. Rejected: heavy, requires per-weight hand-tuning, overkill for v1.

The repeating-linear-gradient approach is the cheapest workable technique that produces the intended effect. If it lands, no upgrade needed. If it doesn't, the upgrade path (SVG dot-matrix, then hand-drawn SVG) is clear.

### README updates

Add a new section to README after "Intensity Levels":

```markdown
## Typography

`neon_glow` defines three primary font slots as CSS custom properties:

| Token | Default | Role |
|-------|---------|------|
| `--ng-font-display` | `Inter` | Headlines, hero text, display elements |
| `--ng-font-body` | `Inter` | Paragraphs, body content, unstyled text |
| `--ng-font-mono` | `JetBrains Mono` | Code, pre-formatted text, keyboard input |

An optional fourth slot, `--ng-font-display-alt`, carries a secondary display face for themes that layer multiple display voices (used by some themes in Phase 3). It defaults to `--ng-font-display` so themes that don't use it get one display face everywhere.

Fonts are delivered via Google Fonts `@import` at the top of `tokens.css`. All included fonts are OFL-licensed and free for commercial use.

### Per-theme font overrides

In Phase 2, one theme — **Nixie** — overrides the defaults with `B612 Mono` (a font commissioned by Airbus for cockpit instrument displays) on both display and body slots. This gives Nixie its "continuous instrument readout" register. Nixie also gains a signature wire-grid frame effect on card headings, recreating the cathode stack visible through a real lit Nixie tube.

Additional per-theme font overrides will be added in Phase 3.

### Using custom fonts

Override the tokens in your own CSS to use different fonts:

```css
:root {
  --ng-font-display: 'Your Custom Font', sans-serif;
  --ng-font-body:    'Your Body Font', serif;
  --ng-font-mono:    'Your Mono Font', monospace;
}
```

You can also override per-theme by scoping the override to a palette class:

```css
.neon-cyberpunk {
  --ng-font-display: 'Orbitron', sans-serif;
}
```
```

Also update:
- Tagline: "12 color palettes. 4 intensity levels. **3 typography slots.** Fully open source." — or similar; TK may want to revise wording
- Palette Classes usage block: no changes needed (typography is a separate concern)

## Out of scope (Phase 2 only)

- Per-theme font overrides for any theme other than Nixie (Phase 3)
- Per-theme font overrides for VFD (Phase 3) — including VFD's own B612 Mono override, which will be identical to Nixie's but applied to VFD context
- The wire-grid frame effect on anything other than Nixie card headings
- Era chrome (Phase 4 — chrome vocabulary for Retrowave/Cyberpunk/Grunge)
- VFD hardware chrome (Phase 4 — instrument frame utility classes)
- VFD `--ng-text-inverse` fix (Phase 4 pre-existing gap)
- Any changes to existing palette colors or intensity values
- Updating any palette card's description copy

## Implementation structure

Single feature branch: `feat/phase-2-typography-nixie`. Five tasks, same subagent-driven pattern as Phase 1 and Phase 1.5:

1. **Typography tokens + Google Fonts @import** in `tokens.css`
2. **Per-component application rules** in `components.css`
3. **Nixie font override** in the `.neon-nixie` block in `tokens.css`
4. **Wire-grid frame** (utility class + auto-application to Nixie card headings) in `components.css`
5. **System tests** for typography application and Nixie font switching
6. **README update** with the Typography section
7. **Holistic review + final verification**
8. **TK visual review** (font pick + wire-grid frame evaluation)
9. **Merge** after approval

Implementation plan document to be written at session start.

## Definition of done

- Four typography tokens defined in `:root` with the specified defaults
- Google Fonts `@import` in place at top of `tokens.css`, including Inter, JetBrains Mono, and B612 Mono
- Per-component font application rules in `components.css`
- `.neon-nixie` overrides both `--ng-font-display` and `--ng-font-body` to B612 Mono
- `.ng-nixie-digit` utility class works as a manual-application affordance
- Wire-grid frame auto-applies to `.ng-card h1/h2` inside `.neon-nixie`, including Bootstrap `.h1`/`.h2`/`.display-4`/`.display-5` classes
- README Typography section added; tagline updated
- System tests verify font switching works and the wire-grid frame is present on Nixie card headings
- No regressions on any Phase 1 or Phase 1.5 test
- TK has visually reviewed:
  - Whether B612 Mono on Nixie lands, or whether to try a comparison candidate
  - Whether the wire-grid frame density (6px spacing, 0.22/0.35 alphas) feels right
  - Whether any other theme visibly changed as an unintended side-effect (it shouldn't — all other themes use the neutral defaults)
- Branch merged to main

## Open questions for TK's visual judgment

These are the calls that require his eyes and cannot be decided in code review:

1. **B612 Mono vs. comparison candidates for Nixie.** Start with B612 Mono. If it feels wrong, try Share Tech Mono, Major Mono Display, or Wallpoet in that order. The distinction will be visible on Nixie headings and paragraphs.

2. **Wire-grid frame density.** Starting values: 6px line period, 0.22 alpha on wires, 0.35 alpha on brackets. Tuning candidates if it doesn't land:
   - Too subtle? Drop period to 5px, bump wire alpha to 0.3
   - Too busy? Raise period to 8px, drop wire alpha to 0.15
   - Brackets too faint/loud? Independently tune their alpha
   - Horizontal brackets feel wrong? Remove them — effect becomes wires-only, more minimal

3. **Wire-grid frame scope.** Currently auto-applies to card h1/h2. Should it also apply to:
   - Card h3? (Smaller — might feel cluttered on subheadings)
   - Non-card headings (`<h2>Hardware</h2>` on the home page)? (Would expand the effect's reach)
   - The home page palette card descriptions? (Those are `<p>` text — frame probably doesn't fit paragraphs)

   TK's call. Starting position: h1/h2 in cards only, nothing else.

4. **Whether any paragraph text inside Nixie feels off** now that body text is in B612 Mono. Mono body text is unusual and may take adjustment to read. If it feels wrong, the fallback is to not override `--ng-font-body` for Nixie and only override display, accepting that paragraphs will use Inter. That weakens the "one continuous instrument" register but improves readability for long-form content. TK's call based on what reads well on the kitchen sink pages.

## Connection to Phase 3 and beyond

After Phase 2, the following will be true:
- Typography tokens exist and are consumed
- Google Fonts @import delivery is validated
- One theme (Nixie) demonstrates the full override pattern
- The wire-grid frame as a CSS-only technique is proven

Phase 3 will then:
- Override `--ng-font-display` (and optionally `--ng-font-display-alt` and `--ng-font-body`) for each of the remaining themes, per the font-selection-by-theme notes in the parent design spec
- Extend the Google Fonts `@import` URL to include all picked fonts
- No new architecture — just additional overrides using the Phase 2 infrastructure

Phase 4 (Hardware Chrome, VFD-only) will then build on both Phase 2 (VFD gets B612 Mono override, same pattern as Nixie) and Phase 3 (era themes don't affect VFD).

## Notes for tomorrow's implementation session

- Start by reading this spec, the Phase 1.5 spec (for format/pattern reference), and the parent design spec's Phase 2 section (for broader context)
- Branch: `feat/phase-2-typography-nixie` (create off main)
- Use the same subagent-driven development pattern as Phases 1 and 1.5
- Holistic review at the end (check for cross-cutting references the task reviews missed)
- Halt at the visual-review gate; do not merge without TK's eyes on the font choice and wire-grid frame
- Test coverage should mirror Phase 1.5's approach — use Capybara system tests verifying that Nixie's body gets the B612 Mono family name when Nixie is active, and that the wire-grid frame pseudo-element is present

End of spec.
