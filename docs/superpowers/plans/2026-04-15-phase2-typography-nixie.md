# Phase 2 — Typography & Nixie PoC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the three-slot (plus optional alt) typography token layer to `neon_glow`, deliver fonts via Google Fonts `@import`, override Nixie to use B612 Mono on both display and body slots, add the wire-grid frame effect, write system tests, update the README. Five tasks, all on `feat/phase-2-typography-nixie` branch.

**Architecture:** Additive. New tokens and @import in `tokens.css`. New application rules and utility class in `components.css`. Nixie block gains font overrides. Tests verify behavior. README documents the architecture. No modifications to existing Phase 1 or Phase 1.5 work.

**Spec reference:** `docs/superpowers/specs/2026-04-15-phase2-typography-and-nixie-spec.md` (primary), `2026-04-10-hardware-themes-and-typography-design.md` (parent design spec, Phase 2 section).

---

## File structure

| File | Action |
|---|---|
| `app/assets/stylesheets/neon_glow/tokens.css` | Add `@import` at top; add 4 font tokens to `:root`; override `--ng-font-display` and `--ng-font-body` in `.neon-nixie` |
| `app/assets/stylesheets/neon_glow/components.css` | Add typography application section (per-component selectors); add wire-grid frame section (utility class + auto-application inside `.neon-nixie`) |
| `README.md` | Add Typography section; update tagline to mention typography slots |
| `test/system/hardware_palettes_test.rb` | Add tests for typography switching and wire-grid frame presence |

---

## Task 1: tokens.css — @import, font tokens, Nixie override

**Pre-context:** Three related additions to `tokens.css`:
1. `@import` at the very top of the file (before `:root`), pulling in Inter, JetBrains Mono, and B612 Mono from Google Fonts
2. Four typography tokens added to `:root`
3. Nixie's font slots overridden inside the existing `.neon-nixie` block (which is near line 540)

Read the current file structure first. The top of the file has a header docblock comment — the `@import` goes AFTER that comment and BEFORE the `:root` block.

### Step 1: Add the Google Fonts @import

Open `app/assets/stylesheets/neon_glow/tokens.css`. Find the end of the top header comment (the `*/` that closes the first docblock). Immediately after that closing `*/`, insert a blank line and then:

```css
/* Typography delivery — Google Fonts @import.
   See 2026-04-10 design spec for the delivery-mechanism reasoning
   (OFL-only, CDN-delivered, zero bundled font files, identical
   behavior across Rails/gem/npm distributions). */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;700&family=B612+Mono:wght@400;700&display=swap');
```

### Step 2: Add font tokens to :root

Find the `:root` block (starts with `:root {` on around line 24). Find the block's closing `}`. Before that closing `}`, and after the last existing token (should be `--ng-transition-glow: 0.3s ease;` or similar), add:

```css

  /* Typography — required defaults */
  --ng-font-display: 'Inter', system-ui, sans-serif;
  --ng-font-body:    'Inter', system-ui, sans-serif;
  --ng-font-mono:    'JetBrains Mono', ui-monospace, monospace;

  /* Typography — optional fourth slot, falls back to display when
     not overridden. Used by "messy" era themes in Phase 3 to carry
     a secondary display face for sub-headline roles. */
  --ng-font-display-alt: var(--ng-font-display);
```

(Note the leading blank line to separate from existing tokens.)

### Step 3: Override font slots in .neon-nixie

Find the `.neon-nixie` palette class block. The block currently ends with radius overrides (`--ng-radius-xl: 0.25rem;` followed by `}`). Before the closing `}`, add:

```css

  /* Typography — immersion override.
     Nixie uses B612 Mono for both display AND body. The entire
     surface should feel like a continuous instrument readout;
     paragraphs and headings share the same instrument-font register.
     Mono stays default (JetBrains Mono) for code. */
  --ng-font-display: 'B612 Mono', 'Courier New', monospace;
  --ng-font-body:    'B612 Mono', 'Courier New', monospace;
```

### Step 4: Verify

```bash
grep -c "@import url.*fonts.googleapis.com" app/assets/stylesheets/neon_glow/tokens.css
```
Expected: `1`

```bash
grep -c "^  --ng-font-" app/assets/stylesheets/neon_glow/tokens.css
```
Expected: `6` — 4 in `:root` (display, body, mono, display-alt) + 2 in `.neon-nixie` (display, body override)

```bash
grep -c "B612 Mono" app/assets/stylesheets/neon_glow/tokens.css
```
Expected: `3` — once in @import URL, twice in Nixie's overrides

