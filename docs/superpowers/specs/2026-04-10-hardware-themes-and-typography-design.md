# Hardware Themes & Typography — Design Spec

- **Date:** 2026-04-10
- **Status:** Draft — awaiting final review
- **Branch:** `design/hardware-themes-and-typography`
- **Authors:** Claude (design, writing) + TokenFires (direction, review)

## Summary

Expand `rails_neon_glow` along three orthogonal axes:

1. **Palette additions.** Add two new color palettes — **Cherenkov** (deep physically-accurate reactor-pool blue) and **Nixie** (warm amber-orange neon-discharge glow with mercury-violet fringe). Both belong to the existing `Hardware` optgroup, joining VFD Display.
2. **Typography architecture.** Introduce a three-slot font token layer (`--ng-font-display`, `--ng-font-body`, `--ng-font-mono`) that palettes can override independently from color, delivered via Google Fonts `@import` with an OFL-only licensing constraint. Apply per-component typography to the existing 10 palettes plus Cherenkov as a follow-up pass.
3. **Hardware Chrome (VFD-only).** Introduce palette-agnostic component utility classes for instrument-panel affordances — hard-edged bezels, trapezoidal VU segments, hairline separators, chamfered corners, tiny all-caps labels — and auto-apply them to the VFD theme so it reads like a real 1970s-80s audio-component display.

These ship as four phased, independently releasable milestones. Each phase leaves the repo, gem, and npm package in a shippable state.

## Why

`rails_neon_glow` exists because the user wanted to give Claude a creative playground. The aesthetic *is* the product; there is no external customer. Every design decision in this spec is optimized for "does this feel authentic, hit hard, and delight someone who sees it for the first time" over conventional delivery metrics. The explicit user directive for this project: propose strong opinionated takes, make design decisions with conviction, iterate based on review rather than up-front committee.

The current palette set has grown to 10 palettes across two optgroups (`Eras` and `Hardware`). The `Hardware` group has a single occupant — VFD Display — and its identity as *"real-world physical light sources with specific non-arbitrary colors"* is strong but underpopulated. Cherenkov and Nixie are both physically grounded (reactor-pool blue and neon-gas-discharge amber respectively), which extends the category coherently rather than diluting it.

Typography is currently unaddressed. All palettes inherit whatever font the host page uses, which means a theme that could be doing 90% of the work is doing 50%. Adding a font layer is the single highest-leverage improvement to the system's visual impact.

## Design principles

These principles govern every decision in this spec and should be used to resolve ambiguity in implementation.

1. **Physical authenticity over aesthetic approximation.** When a palette is based on a real light source (VFD phosphor, Cherenkov radiation, Nixie discharge), the primary color must be correct within ±5° of hue, not "close enough." Derived tokens (secondary, accent, border) stay in a narrow hue band around the primary — no complementary-color drift.
2. **Dark surfaces first.** Every palette in this set uses a dark background. Light content on dark surfaces is the defining characteristic of `neon_glow`. Cherenkov and Nixie inherit this without exception.
3. **Glow effects must not drift the color.** Text shadows, box shadows, and gradients stay within the same hue family as the primary. No warm-to-cool gradients. No white hotspot centers. The authenticity of the color is the product; any effect that dilutes it is removed.
4. **Palette, typography, and component chrome are orthogonal layers.** A user consuming the gem should be able to mix-and-match — e.g., "give me the Cherenkov colors but keep my own body font." The token architecture enforces this by making each layer independently overridable.
5. **OFL-only for all bundled or referenced fonts.** No proprietary fonts, no fan-extracted game fonts, no grey-market downloads. Every font referenced in this project must be available on Google Fonts under the Open Font License or Apache License. This is a hard constraint.
6. **Shippable at every phase boundary.** No phase depends on a later phase being complete. The end of each phase is a valid, taggable release.

## Context — where the project stands

Relevant current state of the repo, verified against `main` on 2026-04-10:

- **10 palettes** defined in `app/assets/stylesheets/neon_glow/tokens.css`: Rainbow, Unicorn, Cinematic, Pink, Retrowave, Grunge, Y2K, Social, Cyberpunk, VFD Display.
- **Theme switcher** at `app/javascript/controllers/theme_switcher_controller.js` handles palette switching + VFD-specific hue slider and preset controls.
- **VFD** is architecturally special: it uses a `--ng-vfd-hue` custom property and derives all colors via `hsl(var(--ng-vfd-hue), ...)`, allowing a single slider to rotate the entire "phosphor lens" through the color wheel. This pattern is not copied by Cherenkov or Nixie — both are deliberately locked to a single physically-correct hue.
- **Home page** at `app/views/pages/home.html.erb` displays palette cards in two sections: Eras and Hardware. The Hardware section currently contains one card (VFD Display).
- **README** credits *"Designed by Claude (Anthropic) in collaboration with TokenFires."*
- **Distribution targets:** the Rails app in this repo is the reference/demo; a Ruby gem is published to rubygems.org and an npm package to npmjs.com, both from the `TokenFires` GitHub account. Any changes to `tokens.css` ripple through all three distribution targets.

