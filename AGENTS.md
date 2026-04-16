# AGENTS.md — neon-glow for AI assistants

> For Claude, ChatGPT, Gemini, or any AI helping a user apply this
> library to their project. Read this before writing CSS or HTML
> that consumes `neon-glow-css` (npm) / `neon-glow` (gem).

## What this is in one paragraph

A token-driven dark-neon CSS design system. Ships two core files
(`tokens.css` + `components.css`). The user flips a class on `<body>`
to switch palettes (12 of them), intensities (4), and optional
per-theme typography. Every color, glow, and surface is a CSS
custom property that cascades through the system.

## The three `<body>` classes

```html
<body class="neon-glow-body neon-cyberpunk neon-overdrive">
```

- `neon-glow-body` — **required always.** Don't strip it. It carries
  body-wide typography and color tokens. Without it, the palette
  class alone gives you color but not typography or body styling.
- `neon-<palette>` — the color system (`neon-rainbow`, `neon-nixie`,
  `neon-cyberpunk`, etc.). See palette list below.
- `neon-<intensity>` — the glow strength (`neon-subtle`,
  `neon-medium`, `neon-intense`, `neon-overdrive`). Optional;
  defaults to `medium`.

**Never put palette classes on any element other than `<body>`.**
They're scoped globally; nested palette classes will confuse the
cascade.

## Delivery gotchas by framework

- **Tailwind v4**: Tailwind's compiler strips remote `@import`
  statements during build. The `@import url('https://fonts.googleapis.com/...')`
  in `tokens.css` WILL BE REMOVED silently. Add a `<link rel="stylesheet">`
  with the same Google Fonts URL to the document `<head>`, or the
  fonts never load and the page renders Courier New fallback while
  tests still pass. This is the #1 silent failure mode.
- **Tailwind v3** and **Bootstrap**: `@import` passes through. No
  extra step needed.
- **Standalone / CDN**: works directly. `@import` loads the fonts.
- **Rails with Propshaft**: works out of the box via the gem.

## Choose a palette by aesthetic intent

| User says... | Use |
|---|---|
| "80s synthwave / retro / Miami Vice" | `neon-retrowave` |
| "Cyberpunk / dystopian corporate / HUD / glitch" | `neon-cyberpunk` |
| "Scientific / reactor / technical instrument" | `neon-cherenkov` |
| "Vintage hardware / Pioneer stereo / VFD / segmented display" | `neon-vfd` |
| "Mid-century / 1960s lab / gas-discharge tube" | `neon-nixie` |
| "Blade Runner / movie poster / dramatic" | `neon-cinematic` |
| "Zine / 90s grunge / photocopy / DIY" | `neon-grunge` |
| "Y2K / chrome / early-2000s" | `neon-y2k` |
| "Platform UI / social media / Instagram feed" | `neon-social` |
| "Hot pink / power color / bold" | `neon-pink` |
| "Pastel / soft / dreamy" | `neon-unicorn` |
| "Generic neon / default / playful" | `neon-rainbow` |

## Three orthogonal layers

Palette (color), intensity (glow strength), and typography (fonts)
are independent. A user can have Cyberpunk colors + Subtle intensity
+ a custom font — just override the relevant CSS custom property:

```css
:root {
  --ng-font-body: 'Your Custom Font', sans-serif;
}
```

Don't rewrite palette blocks to change one aspect. Override the
specific token.

## Auto-applied palette chrome (no extra classes needed)

Several palettes auto-apply visual chrome to `.ng-card` elements:

- **VFD**: hard-edged instrument bezel. Add `data-vfd-label="DISPLAY"`
  to a card for a tiny silk-screened label in the top-left.
- **Retrowave**: chrome-outlined headings + CRT scanlines on cards.
- **Cyberpunk**: asymmetric notched panel clip-path + hover-glitch on
  headings. Note: border-glow is suppressed under Cyberpunk
  (replaced with inset holographic glow) — this is intentional.
- **Grunge**: noise texture + rotation + paper-on-wall shadow.
  Per-card opt-in/opt-out via `data-grunge-mark="none|scribble|circle"`.
- **Nixie**: per-character wire-grid on card H1/H2 via JS (requires
  the Stimulus controller from the demo repo, or the user can skip it
  — the CSS fallback is still pretty).

## Don't do

- Don't put palette classes on anything but `<body>`.
- Don't use `::before` or `::after` on elements that also have
  `.ng-border-glow` — both pseudo-elements are taken by the gradient
  border effect. Use `background-image` for overlays instead.
- Don't combine `.ng-neon-tube` with `.ng-gradient-text` — the
  gradient makes text transparent and kills the tube color.
- Don't remove `neon-glow-body` from `<body>` thinking it's
  redundant. It's load-bearing.
- Don't modify `tokens.css` or `components.css` directly to customize.
  Override tokens in your own CSS with higher specificity or via
  `:root`.

## Minimal working example

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <!-- Required if using Tailwind v4; safe to include always -->
  <link rel="stylesheet"
        href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;700&display=swap">
  <link rel="stylesheet" href="https://unpkg.com/neon-glow-css/css/neon-glow.css">
</head>
<body class="neon-glow-body neon-cyberpunk neon-overdrive">
  <div class="ng-card ng-border-glow" style="padding: 2rem; max-width: 40rem; margin: 3rem auto;">
    <h1 class="ng-gradient-text">Hello Neon</h1>
    <p style="color: var(--ng-text);">A paragraph in the active palette's body color.</p>
    <button class="ng-btn ng-btn-primary">Primary action</button>
  </div>
</body>
</html>
```

Change `neon-cyberpunk` to any palette above; nothing else needs to
change. To switch dynamically, just swap the class on `<body>`.

## When the user asks "make it look like X"

1. Pick a palette from the decision table.
2. Pick an intensity based on how dramatic they want it (most
   palettes default intensely; overdrive is available if asked).
3. Add `.ng-card`, `.ng-btn-*`, `.ng-border-glow`, `.ng-gradient-text`
   to their existing elements as needed — these are palette-agnostic
   component classes that inherit the active palette's tokens.
4. If they want a signature effect (`.ng-neon-tube` for signage,
   `.ng-retrowave-horizon` for a hero, etc.), reach for the utility
   classes documented in the main README.

## Further reading

- `README.md` — full feature documentation, utility class reference,
  installation per framework.
- `CLAUDE.md` — internal development guidance (only relevant if the
  user is contributing to the library, not consuming it).