```bash
grep -c "Inter" app/assets/stylesheets/neon_glow/tokens.css
```
Expected: at least `3` — in @import, in `--ng-font-display` default, in `--ng-font-body` default

### Step 5: Commit

```bash
git add app/assets/stylesheets/neon_glow/tokens.css
git commit -m "$(cat <<'EOF'
feat: add typography token layer and Nixie font override

Three related additions to tokens.css:

1. Google Fonts @import at the top of the file pulling in Inter
   (weights 400/500/600/700), JetBrains Mono (400/700), and
   B612 Mono (400/700). All OFL-licensed.

2. Four new tokens in :root: --ng-font-display, --ng-font-body,
   --ng-font-mono (required defaults) plus --ng-font-display-alt
   (optional, defaults to --ng-font-display for themes that do
   not use the alt slot).

3. .neon-nixie overrides --ng-font-display and --ng-font-body to
   B612 Mono, giving Nixie its continuous-instrument-readout
   register. B612 Mono was commissioned by Airbus for cockpit
   instrument displays — the same emotional register as real
   Nixie tubes carried in 1960s lab instrumentation.

Spec: docs/superpowers/specs/2026-04-15-phase2-typography-and-nixie-spec.md

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: components.css — per-component font application + wire-grid frame

**Pre-context:** Two distinct additions to `components.css`, both of which consume tokens added in Task 1:
1. Per-component font application rules that map each token to the elements it applies to
2. The Nixie wire-grid frame (utility class + auto-application inside `.neon-nixie`)

Both sections go near the end of the file, after the existing content but in logical order.

### Step 1: Add per-component typography application rules

Append to the end of `components.css`:

```css

/* ============================================================
   TYPOGRAPHY APPLICATION
   Headings and display elements get --ng-font-display.
   Subheads and accent elements get --ng-font-display-alt (which
   defaults to --ng-font-display unless a theme overrides it).
   Body text gets --ng-font-body. Code gets --ng-font-mono.
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

### Step 2: Add the Nixie wire-grid frame section

Append after the typography application block:

```css

/* ============================================================
   NIXIE WIRE-GRID FRAME
   The signature Nixie visual: thin vertical cathode wires and
   horizontal support brackets behind the glowing digit. Recreates
   the cathode stack visible through the glass of a lit Nixie tube.

   Two layers: (1) a utility class .ng-nixie-digit for manual
   application to specific elements, (2) auto-application to
   card h1/h2 (including Bootstrap typography classes) inside
   .neon-nixie so consumers get the effect on card headings
   without having to opt in manually.

   Technique: repeating-linear-gradient for vertical wires, single
   borders for horizontal brackets, z-index: -1 to sit behind the
   parent's text. Pure CSS, no external assets.
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

/* Auto-apply to card headings inside the Nixie palette.
   Covers both semantic headings (h1/h2) and Bootstrap typography
   utility classes (.h1/.h2/.display-4/.display-5) so the effect
   applies on both Tailwind and Bootstrap kitchen sink pages. */
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

### Step 3: Verify

```bash
grep -c "TYPOGRAPHY APPLICATION" app/assets/stylesheets/neon_glow/components.css
```
Expected: `1`

```bash
grep -c "NIXIE WIRE-GRID FRAME" app/assets/stylesheets/neon_glow/components.css
```
Expected: `1`

```bash
grep -c "var(--ng-font-display)\|var(--ng-font-body)\|var(--ng-font-mono)\|var(--ng-font-display-alt)" app/assets/stylesheets/neon_glow/components.css
```
Expected: at least `4` (one per token)

```bash
grep -c "\.ng-nixie-digit" app/assets/stylesheets/neon_glow/components.css
```
Expected: `2` (class selector + its ::before)

```bash
grep -c "repeating-linear-gradient" app/assets/stylesheets/neon_glow/components.css
```
Expected: at least `2` (utility class + auto-application block)

### Step 4: Commit