## The two new palettes

### Cherenkov

**Concept.** The blue glow of charged particles moving faster than the phase velocity of light through water — the iconic "nuclear reactor pool" blue. Discovered by Pavel Cherenkov in 1934. The glow is caused by photons being emitted as a coherent shock-front because the particle is outrunning its own light; the result is a deep saturated blue-violet with an underwater volumetric quality.

**Class name:** `.neon-cherenkov`. Named after the discoverer so users who don't recognize the term have a reason to search for it, and when they do they find reactor-pool photography and physics backstory — a small "oh wow" payload embedded in the name.

**Color specification:**

| Token | HSL | Rationale |
|---|---|---|
| `--ng-primary` | `hsl(220, 100%, 60%)` | The locked signature hue. Deep saturated blue with a faint violet lean (220° rather than 210°). Not cyan. Not electric. Specifically *this* blue. |
| `--ng-secondary` | `hsl(215, 80%, 50%)` | Minor shift toward pure blue, lower lightness for depth. |
| `--ng-accent` | `hsl(225, 90%, 70%)` | Slight violet push, higher lightness for highlight moments. |
| `--ng-success` | `hsl(195, 80%, 55%)` | Shifted slightly toward cyan for semantic differentiation without breaking the blue family. |
| `--ng-warning` | `hsl(245, 70%, 60%)` | Shifted toward violet — the hue family still holds. |
| `--ng-danger` | `hsl(30, 90%, 55%)` | One deliberate break: danger is orange, the complementary signal. Used sparingly and intentionally. |
| `--ng-info` | `hsl(210, 60%, 55%)` | Quieter blue for ambient info. |

**Surfaces:**

| Token | Value | Rationale |
|---|---|---|
| `--ng-bg` | `#030510` | Ultra-dark blue-black. Not pure `#000` — a faint blue tint implies the viewer is *already underwater* before any glow appears. |
| `--ng-surface` | `#060818` | Slightly raised, same tint progression. |
| `--ng-surface-raised` | `#0a0c22` | Further raised. |
| `--ng-surface-overlay` | `#0f1230` | Topmost. |
| `--ng-border` | `hsl(220, 50%, 15%)` | Dark border in-hue. |
| `--ng-border-subtle` | `hsl(220, 40%, 10%)` | Subtlest border. |
| `--ng-text` | `hsl(220, 40%, 85%)` | Primary text — softly blue-tinted white. Do not use pure white; it breaks the "underwater" consistency. |
| `--ng-text-secondary` | `hsl(220, 30%, 65%)` | Secondary text. |
| `--ng-text-muted` | `hsl(220, 25%, 45%)` | Muted. |

**Glow character — volumetric underwater.** The signature effect for Cherenkov is *soft large-radius bloom*, not sharp electric glow. Think of a point light source seen through several feet of moving water: the edges are diffuse, the bloom extends far beyond the element boundary, and the color stays *absolutely* in-family.

```css
--ng-glow-primary:
  0 0 20px  hsla(220, 100%, 60%, 0.6),
  0 0 40px  hsla(220, 100%, 60%, 0.4),
  0 0 80px  hsla(220, 100%, 55%, 0.25),
  0 0 120px hsla(220, 100%, 50%, 0.15);
```

Four layers, exponentially growing radius, decreasing opacity, hue and saturation locked. No white center layer (the thing that would "cheat" most glow effects into looking punchier but would break authenticity).

**Gradient:**

```css
--ng-gradient: linear-gradient(
  135deg,
  hsl(220, 100%, 60%) 0%,
  hsl(215, 80%, 45%) 50%,
  hsl(220, 100%, 60%) 100%
);
```

**Border radius:** inherits `neon_glow` defaults. No special radius treatment — Cherenkov is not hardware chrome.

### Nixie

**Concept.** Nixie tubes are 1950s-60s gas-discharge display devices — neon gas with trace mercury vapor, wire-cathode numerals stacked at different depths inside a glass envelope, ~170V ignition. The lit cathode produces a warm amber-orange glow (the neon spectral line at ~605-620nm) with a faint violet-pink fringe at the base from the mercury component. Used in frequency counters, lab instrumentation, and early clocks. Aesthetically: mid-century scientific precision, hand-built, warm, reverent.

