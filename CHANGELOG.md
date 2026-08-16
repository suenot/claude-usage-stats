# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-08-16

### Added

- Added independent sharing controls and public routes for sanitized session and project analytics.

### Security

- Public session and project responses use explicit field allowlists and omit prompts, paths, session identifiers, files, and device metadata.

## [0.2.0] - 2026-08-16

### Added

- Added multi-device CLI synchronization with stable private device identities and fleet-wide aggregation.
- Added a private, range-aware device usage chart with USD, token and session metrics.

### Changed

- Replaced the duplicate landing-page hero logo with telemetry facts and clarified private device-label handling.

### Fixed

- Increased the installation command line height and vertical clearance so glyphs are not clipped.

### Security

- Updated resolved Hono and Nano ID dependencies to patched releases.

## [0.1.2] - 2026-08-16

### Fixed

- Made the landing-page CLI installation command a prominent full-width hero strip.

## [0.1.1] - 2026-08-16

### Fixed

- Exposed the Harness Analyzer CLI installation command on the public landing page.
- Corrected landing-page privacy copy for aggregate hosted synchronization.