```bash
git add app/assets/stylesheets/neon_glow/components.css
git commit -m "$(cat <<'EOF'
feat: add typography application rules and Nixie wire-grid frame

Two additions to components.css:

1. Typography application section: maps each font token to the
   elements it applies to. .ng-card h1/.ng-hero/.ng-display get
   --ng-font-display. h2/h3/.ng-accent get --ng-font-display-alt.
   Body text gets --ng-font-body. Code/pre/kbd/samp get mono.

2. Nixie wire-grid frame: the signature Nixie visual of cathode
   wires and support brackets behind the glowing digit. Two forms:
   - .ng-nixie-digit utility class for manual application
   - Auto-application to .ng-card h1/h2 (and Bootstrap .h1/.h2/
     .display-4/.display-5) inside .neon-nixie

Technique is pure CSS — repeating-linear-gradient for vertical
wires, borders for horizontal brackets, z-index: -1 to sit behind
text. No external assets, no bundled SVG files.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: System tests for typography and wire-grid frame

**Pre-context:** Add tests to `test/system/hardware_palettes_test.rb`. Do not modify existing tests. The current file has 15 tests (7 from Phase 1, 8 from Phase 1.5). Phase 2 adds a smaller set.

The critical Phase 2 behaviors to test:
- Nixie applies B612 Mono to body (verifiable via `getComputedStyle`)
- Other palettes do NOT have B612 Mono (Cherenkov, for instance, should have whatever the font defaults are)
- The wire-grid frame pseudo-element is present on card h1/h2 when Nixie is active (verifiable by checking that the pseudo-element has a `background-image`)

### Step 1: Add tests before the closing `end` of the test class

Insert these tests at the end of the existing tests (before the class `end`):

```ruby

  test "Nixie palette applies B612 Mono to body text" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    font_family = page.evaluate_script(
      "window.getComputedStyle(document.body).getPropertyValue('font-family')"
    )
    assert_match(/B612\s*Mono/i, font_family,
      "expected body font-family to include B612 Mono when Nixie is active; got: #{font_family}")
  end

  test "non-Nixie palette does not use B612 Mono" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    font_family = page.evaluate_script(
      "window.getComputedStyle(document.body).getPropertyValue('font-family')"
    )
    refute_match(/B612\s*Mono/i, font_family,
      "expected body font-family to NOT include B612 Mono when Cherenkov is active; got: #{font_family}")
  end

  test "typography font tokens are defined on :root" do
    visit root_path

    display_font = page.evaluate_script(
      "window.getComputedStyle(document.documentElement).getPropertyValue('--ng-font-display').trim()"
    )
    body_font = page.evaluate_script(
      "window.getComputedStyle(document.documentElement).getPropertyValue('--ng-font-body').trim()"
    )
    mono_font = page.evaluate_script(
      "window.getComputedStyle(document.documentElement).getPropertyValue('--ng-font-mono').trim()"
    )
    alt_font = page.evaluate_script(
      "window.getComputedStyle(document.documentElement).getPropertyValue('--ng-font-display-alt').trim()"
    )

    refute display_font.empty?, "expected --ng-font-display to be defined; got empty string"
    refute body_font.empty?, "expected --ng-font-body to be defined"
    refute mono_font.empty?, "expected --ng-font-mono to be defined"
    refute alt_font.empty?, "expected --ng-font-display-alt to be defined"
  end

  test "Nixie card headings have wire-grid frame pseudo-element" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    # The wire-grid frame is applied via ::before pseudo-element with a
    # background-image (repeating-linear-gradient). Query any h1 or h2
    # inside a .ng-card on the current page.
    bg_image = page.evaluate_script(<<~JS)
      (function() {
        var heading = document.querySelector('.ng-card h1, .ng-card h2, .ng-card .h1, .ng-card .h2');
        if (!heading) return 'NO_HEADING_FOUND';
        var style = window.getComputedStyle(heading, '::before');
        return style.getPropertyValue('background-image') || 'EMPTY';
      })()
    JS

    refute_equal "NO_HEADING_FOUND", bg_image,
      "no card heading found on the page; test setup may need a page with card headings"
    refute_equal "EMPTY", bg_image,
      "expected wire-grid frame ::before background-image to be set on Nixie card heading"
    assert_match(/linear-gradient/i, bg_image,
      "expected ::before background-image to contain a linear-gradient; got: #{bg_image}")
  end

  test "non-Nixie palette card headings do not have wire-grid frame" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    bg_image = page.evaluate_script(<<~JS)
      (function() {
        var heading = document.querySelector('.ng-card h1, .ng-card h2, .ng-card .h1, .ng-card .h2');
        if (!heading) return 'NO_HEADING_FOUND';
        var style = window.getComputedStyle(heading, '::before');
        return style.getPropertyValue('background-image') || 'EMPTY';
      })()
    JS

    refute_equal "NO_HEADING_FOUND", bg_image
    # Cherenkov card headings should either have no ::before background-image
    # or at minimum should not have the wire-grid linear-gradient pattern.
    # Other CSS may set ::before backgrounds for other reasons; specifically
    # check that the wire-grid pattern is absent.
    if bg_image != "EMPTY" && bg_image != "none"
      refute_match(/repeating-linear-gradient/i, bg_image,
        "expected wire-grid (repeating-linear-gradient) to NOT apply to Cherenkov card headings; got: #{bg_image}")
    end
  end

  test "ng-nixie-digit utility class works when manually applied" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    # Inject a test element with the .ng-nixie-digit class and verify
    # the pseudo-element rendering
    bg_image = page.evaluate_script(<<~JS)
      (function() {
        var el = document.createElement('span');
        el.className = 'ng-nixie-digit';
        el.textContent = '42';
        document.body.appendChild(el);
        var style = window.getComputedStyle(el, '::before');
        var bg = style.getPropertyValue('background-image') || 'EMPTY';
        el.remove();
        return bg;
      })()
    JS

    refute_equal "EMPTY", bg_image,
      "expected .ng-nixie-digit to produce a ::before with background-image; got EMPTY"
    assert_match(/linear-gradient/i, bg_image,
      "expected .ng-nixie-digit ::before to contain a linear-gradient; got: #{bg_image}")
  end
