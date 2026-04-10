# Phase 1 — Hardware Pair Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add two new color-only palettes — Cherenkov (deep reactor-pool blue) and Nixie (warm amber-orange neon discharge) — to the `neon_glow` Hardware section, without introducing typography or chrome changes (those are Phases 2-5).

**Architecture:** Two additions to `app/assets/stylesheets/neon_glow/tokens.css` following the existing palette block pattern. The Stimulus theme switcher controller gets two new palette names added to its `PALETTES` array. The navbar dropdown gets two new `<option>` entries in the existing `Hardware` optgroup. The home page gets two new palette cards added to the existing Hardware section. A Rails system test exercises the full integration. No changes to typography, JS architecture, or component chrome.

**Tech Stack:** Rails 8.1, CSS custom properties, Stimulus (Hotwire), ERB templates, Minitest + Capybara system tests (Rails 8 default), Selenium-driven headless Chrome for system tests.

**Spec reference:** `docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md` — specifically "The two new palettes" section for exact color specifications, and "Phase 1 — Hardware Pair (color only)" for scope/definition-of-done.

---

## Pre-flight context for the implementing engineer

Read this before starting tasks. You'll save yourself confusion.

**What is `neon_glow`?** It's a CSS theme system that defines ~10 named "palettes" as CSS classes on the `<body>` element (e.g., `.neon-cyberpunk`, `.neon-vfd`). Each palette block overrides a set of CSS custom properties (`--ng-primary`, `--ng-secondary`, etc.) that the rest of the system (in `components.css`) consumes. Switching themes is just swapping a class on `<body>`; a Stimulus controller (`theme_switcher_controller.js`) handles the class swap and persists the choice to `localStorage`.

**Why both `--ng-primary` (hex) and `--ng-primary-rgb` (comma-separated triplet)?** The hex version is used directly as `color:` and `background:` values. The rgb triplet is used inside `rgba(var(--ng-primary-rgb), 0.3)` to produce semi-transparent variants for glow effects. Every color token needs both — the rgb triplet is not optional.

**Why does VFD look different from the other palette blocks?** VFD (around line 424 of `tokens.css`) uses the `hsl(var(--ng-vfd-hue), ...)` pattern because it's parametric — a single slider rotates all its colors through the color wheel. Cherenkov and Nixie do NOT use this pattern. They're locked to a single hue each, following the *spec's physical-authenticity principle*: real Cherenkov radiation and real Nixie discharge each have exactly one color, so giving them sliders would break authenticity. Use plain hex values like the other palette blocks.

**Why does VFD override surfaces (`--ng-bg`, `--ng-surface`) and the other palette blocks don't?** Most palettes inherit the shared dark surface system from `:root` (`#0a0a1e` etc.). VFD overrides surfaces because its concept requires an ultra-dark background to make the phosphor glow pop. Cherenkov and Nixie do the same thing for the same reason — they override surfaces to tinted near-blacks. The spec specifies exact surface values for both.

**Where do palette cards on the home page come from?** They are hand-authored ERB blocks in `app/views/pages/home.html.erb`. There's no dynamic iteration over a palette list — each palette has its own `<div class="ng-card">` with name + description text. When you add a new palette, you add a new card manually to the appropriate `<h2>` section.

**What is the "Hardware" optgroup?** The palette `<select>` in `app/views/shared/_navbar.html.erb` groups palettes into three `<optgroup>` sections: Classic, Decades, and Hardware. Cherenkov and Nixie go into Hardware alongside the existing VFD Display entry.

**Why no tests for the exact CSS color values?** Because "does the CSS file contain the same hex string I typed into it" is a tautology test. The meaningful tests are *integration*: do the palettes show up in the dropdown, does selecting one update the body class, does the home page render the new cards. Those are the tests in Task 6.

**Branch:** This plan assumes you are already on the `design/hardware-themes-and-typography` branch created during brainstorming. If you're not: `git checkout design/hardware-themes-and-typography`.

---

## File structure

Files touched in this phase:

