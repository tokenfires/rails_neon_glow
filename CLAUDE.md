# CLAUDE.md — rails_neon_glow

> Keep this under ~250 lines. If something's worth knowing for longer than a
> session, put it here. If it's only worth knowing for one task, put it in
> the spec/plan for that task under `docs/superpowers/`.

## What this project is

**`rails_neon_glow` is a dark-neon design system.** Distribution is a Ruby gem
(`neon-glow`) and an npm package (`neon-glow-css`); this Rails 8 app is the
reference + demo site that exercises every palette, intensity, and utility.

**The aesthetic is the product.** Visual polish isn't incidental — it is the
thing being sold. Design decisions have first-class weight here. Ship ugly and
the whole package loses its reason to exist.

**Token-driven.** Every color, glow, surface, spacing, and font is a CSS
custom property. Palettes and intensities are classes on `<body>` that swap
those property values. One class flip → everything re-reads.

## The tokenized-style mindset (read this before writing any CSS)

Before writing a value, grep for the concept. If a token or utility already
exists, use it. Hardcoded values break the cascade — they stop responding to
palette switches, intensity switches, or future per-theme overrides. That's
the opposite of what the system is for.

**Check first:**
- Color? → `var(--ng-primary)`, `rgba(var(--ng-primary-rgb), α)`, `--ng-secondary`, `--ng-accent`, `--ng-text-*`, `--ng-bg-*`, etc.
- Glow/bloom? → `var(--ng-glow-text-blur)`, `var(--ng-glow-opacity)`, `var(--ng-glow-spread)`, `var(--ng-glow-blur)` — these scale with `.neon-subtle|medium|intense|overdrive`.
- Font? → `var(--ng-font-display)`, `--ng-font-body`, `--ng-font-mono`, `--ng-font-display-alt`.
- Gradient? → `var(--ng-gradient)`, `var(--ng-gradient-border)`.
- An existing text-shadow pattern? → See `.ng-text-glow` in components.css; copy its structure.

**The rule:** if you're writing `text-shadow:` or `color:` and the values
aren't CSS variables, you're probably wrong. Stop and look for the token.

## Specificity notes

The palette classes layer rules that target element + palette, like
`.neon-cherenkov h1 { ... }` (specificity `0,1,1`). A bare `.ng-foo` utility
(`0,1,0`) won't beat them on headings inside that palette. When writing a
utility that MUST win against palette rules, use one of these:

- `.ng-foo.ng-foo { ... }` — doubled class, `0,2,0`. Hacky but explicit.
- `:is(h1,h2,.h1,.h2).ng-foo { ... }` — matches element types at `0,2,0`.

Pick the one that reads clearer in context. `.ng-neon-tube` uses the doubled
form — see the comment above that rule for the reasoning.

## Tailwind v4 gotcha (discovered the hard way)

**Tailwind v4's CSS compiler strips remote `@import` statements during
build.** The `@import url('https://fonts.googleapis.com/...')` at the top of
`tokens.css` gets removed, so Google Fonts don't load on Tailwind-layout
pages. Symptom: fonts silently fall back to Courier New and `getComputedStyle`
still reports the declared font, so tests pass while the page renders wrong.

**Fix:** Google Fonts URL must also be in a `<link rel="stylesheet">` tag in
`app/views/layouts/application.html.erb`. Keep both: the `@import` for
non-Tailwind consumers of `tokens.css`, the `<link>` for our demo app.

## Workflow

- **Never work on main.** Branch before any change: `git checkout -b feat/<name>`.
- **Phase-based delivery.** Each phase gets a spec + plan in `docs/superpowers/`. Rough ideas go in `docs/superpowers/ideation/`.
- **Run tests before declaring done.** `bin/rails test:system` covers the visual/behavior tests. `bin/rails test` covers unit. Both must be green.
- **Small commits, descriptive messages.** One commit per logical change; include the *why* in the body, not just the *what*.
- **Fast-forward merge to main** when the branch is approved, so the commit trail stays bisectable.
- **TodoWrite aggressively.** Multi-step tasks get a todo list with exactly one item in_progress.

## Testing patterns

- System tests in `test/system/` using Capybara + headless Chrome.
- Palette-switching tests: `localStorage.clear()` then `visit` to reset Stimulus state.
- `getComputedStyle()` returns the *declared* font-family string, not the *loaded* font — it can't catch a failed font load. Visual review is the only check for that.
- When fixing a bug, add a test that would have caught it. Examples in this repo: intensity-responsiveness of `.ng-neon-tube`, whitespace-wrap skip in `theme_switcher_controller.js`.

## Gotchas

