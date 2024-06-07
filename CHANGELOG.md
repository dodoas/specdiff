# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

- Add option to disable color with environment variable "NO_COLOR"
- Default coloring to true if $stdout is terminal

## [0.3.0] - 2024-04-16

### Changed

- Hashprint now sorts keys (if all the keys are strings or symbols), leading to better text diffs from the hash differ.

## [0.3.0.rc2] - 2024-04-05

### Changed

- Rework how hashdiff's output gets printed.
- Rework switching heuristic between text diff/hashdiff in hash differ.

### Fixed

- The RSpec integration now inspects hashes and arrays recursively. (Like rspec does by default)
- RSpec integration no longer breaks description output of matchers when using multi matchers (like .all or .and)
- The hash differ now deals with recursive hashes and arrays
- RSpec integration no longer breaks description output of matchers that are part of a diff inside an array or hash. (like when doing `match([have_attributes(...)])`)

## [0.3.0-rc1] - 2024-04-02

### Added

- Add rspec integration. `require "specdiff/rspec"` The rspec integration will cause rspec's differ to be replaced entirely with specdiff. It will also cause rspec's inspect (object formatter) to be replaced with Specdiff's inspect.
- Add `Specdiff.diff_inspect` method, which is a wrapper for `#inspect` with some extra logic to make diffs look better.
- Add `Specdiff.hashprint` method, which prints hashes/arrays recursively in a way that is friendly to a text differ.

### Changed

- Improve contrast for some elements of the text differ
- Improve hash diffing. Introduce heuristic that decides whether a text diff of the hashes or the hashdiff gem's output is better for the situation.
- No longer produces a text diff of booleans
- No longer produces a text diff if both strings are a single line. (This would be useless since the diff is line-based.)

## [0.2.0] - 2023-12-04

### Changed

- Stop using thread locals ([#1](https://github.com/odinhb/specdiff/pull/1))

## [0.1.1] - 2023-12-04

### Fixed

- Fix #empty? not returning true when the diff is actually empty

## [0.1.0] - 2023-11-30

- Initial release