| File | Role | Action |
|---|---|---|
| `app/assets/stylesheets/neon_glow/tokens.css` | CSS custom property definitions for all palettes | Add two new palette blocks (Cherenkov, Nixie) at the end, just before the intensity section. Update header comment palette count 10 → 12. |
| `app/javascript/controllers/theme_switcher_controller.js` | Stimulus controller handling palette class swaps + localStorage persistence | Add `"neon-cherenkov"` and `"neon-nixie"` to the `PALETTES` const array |
| `app/views/shared/_navbar.html.erb` | Navbar partial with the palette `<select>` dropdown | Add two `<option>` entries inside the `Hardware` `<optgroup>` |
| `app/views/pages/home.html.erb` | Home page content including palette gallery cards | Add two new `<div class="ng-card">` entries inside the Hardware section's grid container |
| `README.md` | Project README | Update palette count reference 10 → 12 |
| `test/application_system_test_case.rb` | System test base class (new file) | Create — this project has no system tests yet and the base class must exist before any system test can run |
| `test/system/hardware_palettes_test.rb` | Rails system test (new file) | Create with integration tests for the Hardware palette behaviors |

Files intentionally NOT touched in Phase 1:
- `app/assets/stylesheets/neon_glow/components.css` — component-level styles that consume the tokens. No changes needed; new palettes get component behavior for free via the shared token consumption.
- `app/assets/stylesheets/neon_glow/intensities.css` — intensity modifiers. Same reason as components.
- Any JS file other than `theme_switcher_controller.js` — the palette list lives only in that one file.
- Any test helper/fixture — the test is self-contained.

---

## Task 1: Add Cherenkov palette to tokens.css

**Files:**
- Modify: `app/assets/stylesheets/neon_glow/tokens.css` — append a new palette block after the existing VFD block (which ends around line 482)

**Pre-context:** Open the file and navigate to the end of the VFD palette block (look for the `.neon-vfd-pink { --ng-vfd-hue: 330; }` line — that's the last VFD-related line before the intensity section comment `/* ============================================================ INTENSITY: SUBTLE`). You will insert the new block AFTER the VFD section and BEFORE the intensity section.

- [ ] **Step 1: Insert the Cherenkov palette block**

Open `app/assets/stylesheets/neon_glow/tokens.css`, locate the VFD section's final line (`.neon-vfd-pink { --ng-vfd-hue: 330; }`), and immediately after it (before the next `/* ====...` section separator) insert this exact block:

```css

/* ============================================================
   PALETTE: CHERENKOV
   The deep blue glow of charged particles exceeding the phase
   velocity of light through water. Reactor pool blue.
   Named for Pavel Cherenkov, who discovered the effect in 1934.
   ============================================================ */
.neon-cherenkov {
  --ng-primary:       #3377FF;
  --ng-primary-rgb:   51, 119, 255;
  --ng-secondary:     #196EE6;
  --ng-secondary-rgb: 25, 110, 230;
  --ng-accent:        #6E90F7;
  --ng-accent-rgb:    110, 144, 247;
  --ng-success:       #30BAE8;
  --ng-success-rgb:   48, 186, 232;
  --ng-warning:       #5D52E0;
  --ng-warning-rgb:   93, 82, 224;
  --ng-danger:        #F48C25;
  --ng-danger-rgb:    244, 140, 37;
  --ng-info:          #478CD1;
  --ng-info-rgb:      71, 140, 209;

  --ng-gradient: linear-gradient(
    135deg,
    #3377FF 0%,
    #196EE6 50%,
    #3377FF 100%
  );

  --ng-gradient-border: linear-gradient(
    var(--ng-border-angle, 135deg),
    #3377FF,
    #196EE6,
    #6E90F7
  );

  --ng-bg:             #030510;
  --ng-surface:        #060818;
  --ng-surface-raised: #0a0c22;
  --ng-surface-overlay:#0f1230;
  --ng-border:         #132039;
  --ng-border-subtle:  #0F1624;
  --ng-text:           #C9D4E8;
  --ng-text-secondary: #8B9DC1;
  --ng-text-muted:     #56698F;
}
```

- [ ] **Step 2: Save the file and verify CSS parses cleanly**

Run the Rails server in the background to load the asset pipeline:

```bash
bin/rails server -p 3000 &
sleep 3
curl -s http://localhost:3000/assets/neon_glow/tokens.css 2>/dev/null | grep -c "neon-cherenkov"
kill %1 2>/dev/null
```

Expected output: `1` (meaning the class selector appears once in the served CSS file). If the output is `0`, the file wasn't saved or the asset pipeline rejected it. If curl fails, try the alternative verification below.

Alternative verification without running the server — just grep the raw source file:

```bash
grep -c "^\.neon-cherenkov {" app/assets/stylesheets/neon_glow/tokens.css
```

Expected output: `1`.

- [ ] **Step 3: Commit**

```bash
git add app/assets/stylesheets/neon_glow/tokens.css
git commit -m "$(cat <<'EOF'
feat: add Cherenkov palette to tokens.css

Deep reactor-pool blue (hsl(220, 100%, 60%)) with volumetric
underwater surface tokens. Locked hue — no slider. Follows the
physical-authenticity principle from the spec: the exact color
is the product.

Spec: docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Add Nixie palette to tokens.css

**Files:**
- Modify: `app/assets/stylesheets/neon_glow/tokens.css` — append another palette block after the Cherenkov block you just added

**Pre-context:** Nixie is the other new Hardware palette. Unlike Cherenkov, Nixie adds a *ninth* color token beyond the standard seven: `--ng-nixie-mercury`, which carries the violet mercury-discharge accent color. This is used for the fringe/fallback glow effect and is also where the `danger` state is sourced from (deliberate: a "mercury misbehaving" signal). Nixie also overrides the border-radius tokens to stay hard-edged like VFD, because real Nixie tubes have no rounded corners in their visual identity.

- [ ] **Step 1: Insert the Nixie palette block**

In `app/assets/stylesheets/neon_glow/tokens.css`, immediately after the closing `}` of the `.neon-cherenkov` block from Task 1, insert this exact block:

```css

