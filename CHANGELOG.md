# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/releases/tag/v1.0.0