**Class name:** `.neon-nixie`.

**Color specification:**

| Token | HSL | Rationale |
|---|---|---|
| `--ng-primary` | `hsl(22, 100%, 55%)` | The locked signature hue. Warm amber-orange with a slight red lean — the real neon discharge line, not "orange" generically. |
| `--ng-secondary` | `hsl(18, 95%, 45%)` | Slight red shift, lower lightness. |
| `--ng-accent` | `hsl(28, 100%, 65%)` | Slight yellow shift, higher lightness for highlight moments. |
| `--ng-success` | `hsl(40, 90%, 55%)` | Shifted toward yellow. |
| `--ng-warning` | `hsl(12, 95%, 55%)` | Shifted toward red. |
| `--ng-danger` | `hsl(280, 70%, 55%)` | Deliberate break: danger uses the mercury-violet accent as a semantic anti-color. This violet is also the fringe color, so danger states feel like the tube is misbehaving — a subtle narrative touch. |
| `--ng-info` | `hsl(22, 50%, 60%)` | Desaturated in-family. |

**Mercury-violet accent:**

| Token | Value | Rationale |
|---|---|---|
| `--ng-nixie-mercury` | `hsl(280, 80%, 50%)` | The cool violet fringe color. Used for fringe highlights on letters and the fallback "violet base pool" effect. |

**Surfaces:**

| Token | Value | Rationale |
|---|---|---|
| `--ng-bg` | `#0d0706` | Warm near-black. The faint red tint evokes looking at an unlit tube through tinted bakelite housing. |
| `--ng-surface` | `#130907` | Slightly raised. |
| `--ng-surface-raised` | `#1a0d09` | Further raised. |
| `--ng-surface-overlay` | `#22120c` | Topmost. |
| `--ng-border` | `hsl(22, 40%, 15%)` | Warm dark border. |
| `--ng-border-subtle` | `hsl(22, 30%, 10%)` | Subtlest border. |
| `--ng-text` | `hsl(22, 50%, 85%)` | Softly amber-tinted white. |
| `--ng-text-secondary` | `hsl(22, 35%, 65%)` | Secondary. |
| `--ng-text-muted` | `hsl(22, 25%, 45%)` | Muted. |

**Glow character — layered parallax with mercury fringe.** The signature effect for Nixie is *stacked multi-layer text-shadow with subtle positional offset*, evoking the physical fact that cathode digits sat at different depths inside the tube. The outer-most layer also carries a tiny hint of mercury-violet to imply the fringe.

```css
--ng-glow-primary:
  0 0 2px   hsl(22, 100%, 75%),
  0 0 8px   hsl(22, 100%, 55%),
  0 0 20px  hsl(18, 100%, 45%),
  2px 3px 30px hsla(15, 100%, 40%, 0.6),
  0 0 40px  hsla(280, 80%, 50%, 0.15);
```

The 2px/3px offset on the outer amber layer is the parallax hint. The final violet layer is the mercury fringe — very low opacity, large radius, barely perceptible until you look for it.

**Fallback:** if implementing the inset/fringe version of the mercury violet proves technically finicky (CSS `text-shadow` does not do inset highlights and the fringe-around-letters effect requires stacking), fall back to placing the violet as a *base pool* beneath the character via a `::after` pseudo-element:

```css
.neon-nixie h1::after {
  content: "";
  position: absolute;
  bottom: -0.1em;
  left: 10%;
  right: 10%;
  height: 0.3em;
  background: radial-gradient(ellipse at center, hsla(280, 80%, 50%, 0.4) 0%, transparent 70%);
  filter: blur(8px);
  pointer-events: none;
}
```

This matches the "violet pool at the base of the tube" appearance seen in photos of real lit Nixies and is equally authentic to the physical hardware. Both are valid; decide during implementation based on which reads better in context.

**Border radius:** matches VFD's near-zero radius treatment. Real Nixie tubes are cylindrical glass — nothing about them is "rounded" in the CSS sense, and hard edges reinforce the instrument feel.

```css
--ng-radius-sm: 0.125rem;
--ng-radius:    0.125rem;
--ng-radius-lg: 0.125rem;
--ng-radius-xl: 0.25rem;
```

**Why Nixie does *not* get a hue slider like VFD.** Part of Nixie's identity is that real tubes came in exactly one color. The locked hue is a deliberate narrative contrast with VFD ("VFD = change the lens; Nixie = one true color"). Adding a slider would break this.

