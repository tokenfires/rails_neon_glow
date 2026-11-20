# Runtime upgrade plan

1. Verify release availability and a clean, synchronized starting branch.
2. Update Ruby declarations, the Rails dependency, and Docker version.
3. Resolve dependencies with Bundler using Ruby 4.0.10.
4. Run application boot, Zeitwerk, unit, and system checks; fix compatibility issues.
5. Review the diff, commit, fast-forward main, push, and verify the remote commit.

Validation: Bundler, runtime versions, application boot, and Zeitwerk pass.
The unit command completes with no unit tests defined. All 49 browser system
tests pass (109 assertions) on Ruby 4.0.10 and Rails 8.1.4.1.