1. **Hardcoded values instead of tokens.** Came up on `.ng-neon-tube`'s text-shadow — em-based values that ignored intensity tokens. Always grep for the concept first.
2. **Enumerated whitespace chars miss `'\n'`.** The character-wrap function listed `' '`, `'\u00a0'`, `'\t'` and ERB template indentation produced phantom wire-grid cells under Nixie. Use `/\s/`.
3. **`z-index: -1` without a stacking context.** Wire-grid `::before` rendered *behind* the opaque `.ng-card` background and went invisible. Add `isolation: isolate` to the parent so `z-index: -1` stays inside its own stacking context.
4. **Body element selector outranked by class selector.** `body { font-family: ... }` (specificity `0,0,1`) got beaten by `.neon-glow-body { font-family: system-ui }` from earlier CSS. For body-scoped typography, use `.neon-glow-body` as the selector.
5. **`getComputedStyle(font-family)` reports the declared string even if the font never loaded.** Tests can pass while the page renders Courier New fallback. See the Tailwind v4 gotcha above.

## Design collaboration

The user (TK / Robert / TokenFires on GitHub) explicitly wants strong design
conviction on creative work — "let Claude cook." Defer-to-user on *visual*
decisions reads as hedging. On design:

- Propose opinionated takes with a short reasoning, not a menu of options.
- When a visual review surfaces something off, diagnose first, fix second.
- The feedback loop is: implement → TK eyeballs → name what they see → tune → repeat. Keep it tight.

On architecture/correctness: standard senior-engineer directness applies.
Disagree when you should, say "I don't know" when you don't.

## DOM wrapping (per-character effects)

Some effects can't be expressed in CSS alone — per-character styling where
spaces must *not* participate, for example. The pattern lives in
`theme_switcher_controller.js`:

- Wrap characters in `<span class="ng-nixie-char">` via `createElement` + `textContent` only. **Never `innerHTML`** — a PreToolUse hook rejects it, and the existing code is carefully safe.
- Skip whitespace (all of it, via `/\s/`) so spaces render as natural gaps.
- Store original text in `dataset.nixieOriginal` so `unwrap` restores it exactly.
- Wrapping is keyed on `.ng-nixie-char` — the same span class is reused by the Phase 2.5 `.ng-neon-tube` utility. Nixie's CSS decorates that span with a wire-grid `::before`; other palettes leave it unstyled.

## Phase roadmap (as of 2026-04-15)

| Phase | Status | Deliverable |
|-------|--------|-------------|
| 1 | ✓ merged | Cherenkov + Nixie palettes |
| 1.5 | ✓ merged | Overdrive intensity + per-palette defaults |
| 2 | ✓ merged | Typography architecture + Nixie proof + wire-grid |
| 2.5 | current | `.ng-neon-tube` affordance (palette-agnostic neon signage) |
| 3 | next | Per-theme font pass across all 12 palettes |
| 4 | planned | Hardware Chrome (VFD-only visual chrome) |
| 5 | planned | Era Chrome (Retrowave, Cyberpunk, Grunge) |

Detailed specs and plans live in `docs/superpowers/specs/` and `docs/superpowers/plans/`.

## File map (where things live)

| Path | Role |
|------|------|
| `app/assets/stylesheets/neon_glow/tokens.css` | All CSS custom properties, palette blocks, intensity classes. The contract. |
| `app/assets/stylesheets/neon_glow/components.css` | Utility classes (`.ng-card`, `.ng-btn-*`, `.ng-text-glow`, `.ng-nixie-digit`, `.ng-neon-tube`, etc.) |
| `app/javascript/controllers/theme_switcher_controller.js` | Stimulus controller: palette/intensity/VFD-hue selection, persistence, character-wrapping |
| `app/views/layouts/application.html.erb` | Google Fonts `<link>` tag lives here (don't remove — see Tailwind gotcha) |
| `app/views/pages/home.html.erb` | Home page + hero `.ng-neon-tube` |
| `app/views/pages/tailwind.html.erb`, `bootstrap.html.erb` | Kitchen sinks — exercise every utility in both frameworks |
| `test/system/hardware_palettes_test.rb` | System tests for palettes, intensity, typography, wire-grid, neon-tube |
| `docs/superpowers/specs/` | Per-phase specs (what + why) |
| `docs/superpowers/plans/` | Per-phase plans (how, step by step) |
| `docs/superpowers/ideation/` | Rough captures of ideas before they become specs |

## A note to future-me about intention

This project started as an icon-styling session for EmberHearth's README and
grew into a standalone library because the aesthetic kept pulling. That
origin matters: **every design decision should make a designer want to use
this library** — not just function correctly. Visual polish, honest palette
character, the "is this really neon?" test — those are the bar.

The user delegates a lot of creative autonomy. That's trust, not a pass on
rigor. Strong opinions with clear reasoning, then show the work. When
something is visually off, the user will tell you; fix it with the same care
you'd fix a logic bug.

Keep it opinionated. Keep it polished. Stay on rails.