## Typography architecture

### Token layer

Add three new CSS custom properties to the `:root` block in `tokens.css`:

```css
:root {
  /* ... existing color tokens ... */

  /* Typography */
  --ng-font-display: 'Inter', system-ui, sans-serif;
  --ng-font-body:    'Inter', system-ui, sans-serif;
  --ng-font-mono:    'JetBrains Mono', ui-monospace, monospace;
}
```

**Defaults** are deliberately neutral — the `Inter` family for display/body and `JetBrains Mono` for mono. Themes that want a personality override `--ng-font-display` (and optionally `--ng-font-body`) in their own class block.

**Per-component application** inside the `neon_glow` CSS:

```css
.ng-card h1, .ng-card h2, .ng-card h3,
.ng-hero, .ng-display { font-family: var(--ng-font-display); }
.ng-card p, body { font-family: var(--ng-font-body); }
.ng-code, pre, code { font-family: var(--ng-font-mono); }
```

This is where the design principle of *display ≠ body ≠ mono* is enforced. Each font does a specific job:

- **Display** carries theme personality. Grabs attention, can afford to be weird and loud. Read for ≤ 10 seconds at a time.
- **Body** disappears so content is readable. Should be *boring on purpose*. A weird body font is a usability crime.
- **Mono** is functional. Same width per character. Used only where alignment matters.

**The pairing rule:** display fonts pair with *neutral* body fonts, not other display fonts. Cinzel + a delicate serif body? Good. Cinzel + Wallpoet body? Visual seizure. The display does the personality work so the body doesn't have to.

**Neutral body rotation** (small, opinionated list — not every Google Font):

- `Inter` — modern sans, the default
- `Source Sans 3` — humanist sans, slightly warmer
- `IBM Plex Sans` — corporate-technical
- `Source Serif 4` — for themes that want editorial feel (Cinematic, Classic Pink)

**Mono rotation:**

- `JetBrains Mono` — default
- `IBM Plex Mono` — for technical themes
- `B612 Mono` — for instrument themes (see Nixie)

**Immersion theme exceptions.** VFD and Nixie override `--ng-font-body` as well as display, because their entire surface is meant to feel like a single instrument. A paragraph of body text on a VFD theme should look like it's being rendered by the phosphor display, not inserted into it.

### Delivery mechanism

Google Fonts via `@import` at the top of `tokens.css`:

```css
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=JetBrains+Mono:wght@400;700&display=swap');
```

**Why `@import` and not `<link>` tags in the Rails layout:**

1. The `tokens.css` file is the single shared artifact across the Rails demo, the gem, and the npm package. Putting the `@import` inside it means a consumer of the gem gets the fonts automatically with zero extra setup.
2. Consumers who don't want the fonts can override `--ng-font-*` tokens in their own CSS and the `@import` becomes harmless dead weight (~1KB of unused CSS).
3. `display=swap` is set so text renders in the fallback font immediately and swaps to the Google Font when loaded. No FOIT (flash of invisible text) blocking the page.

**Why not self-hosted WOFF2:**

1. Font files would need to be bundled into the gem, the npm package, and the Rails asset pipeline separately — three places to keep in sync.
2. Bundle size cost (~30-80KB per font face).
3. Licensing attribution for self-hosted OFL fonts is our responsibility to track and propagate. Google Fonts handles the attribution server-side.
4. Users who override our font tokens are still paying the bundle cost for fonts they don't use.

Google Fonts is the correct tradeoff for a distributed theme system.

### Constraint: OFL-only

No font is referenced in this project unless it is available on Google Fonts under the Open Font License or Apache License 2.0. This is enforced at two points:

1. **At spec time** — any font proposed in this document or its implementation plans must be verifiable on `fonts.google.com`.
2. **At review time** — any PR adding a new font must include a link to its Google Fonts page in the commit message.

Specifically prohibited, regardless of how tempting:

- **Any proprietary font** (Rage Italic from Cyberpunk 2077, anything from Disney, Apple system fonts redistributed, etc.).
- **Any fan-extracted font from copyrighted media.** Fan-made Nixie fonts scraped from Steins;Gate (e.g., the BONX family from `zyf722/Max-s-Divergence-Meter`) are explicitly prohibited — the repo's own README credits the fonts as copyright works of 5pb./Nitroplus. MIT on the project does not cover bundled fonts.
- **Grey-market "free to download" fonts** from single-developer repos where licensing is unclear.

### Font selection philosophy by theme

Phase 3 will pick fonts for every theme. The selection reasoning for each follows the same template: *what physical/cultural artifact is this theme evoking, and what font did that artifact actually use or what OFL font most faithfully evokes the same register?*