```

### Step 2: Run the tests

```bash
bin/rails test test/system/hardware_palettes_test.rb
```

Expected: `21 runs, X assertions, 0 failures, 0 errors, 0 skips` (15 existing + 6 new).

**Common failure modes:**
- If `B612 Mono` isn't matched: may be a Google Fonts loading issue in the test environment. Check whether the CSS selector actually applies to body (it should via the `body` selector in components.css). If CSS is correct but the font name doesn't appear in computed style, the browser may not be loading the @import in the test environment; consider whether the test should check for `B612` substring more loosely, or check that the value includes either `B612 Mono` or the fallback `Courier New`/`monospace`.
- If the wire-grid frame test fails because `NO_HEADING_FOUND`: the home page may not have a card with h1/h2 — verify by visiting root_path in dev and inspecting. If true, update the test to either visit a different page or pick a different selector.
- If existing tests fail: that's a regression — investigate before continuing.

### Step 3: Commit (only after all tests pass)

```bash
git add test/system/hardware_palettes_test.rb
git commit -m "$(cat <<'EOF'
test: cover typography tokens and Nixie wire-grid frame

Adds 6 new system tests:
- Nixie palette applies B612 Mono to body text
- Non-Nixie palettes do not use B612 Mono
- All four typography tokens are defined on :root
- Nixie card headings have the wire-grid frame pseudo-element
- Non-Nixie palettes do not have the wire-grid frame
- .ng-nixie-digit utility class works when manually applied

All original 15 Phase 1 + Phase 1.5 tests still pass.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: README — Typography section + tagline update

**Pre-context:** The current README tagline reads "12 color palettes. 4 intensity levels. Fully open source." Phase 2 adds typography as a third pillar of the theme system. Need to update the tagline AND add a Typography section documenting the token layer.

### Step 1: Update the tagline (line ~5)

Find:
```markdown
12 color palettes. 4 intensity levels. Fully open source.
```

Change to:
```markdown
12 color palettes. 4 intensity levels. 3 typography slots. Fully open source.
```

### Step 2: Add a Typography section after the Intensity Levels section

After the Intensity Levels section (including the Per-theme defaults subsection from Phase 1.5) and its closing `---` divider, insert a new Typography section. Find a good insertion point — likely right after the intensity defaults section ends. Insert:

```markdown
## Typography

`neon_glow` defines three primary font slots as CSS custom properties, plus an optional fourth for themes that layer multiple display voices:

| Token | Default | Role |
|-------|---------|------|
| `--ng-font-display` | `Inter` | Headlines, hero text, display elements |
| `--ng-font-body` | `Inter` | Paragraphs, body content, unstyled text |
| `--ng-font-mono` | `JetBrains Mono` | Code, pre-formatted text, keyboard input |
| `--ng-font-display-alt` | `var(--ng-font-display)` | Optional secondary display face for subheads; used by "messy" era themes |

Fonts are delivered via Google Fonts `@import` at the top of `tokens.css`. All included fonts are OFL-licensed and free for commercial use.

### Per-theme font overrides

Currently one theme overrides the defaults:

- **Nixie** uses `B612 Mono` on both display and body — a font commissioned by Airbus for cockpit instrument displays, which maps directly onto Nixie's 1960s scientific-instrumentation register. Nixie also gains a signature wire-grid frame effect on card headings, recreating the cathode stack visible through a real lit Nixie tube.

Additional per-theme font overrides will be added in later phases.

### Using custom fonts

Override the tokens in your own CSS:

```css
:root {
  --ng-font-display: 'Your Custom Font', sans-serif;
  --ng-font-body:    'Your Body Font', serif;
  --ng-font-mono:    'Your Mono Font', monospace;
}
```

You can also override per-theme by scoping to a palette class:

```css
.neon-cyberpunk {
  --ng-font-display: 'Orbitron', sans-serif;
}
```

### The Nixie wire-grid frame

The `.ng-nixie-digit` utility class applies a cathode-wire-and-bracket frame behind its contents, recreating the visual of a lit Nixie tube's cathode stack. Auto-applied to card `h1` and `h2` headings inside the `.neon-nixie` palette. You can apply it manually to any element:

```html
<span class="ng-nixie-digit">42</span>
```

---
```

