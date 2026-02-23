# Neon Glow

**A dark neon glow design system for Bootstrap and Tailwind CSS.**

4 color palettes. 3 intensity levels. Fully open source.

<!-- Replace with your animated GIF when ready -->
<!-- ![Neon Glow Demo](docs/screenshots/neon-glow-demo.gif) -->

<p align="center">
  <img src="docs/screenshots/home-rainbow.png" alt="Rainbow Palette" width="48%">
  <img src="docs/screenshots/home-cinematic.png" alt="Cinematic Palette" width="48%">
</p>

---

## Palettes

| Palette | Vibe | Colors |
|---------|------|--------|
| **Rainbow Glow** | Full-spectrum neon. Arcade cabinets and light shows. | Red, cyan, yellow, green, purple, pink |
| **Unicorn Glow** | Pastel rainbow. Dreamy, soft, ethereal. | Lavender, mint, peach, soft rose |
| **Cinematic Glow** | Electric blue + amber. The Blade Runner palette. | Blue, orange, gold |
| **Pink Glow** | Hot pink + magenta. A power color for everyone. | Pink, magenta, rose, purple |

## Intensity Levels

| Level | Description |
|-------|-------------|
| **Subtle** | Gentle glow. Professional. Easy on the eyes. |
| **Medium** | Balanced glow. The sweet spot for most apps. |
| **Intense** | Maximum glow. Over the top. The WOW factor. |

---

## Features

- **CSS Custom Properties** -- Every color, glow effect, and surface is a CSS variable. Swap a class on `<body>` and everything updates.
- **Framework Agnostic Core** -- The token system (`tokens.css` + `components.css`) works with any CSS framework or standalone.
- **Tailwind CSS Integration** -- Import the tokens into your Tailwind setup and use neon glow alongside Tailwind utilities.
- **Bootstrap Integration** -- Dark-themed Bootstrap via SCSS variable overrides, plus neon glow component classes.
- **Glow Effects** -- Box shadows, text shadows, gradient borders, and animated gradient rotation.
- **Accessibility** -- Respects `prefers-reduced-motion` to disable animations for users who need it.
- **Theme Switcher** -- A simple dropdown-based palette and intensity switcher using Stimulus.js.

---

## Quick Start

### Standalone (any project)

Copy the two core CSS files into your project:

```
app/assets/stylesheets/neon_glow/tokens.css
app/assets/stylesheets/neon_glow/components.css
```

Link them in your HTML:

```html
<link rel="stylesheet" href="path/to/neon_glow/tokens.css">
<link rel="stylesheet" href="path/to/neon_glow/components.css">
```

Add palette and intensity classes to your `<body>`:

```html
<body class="neon-glow-body neon-rainbow neon-medium">
```

### With Tailwind CSS

Import the tokens in your Tailwind entry point:

```css
@import "tailwindcss";
@import "neon_glow/tokens.css";
@import "neon_glow/components.css";
```

### With Bootstrap (SCSS)

Override Bootstrap's SCSS variables with the neon dark surface colors (see `bootstrap_custom.scss` for the full list), then import Bootstrap. Layer the neon glow tokens on top via a separate `<link>` tag.

---

## Usage

### Palette Classes

Add one of these to `<body>` to set the color palette:

```
neon-rainbow    -- Full spectrum neon
neon-unicorn    -- Pastel rainbow
neon-cinematic  -- Blue + amber (movie poster)
neon-pink       -- Hot pink + magenta
```

### Intensity Classes

Add one of these to `<body>` to control glow strength:

```
neon-subtle   -- Gentle, professional
neon-medium   -- Balanced (default)
neon-intense  -- Maximum glow
```

### Component Classes

```
ng-card              -- Dark surface card
ng-card-raised       -- Elevated surface card
ng-border-glow       -- Gradient border with glow
ng-glow-primary      -- Primary color box-shadow glow
ng-glow-secondary    -- Secondary color box-shadow glow
ng-text-glow         -- Glowing text (primary)
ng-gradient-text     -- Rainbow gradient text
ng-btn               -- Base button
ng-btn-primary       -- Primary glowing button
ng-btn-secondary     -- Secondary glowing button
ng-btn-outline       -- Outline button with glow
ng-btn-ghost         -- Ghost button
ng-input             -- Form input with focus glow
ng-select            -- Select dropdown
ng-switch            -- Toggle switch
ng-badge-*           -- Badges (primary, secondary, success, warning, danger, info)
ng-alert-*           -- Alerts with glowing left border
ng-table             -- Dark themed table
ng-progress          -- Progress bar container
ng-progress-bar      -- Gradient progress bar
ng-navbar            -- Sticky navbar with backdrop blur
ng-divider           -- Gradient divider line
ng-animate-pulse     -- Pulsing glow animation
ng-animate-gradient  -- Rotating gradient border animation
```

