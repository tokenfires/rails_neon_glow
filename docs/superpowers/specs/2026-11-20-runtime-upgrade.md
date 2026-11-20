# Ruby and Rails maintenance upgrade

Run the application on Ruby 4.0.10 and Rails 8.1.4.1. Keep the runtime
declaration, Bundler lockfile, and Docker build version consistent.
Preserve the existing Rails 8.1 defaults and visual behavior.

Acceptance: Bundler resolves and installs successfully; the application boots;
Zeitwerk, unit tests, and browser system tests pass under Ruby 4.0.10.
Commit the verified upgrade and fast-forward the main branch, then push it.
