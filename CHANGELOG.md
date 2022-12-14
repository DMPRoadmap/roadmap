# Changelog

### Added

- Added CHANGELOG.md and Danger Github Action [#3257](https://github.com/DMPRoadmap/roadmap/issues/3257)
- Added validation with custom error message in research_output.rb to ensure a user does not enter a very large value as 'Anticipated file size'. [#3161] (https://github.com/DMPRoadmap/roadmap/issues/3161)
### Fixed

- Updated JS that used to call the TinyMCE `setMode()` function so that it now calls `mode.set()` because the former is now deprecated.

### Changed

- Added scss files to EditorConfig
