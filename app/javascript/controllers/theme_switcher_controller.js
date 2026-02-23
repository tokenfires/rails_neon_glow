import { Controller } from "@hotwired/stimulus"

const PALETTES = [
  "neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink",
  "neon-retrowave", "neon-grunge", "neon-y2k", "neon-social",
  "neon-cyberpunk", "neon-vfd"
]

export default class extends Controller {
  static targets = ["palette", "intensity", "vfdHue", "vfdHueGroup"]

  connect() {
    const savedPalette = localStorage.getItem("ng-palette") || "neon-rainbow"
    const savedIntensity = localStorage.getItem("ng-intensity") || "neon-medium"
    const savedHue = localStorage.getItem("ng-vfd-hue") || "170"

    this.applyPalette(savedPalette)
    this.applyIntensity(savedIntensity)
    this.applyVfdHue(savedHue)

    if (this.hasPaletteTarget) this.paletteTarget.value = savedPalette
    if (this.hasIntensityTarget) this.intensityTarget.value = savedIntensity
    if (this.hasVfdHueTarget) this.vfdHueTarget.value = savedHue
  }

  changePalette(event) {
    this.applyPalette(event.target.value)
  }

  changeIntensity(event) {
    this.applyIntensity(event.target.value)
  }

  changeVfdHue(event) {
    this.applyVfdHue(event.target.value)
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

  toggleVfdControls(show) {
    if (this.hasVfdHueGroupTarget) {
      this.vfdHueGroupTarget.style.display = show ? "flex" : "none"
    }
  }
}
