import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["palette", "intensity"]

  connect() {
    const savedPalette = localStorage.getItem("ng-palette") || "neon-rainbow"
    const savedIntensity = localStorage.getItem("ng-intensity") || "neon-medium"

    this.applyPalette(savedPalette)
    this.applyIntensity(savedIntensity)

    if (this.hasPaletteTarget) this.paletteTarget.value = savedPalette
    if (this.hasIntensityTarget) this.intensityTarget.value = savedIntensity
  }

  changePalette(event) {
    this.applyPalette(event.target.value)
  }

  changeIntensity(event) {
    this.applyIntensity(event.target.value)
  }

  applyPalette(palette) {
    const body = document.body
    body.classList.remove("neon-rainbow", "neon-unicorn", "neon-cinematic", "neon-pink")
    body.classList.add(palette)
    localStorage.setItem("ng-palette", palette)
  }

  applyIntensity(intensity) {
    const body = document.body
    body.classList.remove("neon-subtle", "neon-medium", "neon-intense")
    body.classList.add(intensity)
    localStorage.setItem("ng-intensity", intensity)
  }
}