Starting positions (confirmed during implementation):

- **VFD** — `B612 Mono` for both display and body. Commissioned by Airbus for cockpit instrument readouts, designed for high-reliability legibility. Authentic to the "instrument display" register. Both-slot override.
- **Nixie** — `B612 Mono` as starting candidate, with `Share Tech Mono`, `Major Mono Display`, and `Wallpoet` as comparison candidates. Final pick decided during Phase 2 implementation based on in-context evaluation. Both-slot override.
- **Cherenkov** — neutral display, maybe `IBM Plex Sans` or `Inter Tight`. Cherenkov is a *phenomenon*, not a cultural era or device — there is no "cherenkov font." The typography should stay out of the color's way. Display-only override; body stays default.
- **Cyberpunk** — OFL alternative to Rage Italic. Starting candidates: `Orbitron`, `Audiowide`, `Syncopate`, `Michroma`. Wide, angular, geometric display faces. Display-only override.
- **Retrowave** — the era used *multiple* display fonts per layout. Primary candidate: a thick chrome-outline display face; `Monoton` or `Bungee Shade` for that "80s synthwave album cover" vibe. Display-only override; consider a secondary accent font for headlines vs sub-headers.
- **Grunge** — the era was deliberately disjointed. Starting candidates: `Special Elite` (typewriter), `Rock Salt` (hand-scrawled), possibly mixed. Grunge is the one theme where using *two* display fonts simultaneously is on-brand, not a violation.
- **Y2K** — boy-band/bubble-gum era. Starting candidates: `Bungee`, `Righteous`, something glossy and round. Candidate: `Michroma` for the Y2K futurism angle.
- **Cinematic** — `Cinzel`. Trajan-adjacent, OFL, the movie-poster font. High confidence.
- **Classic Pink** — editorial feminine register, not cliche. Starting candidates: `Playfair Display`, `Cormorant Garamond`, `Italiana`. Delicate display serifs.
- **Unicorn** — deliberately playful. Starting candidates: `Fredoka`, `Lobster`, `Pacifico`. Cliche is on-brand here.
- **Social (2010s)** — the era of corporate-friendly sans-serifs. Starting candidates: `Work Sans`, `DM Sans`, `Nunito`. Display-only override.
- **Rainbow** — neutral. Rainbow is about the color gradient; typography should not compete. `Inter` default is probably right.

These are *starting positions*, not final picks. Final selection happens in Phase 3 with in-context review.

## Hardware Chrome (Phase 4, VFD-only)

### Concept

Classic VFD instrument chrome has a specific visual vocabulary that came from the physical constraints of 1970s-80s audio component design and fluorescent segment manufacturing. When the VFD palette currently switches on, it changes the *colors* of the existing `.ng-card` components but leaves them as generic rounded rectangles with soft edges. This phase adds a set of palette-agnostic component utility classes that provide the missing chrome vocabulary, then auto-applies them inside the VFD palette context so that activating VFD makes the cards *look like a real 1980s Pioneer stereo readout*.

### The vocabulary

The following classes are added to `neon_glow` CSS as palette-agnostic utilities. They do not care which palette is active — they are pure visual primitives. They are auto-applied inside the VFD palette context via descendant selectors.

#### `.ng-instrument-frame`

Hard-edged rectangular bezel with recessed inset shadow. This is the single most important utility — it transforms a soft card into an "instrument panel window."

```css
.ng-instrument-frame {
  border: 2px solid var(--ng-border);
  border-radius: 0;
  box-shadow:
    inset 0 0 0 1px var(--ng-border-subtle),
    inset 0 2px 8px rgba(0,0,0,0.6),
    inset 0 -2px 8px rgba(0,0,0,0.4);
  padding: 1rem 1.25rem;
  background: var(--ng-surface);
}
```

#### `.ng-chamfer`

45° chamfered corners via `clip-path`. The era's closest approximation to rounded corners.

```css
.ng-chamfer {
  clip-path: polygon(
    0.5rem 0, calc(100% - 0.5rem) 0,
    100% 0.5rem, 100% calc(100% - 0.5rem),
    calc(100% - 0.5rem) 100%, 0.5rem 100%,
    0 calc(100% - 0.5rem), 0 0.5rem
  );
}
```

#### `.ng-vfd-separator`

Hairline horizontal rule with hard edges. Used to divide display regions.

```css
.ng-vfd-separator {
  height: 1px;
  background: linear-gradient(
    to right,
    transparent 0%,
    var(--ng-border) 10%,
    var(--ng-border) 90%,
    transparent 100%
  );
  margin: 0.75rem 0;
}
```