/* ============================================================
   PALETTE: NIXIE
   Warm amber-orange glow of a 1950s-60s gas-discharge tube.
   Neon with trace mercury vapor, ~170V ignition. The cathode
   wires produced a specific ~605-620nm orange, with a faint
   violet fringe at the base from the mercury component.
   Locked hue — real Nixies came in exactly one color.
   ============================================================ */
.neon-nixie {
  --ng-primary:       #FF6E1A;
  --ng-primary-rgb:   255, 110, 26;
  --ng-secondary:     #E04706;
  --ng-secondary-rgb: 224, 71, 6;
  --ng-accent:        #FFA04D;
  --ng-accent-rgb:    255, 160, 77;
  --ng-success:       #F4AF25;
  --ng-success-rgb:   244, 175, 37;
  --ng-warning:       #F94B1F;
  --ng-warning-rgb:   249, 75, 31;
  --ng-danger:        #A73CDD;
  --ng-danger-rgb:    167, 60, 221;
  --ng-info:          #CC8B66;
  --ng-info-rgb:      204, 139, 102;

  /* Mercury-violet accent — the violet fringe color at the base
     of a lit Nixie tube. Used for fringe/fallback glow effects. */
  --ng-nixie-mercury:     #A219E6;
  --ng-nixie-mercury-rgb: 162, 25, 230;

  --ng-gradient: linear-gradient(
    135deg,
    #FF6E1A 0%,
    #E04706 50%,
    #FF6E1A 100%
  );

  --ng-gradient-border: linear-gradient(
    var(--ng-border-angle, 135deg),
    #FF6E1A,
    #E04706,
    #FFA04D
  );

  --ng-bg:             #0d0706;
  --ng-surface:        #130907;
  --ng-surface-raised: #1a0d09;
  --ng-surface-overlay:#22120c;
  --ng-border:         #362217;
  --ng-border-subtle:  #211712;
  --ng-text:           #ECD4C6;
  --ng-text-secondary: #C59D87;
  --ng-text-muted:     #8F6B56;

  --ng-radius-sm: 0.125rem;
  --ng-radius:    0.125rem;
  --ng-radius-lg: 0.125rem;
  --ng-radius-xl: 0.25rem;
}
```

- [ ] **Step 2: Verify the block was added correctly**

```bash
grep -c "^\.neon-nixie {" app/assets/stylesheets/neon_glow/tokens.css
```

Expected output: `1`.

Also verify the mercury accent token is present:

```bash
grep -c "ng-nixie-mercury:" app/assets/stylesheets/neon_glow/tokens.css
```

Expected output: `1`.

- [ ] **Step 3: Commit**

```bash
git add app/assets/stylesheets/neon_glow/tokens.css
git commit -m "$(cat <<'EOF'
feat: add Nixie palette to tokens.css

Warm amber-orange (hsl(22, 100%, 55%)) locked hue with mercury-
violet accent token for fringe glow effects. Hard-edged radius
override (0.125rem) matching VFD's instrument aesthetic. Danger
state uses the mercury violet as a "tube misbehaving" signal —
deliberate narrative touch per spec.

Spec: docs/superpowers/specs/2026-04-10-hardware-themes-and-typography-design.md

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Register new palettes in the Stimulus theme switcher

**Files:**
- Modify: `app/javascript/controllers/theme_switcher_controller.js` — add `"neon-cherenkov"` and `"neon-nixie"` to the `PALETTES` const array at the top of the file (around line 3-7)