### CSS Custom Properties

All colors are available as CSS variables for custom styling:

```css
var(--ng-primary)        /* Primary palette color */
var(--ng-secondary)      /* Secondary palette color */
var(--ng-accent)         /* Accent color */
var(--ng-success)        /* Success green */
var(--ng-warning)        /* Warning orange */
var(--ng-danger)         /* Danger red */
var(--ng-info)           /* Info purple */
var(--ng-bg)             /* Background */
var(--ng-surface)        /* Card/panel surface */
var(--ng-surface-raised) /* Elevated surface */
var(--ng-text)           /* Primary text */
var(--ng-text-secondary) /* Secondary text */
var(--ng-text-muted)     /* Muted text */
var(--ng-gradient)       /* Full gradient */
var(--ng-glow-blur)      /* Current glow blur radius */
var(--ng-glow-opacity)   /* Current glow opacity */
```

### JavaScript Theme Switching

Switch palettes and intensities at runtime by swapping classes on `<body>`:

```javascript
// Switch to Pink palette
document.body.classList.remove("neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink");
document.body.classList.add("neon-pink");

// Switch to Intense glow
document.body.classList.remove("neon-subtle", "neon-medium", "neon-intense");
document.body.classList.add("neon-intense");
```

---

## Kitchen Sink Demo

This repository includes a Rails 8.1.2 application with live demos:

- **Home** (`/`) -- Overview with palette cards
- **Tailwind Kitchen Sink** (`/tailwind`) -- All components styled with Tailwind + Neon Glow
- **Bootstrap Kitchen Sink** (`/bootstrap`) -- All components styled with Bootstrap + Neon Glow

### Running the Demo

```bash
git clone https://github.com/tokenfires/rails_neon_glow.git
cd rails_neon_glow
bundle install
bin/dev
```

No database setup required -- the app uses SQLite, which is included in the repo.

Visit `http://localhost:5000` and use the palette/intensity dropdowns in the navbar.

---

## Tech Stack

- Ruby 4.0.0 / Rails 8.1.2
- SQLite (zero-config, included)
- Tailwind CSS 4.2 (via tailwindcss-rails)
- Bootstrap 5.3 (via dartsass-rails)
- Hotwire (Turbo + Stimulus)
- Importmap (no Node.js required)

---

## Design

**Designed by Claude** (Anthropic) in collaboration with [TokenFires](https://github.com/tokenfires).

The Neon Glow design system was created through an AI-human collaboration. Claude designed the color palettes, glow effects, component styles, and the overall dark neon aesthetic. TokenFires provided creative direction, reference materials, and review.

The design draws inspiration from neon signage, arcade aesthetics, sci-fi movie palettes, and the SVG icon glow style from the [EmberHearth](https://github.com/tokenfires/emberhearth) project.

---

## License

MIT License -- See [LICENSE](LICENSE)

Use it in any project, commercial or personal. Attribution appreciated but not required.

---

## Packages

Use Neon Glow in your own projects:

| Package | Install |
|---------|---------|
| **Ruby gem** | `gem "neon_glow"` -- [neon_glow_gem](https://github.com/tokenfires/neon_glow_gem) |
| **npm** | `npm install neon-glow-css` -- [neon_glow_npm](https://github.com/tokenfires/neon_glow_npm) |

---

## Screenshots

### Home -- All 4 Palettes (Intense)

<p align="center">
  <img src="docs/screenshots/home-rainbow.png" alt="Rainbow Palette" width="48%">
  <img src="docs/screenshots/home-unicorn.png" alt="Unicorn Palette" width="48%">
</p>
<p align="center">
  <img src="docs/screenshots/home-cinematic.png" alt="Cinematic Palette" width="48%">
  <img src="docs/screenshots/home-pink.png" alt="Pink Palette" width="48%">
</p>

### Kitchen Sink -- Components

<p align="center">
  <img src="docs/screenshots/tailwind-swatches-rainbow.png" alt="Tailwind Color Swatches" width="48%">
  <img src="docs/screenshots/bootstrap-cinematic.png" alt="Bootstrap Cinematic" width="48%">
</p>

---

## Contributing

Contributions welcome! Whether it's new palettes, component styles, bug fixes, or documentation improvements.

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Open a pull request

---

*Built with care by Claude and TokenFires. 2026.*
