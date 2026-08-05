# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-08-05

Second official release. This update focuses on stability fixes, clearer check-in validation, and a cleaner confirmation experience.

### Added

- Clear duplicate check-in protection so a person already checked in must check out first
- Safer host and location dropdown handling when no staff or locations exist yet

### Changed

- Updated the In confirmation flow wording to match the actual staff-and-location check-in process
- Fixed the In screen so registered members load from the enrolled users table again
- Removed the Members host dropdown from the staff listing to avoid confusing empty-state behavior
- Squared off the confirmation photo container so it matches the photo-picker style better
- Tightened empty-state handling in Members, In, and Out so they stop loading immediately when no data exists

## [1.0.0] - 2026-08-02

First official release. Release and debug APKs are attached to this GitHub release.

### Added

- Offline-first visitor management flow: enroll, check-in, check-out, and staff/member management
- Camera and gallery photo capture with automatic face-aware cropping
- Speech-to-text input across enrollment and search screens
- Local notifications for enrollment and staff creation events
- Local persistence using SQLite (`sqflite`) and `SharedPreferences`

### Changed

- Removed the Firebase dependency in favor of a fully local, offline workflow
- Dropped iOS support to focus on the Android-first experience
- Updated Gradle configuration, Android manifest, and theme resources for compatibility with newer build tooling
- Refreshed dependency metadata and lockfiles for build reliability
- Expanded README documentation with license, roadmap, and contribution guidelines

[Unreleased]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/compare/v1.0.1...HEAD
[1.0.1]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/releases/tag/v1.0.1
[1.0.0]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/releases/tag/v1.0.0