**Pre-context:** The `PALETTES` array is the source of truth for the Stimulus controller. The `applyPalette()` method iterates over it to remove any previously-applied palette class from `<body>` before adding the new one. If a palette name is missing from this array, switching away from it will leave its class on the body, causing visual stacking bugs. This is why every new palette must be registered here, not just added to the CSS.

- [ ] **Step 1: Read the current PALETTES array**

```bash
sed -n '3,8p' app/javascript/controllers/theme_switcher_controller.js
```

Expected output:

```
const PALETTES = [
  "neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink",
  "neon-retrowave", "neon-grunge", "neon-y2k", "neon-social",
  "neon-cyberpunk", "neon-vfd"
]
```

- [ ] **Step 2: Add the two new palette names**

Use your editor to change the `PALETTES` array declaration to:

```javascript
const PALETTES = [
  "neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink",
  "neon-retrowave", "neon-grunge", "neon-y2k", "neon-social",
  "neon-cyberpunk", "neon-vfd", "neon-cherenkov", "neon-nixie"
]
```

Note: `neon-cherenkov` and `neon-nixie` are appended to the end of the array. Order within the array does not affect display or grouping — that's controlled by the navbar `<optgroup>` structure in Task 4. The array is only used to iterate and remove stale classes.

- [ ] **Step 3: Verify the additions**

```bash
grep -c "neon-cherenkov\|neon-nixie" app/javascript/controllers/theme_switcher_controller.js
```

Expected output: `2` (one match per palette name, on the same line).

- [ ] **Step 4: Commit**

```bash
git add app/javascript/controllers/theme_switcher_controller.js
git commit -m "$(cat <<'EOF'
feat: register Cherenkov and Nixie in theme switcher PALETTES array

Ensures applyPalette() correctly removes these classes when
switching away from them. Without this the classes would stack
on body and produce visual bugs.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Add dropdown options to the navbar Hardware optgroup

**Files:**
- Modify: `app/views/shared/_navbar.html.erb` — add two `<option>` entries inside the existing `<optgroup label="Hardware">` block (around lines 26-28)

**Pre-context:** The `<optgroup label="Hardware">` currently contains only `<option value="neon-vfd">VFD Display</option>`. You'll add two more options after it. The `value` attribute must exactly match the CSS class name (`neon-cherenkov`, `neon-nixie`) and the registered name in `PALETTES`. The visible label is the user-facing display name.

- [ ] **Step 1: Modify the Hardware optgroup**

Open `app/views/shared/_navbar.html.erb` and change this block:

```erb
      <optgroup label="Hardware">
        <option value="neon-vfd">VFD Display</option>
      </optgroup>
```

to:

```erb
      <optgroup label="Hardware">
        <option value="neon-vfd">VFD Display</option>
        <option value="neon-cherenkov">Cherenkov</option>
        <option value="neon-nixie">Nixie</option>
      </optgroup>
```

- [ ] **Step 2: Verify the change**

```bash
grep -A3 'optgroup label="Hardware"' app/views/shared/_navbar.html.erb
```

Expected output:

```
      <optgroup label="Hardware">
        <option value="neon-vfd">VFD Display</option>
        <option value="neon-cherenkov">Cherenkov</option>
        <option value="neon-nixie">Nixie</option>
```

- [ ] **Step 3: Commit**

```bash
git add app/views/shared/_navbar.html.erb
git commit -m "$(cat <<'EOF'
feat: add Cherenkov and Nixie to navbar Hardware optgroup

Value attributes match CSS class names exactly so selection
wires straight through to the Stimulus controller without
translation.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Add palette gallery cards to the home page

**Files:**
- Modify: `app/views/pages/home.html.erb` — add two new `<div class="ng-card">` entries inside the Hardware section's grid container (around lines 84-92)

**Pre-context:** The home page has an "eras" section (10 cards) and a "Hardware" section that currently contains just the VFD Display card. You'll add two more cards after VFD, following the exact same structure and inline styles as the existing VFD card. The card text should briefly describe what the palette is evoking — keep it to one short paragraph.

- [ ] **Step 1: Modify the Hardware grid**

Open `app/views/pages/home.html.erb` and change this block (around line 85):

```erb
  <h2 style="color: var(--ng-text-secondary); font-size: 1rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 1.5rem;">Hardware</h2>
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(14rem, 1fr)); gap: 1.5rem; max-width: 64rem; margin: 0 auto;">
    <div class="ng-card ng-border-glow" style="text-align: left;">
      <h3 style="color: var(--ng-primary); font-size: 1rem; font-weight: 700; margin-bottom: 0.5rem;">VFD Display</h3>
      <p style="color: var(--ng-text-muted); font-size: 0.85rem; line-height: 1.5;">
        Vacuum fluorescent display. That warm phosphor glow. Monochromatic with an adjustable hue slider -- just like changing the lens on a real VFD.
      </p>
    </div>
  </div>
```