### Step 3: Verify

```bash
grep -c "3 typography slots" README.md
```
Expected: `1`

```bash
grep -c "^## Typography" README.md
```
Expected: `1`

```bash
grep -c "ng-font-display\|ng-font-body\|ng-font-mono" README.md
```
Expected: at least `5` (each token in the table, plus the override example code)

```bash
grep -c "B612 Mono" README.md
```
Expected: at least `1` (in the Nixie override description)

```bash
grep -c "ng-nixie-digit" README.md
```
Expected: at least `2` (in the class documentation and the HTML example)

### Step 4: Commit

```bash
git add README.md
git commit -m "$(cat <<'EOF'
docs: add Typography section to README for Phase 2

- Tagline: adds "3 typography slots" as a third pillar
- New Typography section documenting the token layer:
  - Four tokens (display, body, mono, display-alt) and their roles
  - Google Fonts delivery mechanism
  - Per-theme override mechanism with Nixie as the documented example
  - Usage examples for custom fonts at :root and per-palette
  - The .ng-nixie-digit utility class

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Final holistic review + verification

**Pre-context:** Same pattern as Phase 1 and Phase 1.5's final review. Look for cross-cutting issues that per-task reviewers missed. Run the full test suite.

### Step 1: Run the full system test suite

```bash
bin/rails test
```

Expected: all tests pass cleanly (originals + Phase 1.5's + Phase 2's new 6 = 21 total).

### Step 2: Holistic cross-cutting checks

```bash
# Check for stale mentions of "2 font slots" or "3 fonts" that should be updated
grep -rn "2 font\|two font\|three font" --include="*.erb" --include="*.md" --include="*.css" --include="*.js" -- . 2>&1 | grep -v "node_modules\|\.git\|tailwind.css\|bootstrap_custom"

# Check for any home.html.erb mentions of typography/fonts that might need updating
grep -n "font\|typography\|Typography" app/views/pages/home.html.erb

# Verify the .neon-nixie block has the font overrides
awk '/^\.neon-nixie \{/,/^\}/' app/assets/stylesheets/neon_glow/tokens.css | grep "font-display\|font-body"
```

Investigate any surprising matches. Fix any issues found with tight, commented commits.

### Step 3: Check git log and diff

```bash
git log --oneline main..HEAD
```

Expected: 4 or 5 commits from Phase 2 work (Tasks 1-4 plus possibly a holistic-fix commit).

```bash
git diff main --stat
```

Verify only expected files changed: `tokens.css`, `components.css`, `README.md`, `hardware_palettes_test.rb`, plus the plan document.

### Step 4: Report Phase 2 ready for TK visual review

Status message for TK should include:
- All tests passing
- Branch state (commits ahead of main, clean working tree)
- What to look at during visual review (Nixie on home page, tailwind kitchen sink, bootstrap kitchen sink)
- Specific questions requiring his judgment (the ones from the Phase 2 spec's "Open questions for TK's visual judgment" section)

---

## Definition of done (Phase 2)

- [ ] Google Fonts `@import` in place at top of `tokens.css`
- [ ] Four typography tokens defined in `:root`
- [ ] `.neon-nixie` overrides both `--ng-font-display` and `--ng-font-body` to B612 Mono
- [ ] Typography application section in `components.css` maps tokens to component selectors
- [ ] Wire-grid frame utility class `.ng-nixie-digit` defined
- [ ] Wire-grid frame auto-applies to `.ng-card h1/h2/.h1/.h2/.display-4/.display-5` inside `.neon-nixie`
- [ ] README Typography section added; tagline updated
- [ ] System tests verify typography switching and wire-grid frame
- [ ] All existing Phase 1 and Phase 1.5 tests still pass
- [ ] No stale references uncovered by holistic review
- [ ] TK has visually reviewed and approved:
  - B612 Mono on Nixie (vs. the comparison candidates)
  - Wire-grid frame density and alpha values
  - That mono body text on Nixie reads okay (or fallback: override display only, not body)
  - That no other theme unexpectedly changed
- [ ] Branch merged to main
