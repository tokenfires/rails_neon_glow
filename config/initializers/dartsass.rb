Rails.application.config.dartsass.builds = {
  "bootstrap_custom.scss" => "bootstrap_custom.css"
}
Rails.application.config.dartsass.build_options = [
  "--style=compressed", "--no-source-map", "--quiet-deps"
]