#### `.ng-vfd-label`

Tiny all-caps hairline label for functional zones. The "TREBLE", "BASS", "VOL" labels on real audio components.

```css
.ng-vfd-label {
  font-family: var(--ng-font-mono);
  font-size: 0.625rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: var(--ng-text-muted);
  font-weight: 400;
}
```

#### `.ng-vu-segment`

Trapezoidal fan-out segment for VU meter style indicators. The thing the user was trying to describe — each segment slightly wider than the previous, creating a fan.

```css
.ng-vu-segment {
  clip-path: polygon(15% 0, 85% 0, 100% 100%, 0 100%);
  background: var(--ng-primary);
  box-shadow: var(--ng-glow-primary);
}
```

### Auto-application to VFD

Inside the `.neon-vfd` block context, cards and other container elements automatically receive the instrument chrome treatment:

```css
.neon-vfd .ng-card {
  /* inherit .ng-instrument-frame behavior */
  border: 2px solid var(--ng-border);
  border-radius: 0;
  box-shadow:
    inset 0 0 0 1px var(--ng-border-subtle),
    inset 0 2px 8px rgba(0,0,0,0.6),
    inset 0 -2px 8px rgba(0,0,0,0.4),
    var(--ng-glow-primary);
}

.neon-vfd .ng-card::before {
  content: attr(data-vfd-label, "");
  position: absolute;
  top: 0.5rem;
  left: 0.75rem;
  /* inherit .ng-vfd-label typography */
  font-family: var(--ng-font-mono);
  font-size: 0.625rem;
  text-transform: uppercase;
  letter-spacing: 0.2em;
  color: var(--ng-text-muted);
}
```

This means *any* card rendered when `.neon-vfd` is active becomes an instrument panel without the consumer having to add a single class. The `data-vfd-label` attribute is optional — if not set, the label simply doesn't render. Opt-in flavor on top of automatic base chrome.

### Why VFD-only (not Nixie or Cherenkov)

Per direction: VFD is the theme that historically appeared inside consumer hardware with visible bezels, separators, and labeling. Nixie tubes were individual glass envelopes, not framed display surfaces — applying instrument chrome to Nixie would feel wrong. Cherenkov is a phenomenon with no device at all. VFD is the only theme in the set where the chrome vocabulary is physically appropriate.

**Architectural note on extensibility:** the utility classes themselves are palette-agnostic. If a future phase wants to apply `.ng-instrument-frame` manually to a specific Nixie component, or to an arbitrary user component outside any theme, the primitive exists. We are *scoping auto-application* to VFD, not *restricting availability* of the classes.

## Phased delivery plan

Each phase ends in a working, shippable, taggable release of the gem and npm package.

### Phase 1 — Hardware Pair (color only)

**Scope.**
- Add `.neon-cherenkov` palette block to `tokens.css` with the exact color specification above.
- Add `.neon-nixie` palette block to `tokens.css` with the exact color specification above, including the `--ng-nixie-mercury` accent token.
- Add `"neon-cherenkov"` and `"neon-nixie"` to the `PALETTES` array in `theme_switcher_controller.js`.
- Add two new `<option>` entries in the `Hardware` optgroup of `app/views/shared/_navbar.html.erb`.
- Add two new palette cards to the Hardware section of `app/views/pages/home.html.erb`.
- Update the README palette count from 10 → 12.

**Out of scope for Phase 1:**
- Typography (Phase 2).
- Instrument chrome (Phase 4).
- Font `@import` (Phase 2).

**Definition of done.**
- Running the Rails demo, selecting Cherenkov from the palette dropdown visibly changes the page to deep reactor-pool blue with volumetric glow.
- Same for Nixie with warm amber-orange glow and mercury-violet accent behavior on danger state.
- Gem and npm package can be re-built from this state and consumed by a downstream app that gets the new palettes automatically.
- No regressions on the existing 10 palettes.

### Phase 2 — Typography Architecture + Nixie Proof of Concept

