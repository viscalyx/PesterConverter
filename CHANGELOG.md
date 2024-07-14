# Changelog for PesterConverter

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Public commands:
  - `Convert-PesterSyntax`
- Add support for Should operators:
  - Be
  - BeExactly
  - BeFalse
  - BeGreaterOrEqual
  - BeGreaterThan
  - BeIn
  - BeLessOrEqual
  - BeLessThan
  - BeLike
  - BeLikeExactly
  - BeNullOrEmpty
  - BeOfType
  - BeTrue
  - Contain
  - Match
  - MatchExactly
  - Throw

### Fixed

- Improve code to resolve ScriptAnalyzer warnings and errors.
- Localize all the strings.
