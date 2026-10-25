# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.2] - 2026-10-26

Small patch release introducing full Docker containerization, modernizing the Android build toolchain to Gradle 9 and Kotlin DSL, and resolving subproject SDK compatibility.

### Added

- Docker support with multi-stage `Dockerfile` and BuildKit artifact export (`--output type=local,dest=./output`)
- `docker-compose.yml` configurations for debug APK, release APK, Android App Bundle (`build-bundle`), test suites, and interactive development shell
- `DOCKER.md` documentation covering containerized build workflows and wireless ADB device debugging
- Enabled core library desugaring in `android/app/build.gradle.kts` for `flutter_local_notifications` compatibility

### Changed

- Migrated Android build scripts from legacy Groovy to Kotlin DSL (`build.gradle.kts`, `settings.gradle.kts`, `app/build.gradle.kts`)
- Upgraded Gradle wrapper to 9.3.1 and Android Gradle Plugin (AGP) to 9.1.0
- Added subproject evaluation hook in `android/build.gradle.kts` ensuring legacy plugins (such as `image_cropper`) compile against Android API 36
- Removed obsolete Groovy `.gradle` files and duplicate package directory structure

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

[Unreleased]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/compare/v1.0.2...HEAD
[1.0.2]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/releases/tag/v1.0.2
[1.0.1]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/tanishqmudaliar/Synergy-Visitor-Log/releases/tag/v1.0.0