to:

```erb
  <h2 style="color: var(--ng-text-secondary); font-size: 1rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.1em; margin-bottom: 1.5rem;">Hardware</h2>
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(14rem, 1fr)); gap: 1.5rem; max-width: 64rem; margin: 0 auto;">
    <div class="ng-card ng-border-glow" style="text-align: left;">
      <h3 style="color: var(--ng-primary); font-size: 1rem; font-weight: 700; margin-bottom: 0.5rem;">VFD Display</h3>
      <p style="color: var(--ng-text-muted); font-size: 0.85rem; line-height: 1.5;">
        Vacuum fluorescent display. That warm phosphor glow. Monochromatic with an adjustable hue slider -- just like changing the lens on a real VFD.
      </p>
    </div>
    <div class="ng-card ng-border-glow" style="text-align: left;">
      <h3 style="color: var(--ng-primary); font-size: 1rem; font-weight: 700; margin-bottom: 0.5rem;">Cherenkov</h3>
      <p style="color: var(--ng-text-muted); font-size: 0.85rem; line-height: 1.5;">
        The deep blue glow of charged particles exceeding the phase velocity of light through water. Reactor pool blue. Volumetric and ghostly. Named for Pavel Cherenkov, who discovered the effect in 1934.
      </p>
    </div>
    <div class="ng-card ng-border-glow" style="text-align: left;">
      <h3 style="color: var(--ng-primary); font-size: 1rem; font-weight: 700; margin-bottom: 0.5rem;">Nixie</h3>
      <p style="color: var(--ng-text-muted); font-size: 0.85rem; line-height: 1.5;">
        Warm amber-orange glow of a 1950s-60s gas-discharge tube. Neon with trace mercury vapor, layered depth from stacked cathodes, and a faint violet fringe at the base. The mid-century scientific instrument aesthetic.
      </p>
    </div>
  </div>
```

- [ ] **Step 2: Verify the change**

```bash
grep -c "Cherenkov\|Nixie" app/views/pages/home.html.erb
```

Expected output: `4` (heading text + paragraph text for each of the two new cards).

- [ ] **Step 3: Commit**

```bash
git add app/views/pages/home.html.erb
git commit -m "$(cat <<'EOF'
feat: add Cherenkov and Nixie cards to home page Hardware section

Follows the existing VFD card pattern exactly. Copy briefly
explains what each palette evokes — Cherenkov radiation physics
and the mid-century Nixie tube aesthetic.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: Write Rails system tests for the new palette behavior

**Files:**
- Create: `test/application_system_test_case.rb` (system test base class — does not exist in this project yet)
- Create: `test/system/hardware_palettes_test.rb`

**Pre-context:** Rails 8 ships with Minitest + Capybara for system tests, driven by headless Chrome via Selenium. The test harness boots the app, navigates with a real browser, and asserts on rendered DOM. The required gems (`capybara` and `selenium-webdriver`) are already in the `:test` group of the Gemfile — verified against this project's Gemfile.

**Important:** This project currently has **no system tests at all**, which means `test/application_system_test_case.rb` does not exist yet. Rails generates this file automatically the first time you run `bin/rails generate system_test SomeName`, but we're creating it manually here to keep the plan deterministic. All subsequent system test files will inherit from this one.

There are currently no palette tests in this project. You are establishing the pattern. The tests below focus on *meaningful integration behavior* — dropdown presence, card rendering, and palette class application — not on CSS color value tautologies.

The palette switching happens client-side via JavaScript (Stimulus controller reading the `<select>` change event and updating `document.body.classList`). Capybara with Selenium executes real JavaScript, so `select` + JS assertion works.

- [ ] **Step 1: Create the system test base class**

Create `test/application_system_test_case.rb` with exactly this content:

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
```

This is the standard Rails 8 system test base class. `driven_by :selenium, using: :headless_chrome` means tests will launch real Chrome in headless mode, which executes JavaScript exactly as a user's browser would — important for testing the Stimulus controller behavior.

- [ ] **Step 2: Create the test file**

Create `test/system/hardware_palettes_test.rb` with exactly this content:

