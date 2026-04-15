import { Controller } from "@hotwired/stimulus"

const PALETTES = [
  "neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink",
  "neon-retrowave", "neon-grunge", "neon-y2k", "neon-social",
  "neon-cyberpunk", "neon-vfd", "neon-cherenkov", "neon-nixie"
]

const VFD_PRESETS = [
  "neon-vfd-red", "neon-vfd-amber", "neon-vfd-yellow", "neon-vfd-green",
  "neon-vfd-cyan", "neon-vfd-blue", "neon-vfd-purple", "neon-vfd-pink"
]

const VFD_PRESET_HUES = {
  "neon-vfd-red": "0", "neon-vfd-amber": "30", "neon-vfd-yellow": "55",
  "neon-vfd-green": "120", "neon-vfd-cyan": "170", "neon-vfd-blue": "210",
  "neon-vfd-purple": "270", "neon-vfd-pink": "330"
}

const INTENSITIES = ["neon-subtle", "neon-medium", "neon-intense", "neon-overdrive"]

// Headings that get per-character wire-grid treatment when Nixie is active.
// We wrap each non-space character in a <span class="ng-nixie-char"> so CSS
// can render one Nixie tube cell per character with spaces producing natural
// gaps between tubes. Pure CSS can't do per-character styling; this is the
// minimal DOM hook needed for that effect.
const NIXIE_HEADING_SELECTORS = [
  ".ng-card h1",
  ".ng-card h2",
  ".ng-card .h1",
  ".ng-card .h2",
  ".ng-card .display-4",
  ".ng-card .display-5"
].join(", ")

const PALETTE_DEFAULT_INTENSITIES = {
  "neon-rainbow":    "neon-medium",
  "neon-unicorn":    "neon-intense",
  "neon-cinematic":  "neon-intense",
  "neon-pink":       "neon-medium",
  "neon-retrowave":  "neon-intense",
  "neon-grunge":     "neon-intense",
  "neon-y2k":        "neon-medium",
  "neon-social":     "neon-subtle",
  "neon-cyberpunk":  "neon-overdrive",
  "neon-vfd":        "neon-medium",
  "neon-cherenkov":  "neon-overdrive",
  "neon-nixie":      "neon-intense",
}

export default class extends Controller {
  static targets = ["palette", "intensity", "vfdHue", "vfdPreset", "vfdHueGroup"]

  connect() {
    const savedPalette = localStorage.getItem("ng-palette") || "neon-rainbow"
    // If no saved intensity, use the current palette's default. This
    // gives new visitors the intended visual register for whichever
    // palette they're seeing first; returning visitors keep their
    // last manual choice.
    const savedIntensity = localStorage.getItem("ng-intensity")
      || PALETTE_DEFAULT_INTENSITIES[savedPalette]
      || "neon-medium"
    const savedHue = localStorage.getItem("ng-vfd-hue") || "170"
    const savedPreset = localStorage.getItem("ng-vfd-preset") || "neon-vfd-cyan"

    this.applyPalette(savedPalette)
    // Explicitly re-apply saved intensity AFTER applyPalette, since
    // applyPalette will have auto-applied the palette default. This
    // ensures returning visitors with a saved manual intensity get
    // their preference back.
    this.applyIntensity(savedIntensity)
    this.applyVfdHue(savedHue)
    this.applyVfdPreset(savedPreset, false)

    if (this.hasPaletteTarget) this.paletteTarget.value = savedPalette
    if (this.hasVfdHueTarget) this.vfdHueTarget.value = savedHue
    if (this.hasVfdPresetTarget) this.vfdPresetTarget.value = savedPreset
  }

  changePalette(event) {
    this.applyPalette(event.target.value)
  }

  changeIntensity(event) {
    this.applyIntensity(event.target.value)
  }

  changeVfdHue(event) {
    this.applyVfdHue(event.target.value)
    if (this.hasVfdPresetTarget) this.vfdPresetTarget.value = "custom"
    localStorage.setItem("ng-vfd-preset", "custom")
  }

