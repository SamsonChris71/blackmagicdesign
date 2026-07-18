# Changelog

All notable changes to this project will be documented in this file.

## [0.2.1]

### Changed

- Added API documentation for ATEM and HyperDeck libraries and operations.
- Applied HyperDeck lint-only control-flow formatting improvements.

## [0.2.0]

### Added

- Exported Web Presenter APIs from the package root.
- Added Streaming XML builders for custom Web Presenter/Streaming Encoder
  platforms.
- Added Web Presenter REST notification WebSocket support.
- Added HyperDeck shortHelp() and slot-specific record-spill helpers.

### Fixed

- Web Presenter status request helpers now complete with the requested status
  block instead of the intermediate ACK.
- Web Presenter REST base URL normalization now accepts both device roots and
  /control/api/v1 URLs.

## [0.1.0]

### Changed

- Migrated the package to null safety and current Dart SDKs.
- Made HyperDeck connection handling asynchronous and added close().
- Corrected stopRecording() to send the HyperDeck stop command.
- Added a runnable HyperDeck example.

## [0.0.1]

### Added

- HyperDeck Connection Module

## [0.0.2]

### Added

- Hyperdeck Operation Module
- Hyperdeck Device and transport info