**Scope.**
- Add `--ng-font-display`, `--ng-font-body`, `--ng-font-mono` tokens to `:root` in `tokens.css` with neutral defaults (`Inter`, `Inter`, `JetBrains Mono`).
- Add Google Fonts `@import` to the top of `tokens.css` for the default rotation.
- Add per-component font application rules to `neon_glow` CSS (`.ng-card h1-h3` → display, `.ng-card p` → body, `pre/code` → mono).
- Override `--ng-font-display` and `--ng-font-body` in the `.neon-nixie` block with the picked Nixie font (starting candidate: `B612 Mono` both slots; final pick decided during implementation review).
- Add a new palette-agnostic utility class `.ng-nixie-digit` to `neon_glow` CSS that applies the wire-grid frame effect (the "metal cathode bracket" behind the glyph) via a pseudo-element with a repeating-linear-gradient or SVG dot-matrix background. This ships in the gem and npm package, not just the Rails demo.
- Auto-apply `.ng-nixie-digit` behavior to `.ng-card h1, .ng-card h2` descendants inside `.neon-nixie` via a descendant selector, so consumers get the frame effect on card headings automatically. Consumers can opt additional elements in by applying `.ng-nixie-digit` manually.
- Document the typography token system and the `.ng-nixie-digit` utility in the gem and npm package READMEs.

**Out of scope for Phase 2:**
- Font overrides for any theme other than Nixie (Phase 3).
- Instrument chrome (Phase 4).

**Definition of done.**
- Switching to Nixie palette visibly changes fonts as well as colors.
- Numbers/digits rendered in Nixie context display the wire-grid frame effect behind them.
- Gem and npm package READMEs document how to override the font tokens.
- No regressions on existing palettes — their appearance should be unchanged since they still use the neutral defaults.

### Phase 3 — Font Pass: Existing Themes + Cherenkov

**Scope.**
- Per-theme font override in each palette class block for all 11 themes: Rainbow, Unicorn, Cinematic, Pink, Retrowave, Grunge, Y2K, Social, Cyberpunk, VFD, Cherenkov.
- Each theme gets a researched display font pick from Google Fonts, paired with a neutral body (or full immersion override where the theme warrants it — currently VFD).
- Human-eye review gates each pick. Any pick that feels wrong in context gets replaced before shipping.
- Update Google Fonts `@import` URL to include all picked font families.

**Out of scope for Phase 3:**
- Instrument chrome (Phase 4).
- New palettes or color changes.

**Definition of done.**
- Switching any of the 11 themes visibly changes the font as well as the color.
- Each theme's font choice is documented in a comment in `tokens.css` with a one-line rationale.
- Gem and npm package re-built and shippable.

**Delivery flexibility.** Phase 3 can ship theme-by-theme or in clusters. A cluster like "Eras pass" (Retrowave, Grunge, Y2K, Social, Cyberpunk, Cinematic, Pink, Unicorn, Rainbow) and then a separate "Hardware pass" (VFD + Nixie already done in Phase 2, Cherenkov) is a reasonable split. No requirement to ship all 11 in one release.

### Phase 4 — Hardware Chrome (VFD-only)

**Scope.**
- Add the five utility classes (`.ng-instrument-frame`, `.ng-chamfer`, `.ng-vfd-separator`, `.ng-vfd-label`, `.ng-vu-segment`) to `neon_glow` CSS as palette-agnostic primitives.
- Auto-apply instrument frame + label behavior inside `.neon-vfd` descendant context.
- Update the VFD palette card on the home page to demonstrate a `data-vfd-label` attribute in action.
- Document the utility classes in the gem and npm package READMEs with usage examples.

**Out of scope for Phase 4:**
- Auto-applying chrome to Nixie, Cherenkov, or any other palette.
- Canvas/SVG-based chrome (CSS-only primitives).

**Definition of done.**
- Switching to VFD palette gives the demo cards visible hard-edged bezels, inset shadows, and (if `data-vfd-label` is set) a hairline label in the top-left corner.
- Users of the gem/npm package can manually apply `.ng-instrument-frame` to their own components and get the chrome effect regardless of active palette.
- No regressions on any other palette — the utility classes don't affect non-VFD contexts unless opted into.

## Rejected alternatives

Documented here so future-me doesn't re-run the debates.

**Rejected: Nixie with a hue slider like VFD.** Broke authenticity — real Nixie tubes only existed in one color. The locked hue is the narrative point. VFD gets the slider specifically because its concept is "change the phosphor lens." Nixie's concept is the opposite.

**Rejected: Cyberpunk 2077 font (Rage Italic) or any lookalike trying to copy its silhouette.** Proprietary, CDPR-owned, cannot be shipped. Cyberpunk theme will use an OFL wide-angular display face that evokes the same *register* without infringing.

**Rejected: The BONX font family from `zyf722/Max-s-Divergence-Meter`.** The repo's own README credits the fonts as copyright works of 5pb./Nitroplus (Steins;Gate IP holders). Redistributing them in a public gem/npm package is copyright infringement. Used only as a *visual reference target* while hunting for OFL alternatives.