```ruby
require "application_system_test_case"

class HardwarePalettesTest < ApplicationSystemTestCase
  # Clear localStorage before each test so palette state from a previous
  # test does not leak into the next one. Capybara reuses the browser
  # session within a test run by default, which means localStorage would
  # otherwise carry over.
  setup do
    visit root_path
    page.execute_script("localStorage.clear()")
  end

  # Helper: count how many of the known palette classes are on <body>.
  # Used to assert that palette switching removes the prior class
  # instead of stacking.
  PALETTE_CLASSES = %w[
    neon-rainbow neon-unicorn neon-cinematic neon-pink
    neon-retrowave neon-grunge neon-y2k neon-social
    neon-cyberpunk neon-vfd neon-cherenkov neon-nixie
  ].freeze

  def count_body_palette_classes
    page.evaluate_script(<<~JS)
      (function() {
        var classes = #{PALETTE_CLASSES.to_json};
        var body = document.body;
        return classes.filter(function(c) { return body.classList.contains(c); }).length;
      })()
    JS
  end

  test "home page renders all three Hardware palette cards" do
    visit root_path

    assert_selector "h2", text: "Hardware"
    assert_selector "h3", text: "VFD Display"
    assert_selector "h3", text: "Cherenkov"
    assert_selector "h3", text: "Nixie"
  end

  test "navbar palette dropdown includes all three Hardware options" do
    visit root_path

    within("select[data-theme-switcher-target='palette']") do
      assert_selector "option[value='neon-vfd']",       text: "VFD Display"
      assert_selector "option[value='neon-cherenkov']", text: "Cherenkov"
      assert_selector "option[value='neon-nixie']",     text: "Nixie"
    end
  end

  test "selecting Cherenkov applies neon-cherenkov class to body" do
    visit root_path

    select "Cherenkov", from: "palette"

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected body to have neon-cherenkov class after selecting Cherenkov"
    assert_equal 1, count_body_palette_classes,
      "expected exactly one palette class on body after selection, " \
      "indicating the prior palette class was cleanly removed"
  end

  test "selecting Nixie applies neon-nixie class to body" do
    visit root_path

    select "Nixie", from: "palette"

    assert page.evaluate_script("document.body.classList.contains('neon-nixie')"),
      "expected body to have neon-nixie class after selecting Nixie"
    assert_equal 1, count_body_palette_classes,
      "expected exactly one palette class on body after selection"
  end

  test "switching between Cherenkov and Nixie does not leave stale palette classes" do
    visit root_path

    select "Cherenkov", from: "palette"
    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")

    select "Nixie", from: "palette"
    assert page.evaluate_script("document.body.classList.contains('neon-nixie')")
    refute page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected neon-cherenkov to be removed after switching to Nixie"
    assert_equal 1, count_body_palette_classes
  end

  test "Cherenkov palette persists across page reloads via localStorage" do
    visit root_path
    select "Cherenkov", from: "palette"
    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")

    visit root_path  # reload

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected Cherenkov palette to persist after page reload"
  end

  test "Nixie palette persists across page reloads via localStorage" do
    visit root_path
    select "Nixie", from: "palette"
    assert page.evaluate_script("document.body.classList.contains('neon-nixie')")

    visit root_path  # reload

    assert page.evaluate_script("document.body.classList.contains('neon-nixie')"),
      "expected Nixie palette to persist after page reload"
  end
end
```

- [ ] **Step 3: Run the new test file**

```bash
bin/rails test:system TEST=test/system/hardware_palettes_test.rb
```

Expected output: all 7 tests pass (`7 runs, X assertions, 0 failures, 0 errors, 0 skips`). Actual assertion count will vary — what matters is zero failures and zero errors.

**Common failure modes and fixes:**
- **`LoadError: cannot load such file -- application_system_test_case`** — Step 1 was skipped or the file wasn't saved. Create it per Step 1 and re-run.
- **`Selenium::WebDriver::Error::WebDriverError: unable to find chromedriver`** — Chrome or chromedriver isn't installed. On macOS: `brew install --cask google-chrome` then let Selenium auto-download chromedriver on first run. On Linux: install `google-chrome-stable` via your package manager.
- **Tests fail on `select "Cherenkov", from: "palette"`** — the `<select>` might not be findable by the label "palette". The navbar uses a `<label>` element with text "Palette". Capybara's `select from:` matches labels case-insensitively by default, so "palette" should work. If it doesn't, change to `find("select[data-theme-switcher-target='palette']").select("Cherenkov")`.
- **Tests fail because `neon-cherenkov` class isn't on body** — check that Tasks 1-5 were all completed and saved. Most likely Task 3 (JS registration) was missed.
- **First run is slow** — Selenium downloads chromedriver on first invocation. Subsequent runs are fast.

