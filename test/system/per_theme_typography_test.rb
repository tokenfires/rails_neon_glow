require "application_system_test_case"

# Phase 3 — per-theme display font overrides.
#
# Each Tier B palette overrides --ng-font-display to a face that fits
# its referent. These tests assert the computed font-family on a
# display element (.ng-card h3 on the home page is convenient) contains
# the expected face when the corresponding palette is active.
#
# CAVEAT: getComputedStyle returns the *declared* font-family string,
# not whether the font actually loaded. If Google Fonts fails to deliver
# the file, tests still pass while the page renders the fallback.
# Visual review is the only check for actual font loading. See CLAUDE.md.
class PerThemeTypographyTest < ApplicationSystemTestCase
  setup do
    visit root_path
    page.execute_script("localStorage.clear()")
    visit root_path
  end

  # Helper: read the computed font-family of the first .ng-card h3 on
  # the home page. h3 inherits --ng-font-display-alt which defaults to
  # --ng-font-display, so per-palette display overrides land here.
  def display_font_family
    page.evaluate_script(<<~JS)
      (function() {
        var el = document.querySelector('.ng-card h3');
        if (!el) return 'NO_ELEMENT';
        return window.getComputedStyle(el).getPropertyValue('font-family');
      })()
    JS
  end

  def select_palette(label)
    find("select[data-theme-switcher-target='palette']").select(label)
  end

  # ---------- Batch 1 — Geometric sans ----------

  test "Retrowave applies Orbitron to display elements" do
    select_palette("80's Retrowave")
    assert_match(/Orbitron/i, display_font_family,
      "expected Retrowave to set --ng-font-display to Orbitron; got: #{display_font_family}")
  end

  test "Y2K applies Syncopate to display elements" do
    select_palette("2000's Y2K")
    assert_match(/Syncopate/i, display_font_family,
      "expected Y2K to set --ng-font-display to Syncopate; got: #{display_font_family}")
  end

  test "Cherenkov applies Space Grotesk to display elements" do
    select_palette("Cherenkov")
    assert_match(/Space\s*Grotesk/i, display_font_family,
      "expected Cherenkov to set --ng-font-display to Space Grotesk; got: #{display_font_family}")
  end

  # ---------- Batch 2 — Monospace-adjacent ----------

  test "Cyberpunk applies Share Tech Mono to display elements" do
    select_palette("2020's Cyberpunk")
    assert_match(/Share\s*Tech\s*Mono/i, display_font_family,
      "expected Cyberpunk to set --ng-font-display to Share Tech Mono; got: #{display_font_family}")
  end

  test "VFD applies VT323 to display elements" do
    select_palette("VFD Display")
    assert_match(/VT323/i, display_font_family,
      "expected VFD to set --ng-font-display to VT323; got: #{display_font_family}")
  end

  # ---------- Cross-palette sanity ----------

  test "switching palettes changes the display font" do
    # Three Batch 1 palettes use distinct faces; the computed
    # font-family string should differ between them.
    select_palette("80's Retrowave")
    retrowave_font = display_font_family

    select_palette("2000's Y2K")
    y2k_font = display_font_family

    select_palette("Cherenkov")
    cherenkov_font = display_font_family

    refute_equal retrowave_font, y2k_font,
      "Retrowave and Y2K should have distinct display fonts"
    refute_equal y2k_font, cherenkov_font,
      "Y2K and Cherenkov should have distinct display fonts"
    refute_equal retrowave_font, cherenkov_font,
      "Retrowave and Cherenkov should have distinct display fonts"
  end
end
