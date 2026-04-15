require "application_system_test_case"

class HardwarePalettesTest < ApplicationSystemTestCase
  # Clear localStorage before each test so palette state from a previous
  # test does not leak into the next one. Capybara reuses the browser
  # session within a test run by default, which means localStorage would
  # otherwise carry over.
  #
  # Sequence: visit to get a page context → clear localStorage → visit
  # again so the Stimulus controller's connect() re-runs with empty
  # storage. Without the second visit, setup exits with the controller
  # still holding stale state from the first visit.
  setup do
    visit root_path
    page.execute_script("localStorage.clear()")
    visit root_path
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

    assert_selector "h2", text: "HARDWARE"

    # Scope card assertions to the grid container immediately following
    # the Hardware heading, so a regression that moves these cards to
    # another section would fail this test.
    #
    # XPath note: the DOM text is "Hardware" (mixed case) while Capybara's
    # text: option above sees "HARDWARE" (rendered text, because of CSS
    # text-transform: uppercase on the h2). XPath's text() function uses
    # DOM text, so we match "Hardware" here.
    within(:xpath, "//h2[normalize-space(text())='Hardware']/following-sibling::div[1]") do
      assert_selector "h3", text: "VFD Display"
      assert_selector "h3", text: "Cherenkov"
      assert_selector "h3", text: "Nixie"
    end
  end

  test "navbar palette dropdown includes all three Hardware options" do
    visit root_path

    within("select[data-theme-switcher-target='palette']") do
      within("optgroup[label='Hardware']") do
        assert_selector "option[value='neon-vfd']",       text: "VFD Display"
        assert_selector "option[value='neon-cherenkov']", text: "Cherenkov"
        assert_selector "option[value='neon-nixie']",     text: "Nixie"
      end
    end
  end

  test "selecting Cherenkov applies neon-cherenkov class to body" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected body to have neon-cherenkov class after selecting Cherenkov"
    assert_equal 1, count_body_palette_classes,
      "expected exactly one palette class on body after selection, " \
      "indicating the prior palette class was cleanly removed"
  end

  test "selecting Nixie applies neon-nixie class to body" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    assert page.evaluate_script("document.body.classList.contains('neon-nixie')"),
      "expected body to have neon-nixie class after selecting Nixie"
    assert_equal 1, count_body_palette_classes,
      "expected exactly one palette class on body after selection"
  end

  test "switching between Cherenkov and Nixie does not leave stale palette classes" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")

    find("select[data-theme-switcher-target='palette']").select("Nixie")
    assert page.evaluate_script("document.body.classList.contains('neon-nixie')")
    refute page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected neon-cherenkov to be removed after switching to Nixie"
    assert_equal 1, count_body_palette_classes
  end

  test "Cherenkov palette persists across page reloads via localStorage" do
    visit root_path
    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")

    visit root_path  # reload

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')"),
      "expected Cherenkov palette to persist after page reload"
  end

  test "Nixie palette persists across page reloads via localStorage" do
    visit root_path
    find("select[data-theme-switcher-target='palette']").select("Nixie")
    assert page.evaluate_script("document.body.classList.contains('neon-nixie')")

    visit root_path  # reload

    assert page.evaluate_script("document.body.classList.contains('neon-nixie')"),
      "expected Nixie palette to persist after page reload"
  end

  test "selecting Cyberpunk auto-applies neon-overdrive intensity" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("2020's Cyberpunk")

    assert page.evaluate_script("document.body.classList.contains('neon-cyberpunk')"),
      "expected body to have neon-cyberpunk class"
    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')"),
      "expected Cyberpunk to auto-apply neon-overdrive intensity"

    intensity_value = page.evaluate_script("document.querySelector(\"select[data-theme-switcher-target='intensity']\").value")
    assert_equal "neon-overdrive", intensity_value,
      "expected intensity dropdown to reflect the auto-applied Overdrive selection"
  end

  test "selecting Cherenkov auto-applies neon-overdrive intensity" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")
    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')"),
      "expected Cherenkov to auto-apply neon-overdrive intensity"
  end

  test "selecting Social auto-applies neon-subtle intensity" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("2010's Social")

    assert page.evaluate_script("document.body.classList.contains('neon-social')")
    assert page.evaluate_script("document.body.classList.contains('neon-subtle')"),
      "expected Social to auto-apply neon-subtle intensity"
  end

  test "selecting Nixie auto-applies neon-intense intensity" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    assert page.evaluate_script("document.body.classList.contains('neon-nixie')")
    assert page.evaluate_script("document.body.classList.contains('neon-intense')"),
      "expected Nixie to auto-apply neon-intense intensity"
  end

  test "switching palettes overrides any manual intensity choice" do
    visit root_path

    # Start by selecting Cyberpunk (auto-applies overdrive)
    find("select[data-theme-switcher-target='palette']").select("2020's Cyberpunk")
    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')")

    # Manually change intensity to subtle
    find("select[data-theme-switcher-target='intensity']").select("Subtle")
    assert page.evaluate_script("document.body.classList.contains('neon-subtle')")
    refute page.evaluate_script("document.body.classList.contains('neon-overdrive')")

    # Switch palette to Cherenkov — should auto-apply overdrive (Cherenkov's default),
    # overriding the manual subtle choice
    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')"),
      "switching palettes should auto-apply the new palette's default intensity, overriding manual choice"
    refute page.evaluate_script("document.body.classList.contains('neon-subtle')")
  end

  test "neon-overdrive is selectable as a manual intensity choice" do
    visit root_path

    find("select[data-theme-switcher-target='intensity']").select("Overdrive")

    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')"),
      "Overdrive should be selectable as a manual intensity choice"
  end

  test "saved manual intensity persists across page reloads" do
    visit root_path

    # Set a manual intensity preference (subtle) — this writes to localStorage
    find("select[data-theme-switcher-target='intensity']").select("Subtle")
    assert page.evaluate_script("document.body.classList.contains('neon-subtle')")

    # Now reload the page; saved preference should win over palette default
    visit root_path
    assert page.evaluate_script("document.body.classList.contains('neon-subtle')"),
      "saved manual intensity should persist across page reloads"
  end

  test "first load without saved intensity applies palette default" do
    visit root_path

    # Clear ALL state and set palette WITHOUT setting intensity
    page.execute_script("localStorage.clear()")
    page.execute_script("localStorage.setItem('ng-palette', 'neon-cherenkov')")

    visit root_path

    assert page.evaluate_script("document.body.classList.contains('neon-cherenkov')")
    assert page.evaluate_script("document.body.classList.contains('neon-overdrive')"),
      "first-load with palette saved but no intensity saved should apply the palette default"
  end

  test "Nixie palette applies B612 Mono to body text" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    font_family = page.evaluate_script(
      "window.getComputedStyle(document.body).getPropertyValue('font-family')"
    )
    assert_match(/B612\s*Mono/i, font_family,
      "expected --ng-font-body to include B612 Mono when Nixie is active; got: #{font_family}")
  end

  test "non-Nixie palette does not use B612 Mono on body" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    font_family = page.evaluate_script(
      "window.getComputedStyle(document.body).getPropertyValue('font-family')"
    )
    refute_match(/B612\s*Mono/i, font_family,
      "expected --ng-font-body to NOT include B612 Mono when Cherenkov is active; got: #{font_family}")
  end

  test "all four typography tokens are defined on :root" do
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
    refute body_font.empty?, "expected --ng-font-body to be defined; got empty string"
    refute mono_font.empty?, "expected --ng-font-mono to be defined; got empty string"
    refute alt_font.empty?, "expected --ng-font-display-alt to be defined; got empty string"
  end

  test "Nixie card headings have per-character wire-grid frame via .ng-nixie-char wrapping" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    # The home page only has h3 elements inside .ng-card; wire-grid applies to
    # h1/h2/.h1/.h2/.display-4/.display-5. Visit the Bootstrap kitchen sink
    # which has both h1 and h2 inside .ng-card. Palette persists via localStorage.
    visit bootstrap_kitchen_sink_path

    # Under the per-character architecture, Nixie headings don't have a ::before
    # on the heading itself — instead, theme_switcher_controller.js wraps each
    # non-space character in a .ng-nixie-char span, and each span has its own
    # wire-grid ::before. Verify the wrapping happened AND the wrapped chars
    # have the expected pseudo-element.
    bg_image = page.evaluate_script(<<~JS)
      (function() {
        var heading = document.querySelector('.ng-card h1, .ng-card h2, .ng-card .h1, .ng-card .h2, .ng-card .display-4, .ng-card .display-5');
        if (!heading) return 'NO_HEADING_FOUND';
        var wrappedChar = heading.querySelector('.ng-nixie-char');
        if (!wrappedChar) return 'NO_WRAPPED_CHAR_FOUND';
        var style = window.getComputedStyle(wrappedChar, '::before');
        return style.getPropertyValue('background-image') || 'EMPTY';
      })()
    JS

    refute_equal "NO_HEADING_FOUND", bg_image,
      "no card heading found on the page; test setup may need a page with card headings"
    refute_equal "NO_WRAPPED_CHAR_FOUND", bg_image,
      "heading text was not wrapped in .ng-nixie-char spans — JS character wrapping may not have run"
    refute_equal "EMPTY", bg_image,
      "expected wire-grid frame ::before background-image to be set on .ng-nixie-char"
    assert_match(/linear-gradient/i, bg_image,
      "expected ::before background-image to contain a linear-gradient; got: #{bg_image}")
  end

  test "non-Nixie palette card headings do not have wire-grid frame" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    # Visit bootstrap kitchen sink for consistent h1/h2 card headings (home page
    # only has h3 inside .ng-card). Palette persists via localStorage.
    visit bootstrap_kitchen_sink_path

    bg_image = page.evaluate_script(<<~JS)
      (function() {
        var heading = document.querySelector('.ng-card h1, .ng-card h2, .ng-card .h1, .ng-card .h2');
        if (!heading) return 'NO_HEADING_FOUND';
        var style = window.getComputedStyle(heading, '::before');
        return style.getPropertyValue('background-image') || 'EMPTY';
      })()
    JS

    refute_equal "NO_HEADING_FOUND", bg_image
    # The wire-grid frame is specifically a repeating-linear-gradient.
    # Other CSS may legitimately set ::before background images for other
    # reasons, so we only verify the wire-grid pattern is absent.
    if bg_image != "EMPTY" && bg_image != "none"
      refute_match(/repeating-linear-gradient/i, bg_image,
        "expected wire-grid (repeating-linear-gradient) to NOT apply to Cherenkov card headings; got: #{bg_image}")
    end
  end

  test "ng-nixie-digit utility class renders wire-grid frame when applied" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    # Inject a test element with the .ng-nixie-digit class and verify
    # the pseudo-element rendering.
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

  # ============================================================
  # Phase 2.5 — Neon Tube Affordance (.ng-neon-tube)
  #
  # Generalizes Phase 2's underline-font + character-wrap effect to
  # any element, regardless of palette. Each palette's primary color
  # carries a differently-colored "neon tube" shape composed from
  # Montserrat Underline's built-in underline strokes.
  #
  # The home page hero H1 "Neon Glow" uses this utility, making it
  # a good fixture for these tests.
  # ============================================================

  test "ng-neon-tube applies Montserrat Underline font across palettes" do
    visit root_path

    # Default palette (Rainbow): hero should already be in Montserrat Underline
    hero_font = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('font-family')"
    )
    assert_match(/Montserrat\s*Underline/i, hero_font,
      "expected .ng-neon-tube to apply Montserrat Underline on default palette; got: #{hero_font}")

    # Switch to a non-Nixie palette and confirm the font persists
    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    hero_font = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('font-family')"
    )
    assert_match(/Montserrat\s*Underline/i, hero_font,
      "expected .ng-neon-tube to keep Montserrat Underline under Cherenkov; got: #{hero_font}")
  end

  test "ng-neon-tube picks up palette primary color" do
    visit root_path

    # Get the rendered color under Cherenkov
    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    cherenkov_color = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('color')"
    )

    # Switch palettes; color should change (palettes have distinct primaries)
    find("select[data-theme-switcher-target='palette']").select("2020's Cyberpunk")
    cyberpunk_color = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('color')"
    )

    refute_equal cherenkov_color, cyberpunk_color,
      "expected .ng-neon-tube color to change between palettes with distinct primaries; " \
      "both palettes rendered as: #{cherenkov_color}"
  end

  test "ng-neon-tube gets character-wrapped when Nixie palette is active" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Nixie")

    wrapped_count = page.evaluate_script(<<~JS)
      document.querySelectorAll('.ng-neon-tube .ng-nixie-char').length
    JS
    assert wrapped_count > 0,
      "expected .ng-neon-tube to be character-wrapped with .ng-nixie-char spans " \
      "when Nixie is active; got #{wrapped_count} wrapped spans"
  end

  test "ng-neon-tube glow scales with intensity" do
    visit root_path

    # Cherenkov uses Overdrive by default. Compare the rendered text-shadow
    # on Overdrive vs. Subtle — the neon-tube glow should expand/contract
    # with intensity (regression test: an earlier implementation hardcoded
    # the text-shadow and did not respond to intensity changes).
    find("select[data-theme-switcher-target='palette']").select("Cherenkov")
    overdrive_shadow = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('text-shadow')"
    )

    find("select[data-theme-switcher-target='intensity']").select("Subtle")
    subtle_shadow = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('.ng-neon-tube')).getPropertyValue('text-shadow')"
    )

    refute_equal overdrive_shadow, subtle_shadow,
      "expected .ng-neon-tube text-shadow to change with intensity; " \
      "both rendered as: #{overdrive_shadow}"
  end

  test "ng-neon-tube character wrap skips newlines from ERB indentation" do
    # Regression: the home page hero spans multiple lines inside its
    # <h1>, so textContent contains leading/trailing newlines + spaces.
    # An earlier wrapper enumerated only ' ', '\u00a0', '\t' as
    # whitespace, causing newlines to get wrapped in .ng-nixie-char
    # spans. Under Nixie those empty spans rendered as visible extra
    # wire-grid cells flanking "Neon Glow". Fix was switching to a
    # /\s/ whitespace test. Assert every wrapped span has non-whitespace
    # content.
    visit root_path
    find("select[data-theme-switcher-target='palette']").select("Nixie")

    bad_chars = page.evaluate_script(<<~JS)
      Array.from(document.querySelectorAll('.ng-neon-tube .ng-nixie-char'))
        .map(el => el.textContent)
        .filter(t => /^\\s*$/.test(t))
    JS

    assert_equal [], bad_chars,
      "expected no .ng-nixie-char span to contain only whitespace; " \
      "found #{bad_chars.length} whitespace-only spans: #{bad_chars.inspect}"
  end

  test "ng-neon-tube is not character-wrapped on non-Nixie palettes" do
    visit root_path

    find("select[data-theme-switcher-target='palette']").select("Cherenkov")

    wrapped_count = page.evaluate_script(<<~JS)
      document.querySelectorAll('.ng-neon-tube .ng-nixie-char').length
    JS
    assert_equal 0, wrapped_count,
      "expected .ng-neon-tube to NOT be character-wrapped on non-Nixie palettes; " \
      "Cherenkov produced #{wrapped_count} wrapped spans"
  end
end