  changeVfdPreset(event) {
    this.applyVfdPreset(event.target.value, true)
  }

  applyPalette(palette) {
    const body = document.body
    PALETTES.forEach(p => body.classList.remove(p))
    body.classList.add(palette)
    localStorage.setItem("ng-palette", palette)
    this.toggleVfdControls(palette === "neon-vfd")

    // Auto-apply this palette's default intensity. The user can still
    // manually override afterward; this just lands the palette's
    // intended visual register on first switch.
    const defaultIntensity = PALETTE_DEFAULT_INTENSITIES[palette]
    if (defaultIntensity) {
      this.applyIntensity(defaultIntensity)
    } else {
      console.warn(`[neon_glow] No default intensity defined for palette: ${palette}`)
    }

    // Wrap/unwrap heading characters for the Nixie per-character wire-grid
    // effect. This is the minimal DOM manipulation needed for an effect
    // pure CSS can't express (per-character styling with space-skipping).
    this.updateNixieHeadingWrap()
  }

  updateNixieHeadingWrap() {
    const shouldWrap = document.body.classList.contains("neon-nixie")
    document.querySelectorAll(NIXIE_HEADING_SELECTORS).forEach(el => {
      const isWrapped = el.dataset.nixieWrapped === "true"
      if (shouldWrap && !isWrapped) {
        this.wrapNixieChars(el)
      } else if (!shouldWrap && isWrapped) {
        this.unwrapNixieChars(el)
      }
    })
  }

  wrapNixieChars(el) {
    // Preserve original text so unwrap can restore it exactly.
    if (!el.dataset.nixieOriginal) {
      el.dataset.nixieOriginal = el.textContent
    }
    const text = el.textContent
    // Build a document fragment via safe DOM methods (createElement +
    // textContent). This deliberately avoids innerHTML to eliminate any
    // XSS surface — textContent does not parse HTML, so there is no way
    // for a malicious character in the source text to escape into markup.
    // Spaces stay as plain text nodes so they render without a wire-grid
    // cell (natural "gap between tubes" effect).
    const fragment = document.createDocumentFragment()
    for (const c of text) {
      if (c === " " || c === "\u00a0" || c === "\t") {
        fragment.appendChild(document.createTextNode(c))
      } else {
        const span = document.createElement("span")
        span.className = "ng-nixie-char"
        span.textContent = c
        fragment.appendChild(span)
      }
    }
    el.replaceChildren(fragment)
    el.dataset.nixieWrapped = "true"
  }

  unwrapNixieChars(el) {
    if (el.dataset.nixieOriginal !== undefined) {
      el.textContent = el.dataset.nixieOriginal
      delete el.dataset.nixieOriginal
    }
    delete el.dataset.nixieWrapped
  }

  applyIntensity(intensity) {
    const body = document.body
    INTENSITIES.forEach(i => body.classList.remove(i))
    body.classList.add(intensity)
    localStorage.setItem("ng-intensity", intensity)
    if (this.hasIntensityTarget) this.intensityTarget.value = intensity
  }

  applyVfdHue(hue) {
    document.body.style.setProperty("--ng-vfd-hue", hue)
    localStorage.setItem("ng-vfd-hue", hue)
  }

  applyVfdPreset(preset, updateSlider) {
    const body = document.body
    VFD_PRESETS.forEach(p => body.classList.remove(p))
    if (preset !== "custom") {
      body.classList.add(preset)
      const hue = VFD_PRESET_HUES[preset]
      if (hue && updateSlider) {
        this.applyVfdHue(hue)
        if (this.hasVfdHueTarget) this.vfdHueTarget.value = hue
      }
    }
    localStorage.setItem("ng-vfd-preset", preset)
  }

  toggleVfdControls(show) {
    if (this.hasVfdHueGroupTarget) {
      this.vfdHueGroupTarget.style.display = show ? "flex" : "none"
    }
  }
}
