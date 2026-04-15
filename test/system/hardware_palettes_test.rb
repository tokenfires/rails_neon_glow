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
end
