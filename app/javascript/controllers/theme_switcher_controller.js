import { Controller } from "@hotwired/stimulus"

const PALETTES = [
  "neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink",
  "neon-retrowave", "neon-grunge", "neon-y2k", "neon-social",
  "neon-cyberpunk", "neon-vfd"
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

export default class extends Controller {
  static targets = ["palette", "intensity", "vfdHue", "vfdPreset", "vfdHueGroup"]

  connect() {
    const savedPalette = localStorage.getItem("ng-palette") || "neon-rainbow"
    const savedIntensity = localStorage.getItem("ng-intensity") || "neon-medium"
    const savedHue = localStorage.getItem("ng-vfd-hue") || "170"
    const savedPreset = localStorage.getItem("ng-vfd-preset") || "neon-vfd-cyan"

    this.applyPalette(savedPalette)
    this.applyIntensity(savedIntensity)
    this.applyVfdHue(savedHue)
    this.applyVfdPreset(savedPreset, false)

    if (this.hasPaletteTarget) this.paletteTarget.value = savedPalette
    if (this.hasIntensityTarget) this.intensityTarget.value = savedIntensity
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
  }

  applyIntensity(intensity) {
    const body = document.body
    body.classList.remove("neon-subtle", "neon-medium", "neon-intense")
    body.classList.add(intensity)
    localStorage.setItem("ng-intensity", intensity)
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