**Rejected: Self-hosted WOFF2 files in the repo.** Bundle size, licensing attribution burden, asset pipeline complexity across three distribution targets. Google Fonts `@import` is the correct tradeoff.

**Rejected: Hardware chrome applied to Nixie.** Nixie tubes were individual glass envelopes, not framed display surfaces. Applying bezels to Nixie would be anachronistic and would weaken the instrument-panel vocabulary's identity. Per direction, Phase 4 is VFD-only.

**Rejected: Plasma Display Panel as the new Hardware palette.** Considered during brainstorming. Real visual identity but overlaps strongly with Retrowave and Grunge in color territory, and lacks the physical-authenticity hook that Cherenkov has. Cherenkov was the better pick.

**Rejected: LCD Segment (calculator / Game Boy) as the new Hardware palette.** Considered during brainstorming. The olive-green non-glowing surface violates the `neon_glow` brand — the palette set is specifically about *glowing* surfaces.

**Rejected: Unifying display and body font in every theme.** Most themes need the display font to carry personality and the body font to disappear. Only immersion themes (VFD, Nixie) unify both slots because the "whole surface is one instrument" concept requires it. Unifying universally would hurt readability on text-heavy themes (Cinematic, Classic Pink, Social).

## Decisions deferred to implementation

These are things I, the implementing agent, will decide during the build based on in-context evaluation. They do not need to be pre-decided here.

- **Exact Nixie display font pick.** Shortlist: `B612 Mono`, `Share Tech Mono`, `Major Mono Display`, `Wallpoet`. Decide in Phase 2 based on which reads most authentically in context.
- **Exact per-theme font pick for Phases 3.** Starting candidates listed above; final selection during Phase 3.
- **Mercury-violet fringe vs. base-pool placement for Nixie.** Try the layered-fringe version first; fall back to the base-pool version if the fringe proves technically finicky. Both are authentic to real hardware.
- **CSS implementation of the Nixie wire-grid frame.** Either `repeating-linear-gradient` pseudo-element or `background-image` SVG dot-matrix. Pick whichever tunes more cleanly in context.
- **Exact glow radius values for Cherenkov.** The four-layer stack is specified; the exact `px` values may tune during implementation to hit the "volumetric underwater" target visually.
- **Whether to ship Phase 3 as one release or multiple clusters.** Decide at the start of Phase 3 based on how the work paces.

## Out of scope

Explicit non-goals for this project.

- Adding palettes beyond Cherenkov and Nixie.
- Self-hosted fonts.
- Proprietary fonts of any kind.
- Hardware chrome on Nixie, Cherenkov, or any non-VFD theme.
- Canvas, SVG, or image-based hardware chrome (CSS primitives only).
- Modifying the existing VFD hue-slider architecture.
- Changing the existing 10 palettes' colors (typography changes yes, color changes no).
- Accessibility audit and remediation pass (tracked separately; this project assumes current `neon_glow` accessibility posture and does not make it worse).
- Performance budget enforcement (tracked separately; Google Fonts `@import` adds one network request, acceptable).

## Success criteria

At the end of the project (all four phases shipped):

1. **Activating Cherenkov palette visibly feels like standing beside a nuclear reactor pool.** A new user who has never heard the term Cherenkov sees the palette, searches the name, finds reactor photography, recognizes the color match, and has an "oh wow" moment.
2. **Activating Nixie palette visibly feels like looking at a mid-century scientific instrument.** The warm amber glow, the layered depth, the mercury fringe, the font, and the wire-grid frame combine to produce the same recognition from someone who has seen real Nixie clocks.
3. **Activating VFD palette visibly feels like looking at a 1980s Pioneer stereo receiver.** The colors, the hard-edged bezel, the chamfered corners, the tiny hairline labels, and the B612 Mono font combine into a complete instrument-panel aesthetic.
4. **Every other theme in the set feels noticeably stronger than before** because the right typographic personality has been added.
5. **A downstream consumer of the gem or npm package** can install the new version, switch to any of the 12 themes, and get the full experience — colors, fonts, and (for VFD) chrome — without writing any additional CSS.
6. **No existing consumer's deployment breaks** because of a font token addition or a new palette class.

## Appendix: the "why" audit

Before shipping any phase, the implementer (future-me) should re-read this document and answer:

- Does this still feel like the project the user described as "let Claude cook"?
- Have I hedged any design decision back to the user instead of making it?
- Is the physical authenticity of each palette color still within the ±5° hue target?
- Have I shipped any font that isn't verifiably OFL on Google Fonts?

If any of these answers are "no" or "I'm not sure," stop and re-read the design principles section.