- [ ] **Step 4: Run the full test suite to confirm no regressions**

```bash
bin/rails test
bin/rails test:system
```

Expected: both commands pass cleanly. `bin/rails test` runs non-system tests (models, controllers, helpers) and should be unaffected by Phase 1 changes. `bin/rails test:system` runs all system tests, which right now is just the new hardware palettes test.

- [ ] **Step 5: Commit the test file and base class**

```bash
git add test/application_system_test_case.rb test/system/hardware_palettes_test.rb
git commit -m "$(cat <<'EOF'
test: add system test base class and Hardware palette integration tests

Establishes the system test pattern for this project — there
were no system tests prior to this commit. Creates the standard
Rails 8 ApplicationSystemTestCase base class driven by headless
Chrome via Selenium.

Hardware palette tests cover the end-to-end behavior of Cherenkov
and Nixie: card rendering, dropdown options, palette class
application on selection, cleanup of the prior palette class on
switch, and localStorage persistence across reloads. The
count_body_palette_classes helper verifies that switching palettes
never stacks classes on body.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Update palette counts in documentation

**Files:**
- Modify: `README.md` — any line that states the palette count as 10
- Modify: `app/assets/stylesheets/neon_glow/tokens.css` — update the header comment that lists the palette count and names

**Pre-context:** The project has at least two places that cite the palette count: the README and the header docblock at the top of `tokens.css`. Both need to reflect 12 palettes (10 existing + Cherenkov + Nixie). This step is documentation hygiene — if these drift from reality, future-you gets confused about what's actually in the system.

- [ ] **Step 1: Find all mentions of the current count**

```bash
grep -rn "10 palettes\|ten palettes\|10 Palettes" README.md app/assets/stylesheets/neon_glow/tokens.css 2>&1
```

Expected: at least 2 matches, one in README.md and one in tokens.css (in the header comment around line 15).

- [ ] **Step 2: Update the tokens.css header comment**

Find this block near the top of `app/assets/stylesheets/neon_glow/tokens.css` (around lines 10-17):

```
 *   <body class="neon-vfd neon-medium">
 *
 * 10 palettes: Rainbow, Unicorn, Cinematic, Pink, Retrowave,
 *   Grunge, Y2K, Social, Cyberpunk, VFD Display
 */
```

Change it to:

```
 *   <body class="neon-vfd neon-medium">
 *
 * 12 palettes: Rainbow, Unicorn, Cinematic, Pink, Retrowave,
 *   Grunge, Y2K, Social, Cyberpunk, VFD Display, Cherenkov, Nixie
 */
```

- [ ] **Step 3: Update the README palette count**

Open `README.md` and find any line that cites "10 palettes" or similar. Update the count to 12 and, where palette names are listed, append "Cherenkov" and "Nixie" to the list. If the README references Hardware as containing only VFD, update it to reflect VFD + Cherenkov + Nixie.

Run a verification grep to make sure no stale count remains:

```bash
grep -n "10 palette\|ten palette" README.md app/assets/stylesheets/neon_glow/tokens.css
```

Expected output: empty (no matches).

- [ ] **Step 4: Commit**

```bash
git add README.md app/assets/stylesheets/neon_glow/tokens.css
git commit -m "$(cat <<'EOF'
docs: update palette count 10 → 12 for Cherenkov and Nixie

Updates the tokens.css header comment and the README to reflect
the addition of the two new Hardware palettes.

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Manual visual review checkpoint (human-gated)

**This task is not automatable. STOP here and get TK's eyes on the result.**

The entire point of Phase 1 is *visual correctness* — whether the Cherenkov blue actually evokes a reactor pool and whether the Nixie amber actually feels like a mid-century scientific instrument. Automated tests cannot answer those questions. Only TK's human eye can.

- [ ] **Step 1: Start the dev server**

```bash
bin/dev
```

Wait for the "ready" message. The server runs on `http://localhost:3000` by default.

- [ ] **Step 2: Present the results to TK for review**

Ask TK to perform this review sequence in a browser:

1. Open `http://localhost:3000/`.
2. Confirm the home page shows three cards in the Hardware section: VFD Display, Cherenkov, Nixie.
3. From the navbar palette dropdown, select **Cherenkov**. Confirm:
   - The background shifts to a deep tinted near-black
   - Primary color text/borders appear in a saturated deep blue (not cyan, not electric)
   - The glow effects feel "volumetric" — soft large-radius, not sharp
   - It evokes reactor-pool photography if you squint
4. From the navbar palette dropdown, select **Nixie**. Confirm:
   - The background shifts to a warm tinted near-black
   - Primary color text/borders appear in a warm amber-orange (not generic orange, not yellow)
   - Danger-state elements (if visible on the kitchen sink pages) appear in mercury violet
   - It evokes a 1960s lab instrument if you squint
5. Switch between Cherenkov, Nixie, and other palettes several times to confirm no visual stacking or stale class issues.
6. Reload the page while on Cherenkov; confirm Cherenkov persists.
7. Open the Tailwind and Bootstrap kitchen sink pages (linked from the navbar) and verify both new palettes apply correctly there too.

- [ ] **Step 3: Record TK's feedback**

Options from here:

**If TK approves:** Mark this task complete. Phase 1 is ready to merge. Proceed to Task 9.

**If TK wants color adjustments:** This is expected and explicitly in-scope per the spec's "Decisions deferred to implementation" section. Make the adjustments directly in `tokens.css`, re-run the system tests (they should still pass because they don't check specific color values), and re-invite TK for another visual review. Commit each tuning round as `tune:` rather than `feat:`.

**If TK finds a regression on existing palettes:** This is a bug. Stop, debug, fix, re-test. Do not proceed until existing palettes are visually unchanged.

- [ ] **Step 4: Stop the dev server**

```bash
pkill -f "bin/dev" 2>/dev/null || true
```

---

## Task 9: Merge and tag

**Pre-context:** Phase 1 is shippable on its own. After TK's visual approval, this phase closes out with a merge to main and an optional tag. No merge should happen without the visual review in Task 8 passing.

- [ ] **Step 1: Verify the branch is clean and all tests pass**

```bash
git status
bin/rails test:system
```

Expected: clean working tree, all system tests passing.

- [ ] **Step 2: Switch to main and merge the feature branch**

Ask TK whether to use `--no-ff` (explicit merge commit) or fast-forward. The project history on `main` is fast-forward-friendly based on the existing log, so default to fast-forward unless TK prefers explicit merge commits:

```bash
git checkout main
git merge design/hardware-themes-and-typography
```

- [ ] **Step 3: Optionally tag the release**

If TK wants a tagged release for this phase:

```bash
git tag -a v-phase1-hardware-pair -m "Phase 1: Cherenkov and Nixie palettes added"
```

- [ ] **Step 4: Push main (and tags if tagged)**

Ask TK before pushing. Do not push without confirmation.

```bash
git push origin main
# if tagged:
git push origin v-phase1-hardware-pair
```

Phase 1 is complete when the branch is merged to main and TK has visually verified both palettes in the deployed app.

---

## Definition of done (Phase 1)

Per the spec's Phase 1 section, this phase is complete when:

- [ ] Cherenkov palette block exists in `tokens.css` with exact values from the spec.
- [ ] Nixie palette block exists in `tokens.css` with exact values from the spec, including the `--ng-nixie-mercury` accent token.
- [ ] Both palettes are registered in the `PALETTES` array in `theme_switcher_controller.js`.
- [ ] Both palettes appear as `<option>` entries in the Hardware optgroup of the navbar dropdown.
- [ ] Both palettes have cards on the home page Hardware section.
- [ ] The palette count in the README and `tokens.css` header comment reads 12 (not 10).
- [ ] System tests cover card rendering, dropdown presence, palette class application, class cleanup on switch, and localStorage persistence — all passing.
- [ ] TK has visually verified both palettes in a browser and approved.
- [ ] No existing palette has visually regressed.
- [ ] All commits are on `design/hardware-themes-and-typography` or merged to `main`.

## Out of scope (reminder)

Do NOT do any of the following in Phase 1. They belong to later phases:

- Adding typography token overrides (`--ng-font-display`, etc.) — Phase 2.
- Adding Google Fonts `@import` — Phase 2.
- Adding the Nixie wire-grid frame pseudo-element — Phase 2.
- Adding hardware chrome utility classes (`.ng-instrument-frame`, `.ng-vfd-separator`, etc.) — Phase 4.
- Adding Era Chrome for Retrowave/Cyberpunk/Grunge — Phase 5.
- Modifying the existing 10 palettes in any way (colors, radii, surfaces).
- Adding new fields to the theme switcher UI (no new sliders, buttons, or pickers).
- Changing the VFD hue-slider architecture.

If you find yourself touching any file or behavior not listed in the Task table at the top of this plan, stop and re-read the spec. Phase 1 is deliberately narrow.
