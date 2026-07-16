# Synergy Visitor Log

Local-first Flutter visitor management app for enroll, check-in, check-out, and staff listing.

This repository is designed to run offline on a single Android device. It uses local storage, local image handling, local speech input, and local notifications. There is no Firebase dependency in the current codebase.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-Local%20App-3DDC84?logo=android&logoColor=white)
![Storage](https://img.shields.io/badge/Storage-SQLite%20%2B%20SharedPreferences-003B57?logo=sqlite&logoColor=white)
![Offline](https://img.shields.io/badge/Offline-First-blue)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## Table of Contents

- [Overview](#overview)
- [What This App Is](#what-this-app-is)
- [What It Is Not](#what-it-is-not)
- [Core Tasks](#core-tasks)
- [Screen Map](#screen-map)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Shared Storage](#shared-storage)
- [Local Database](#local-database)
- [File-by-File Guide](#file-by-file-guide)
- [Screen Reference](#screen-reference)
- [Data Flow](#data-flow)
- [Photo Pipeline](#photo-pipeline)
- [Speech Input Flow](#speech-input-flow)
- [Notifications](#notifications)
- [Permissions](#permissions)
- [Offline Behavior](#offline-behavior)
- [Known Limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [Roadmap](#roadmap)
- [License](#license)
- [Summary](#summary)

---

## Overview

Synergy Visitor Log is a Flutter app for managing visitors and staff with a fully local workflow.

The app supports:

- visitor enrollment
- photo capture
- face-aware image handling
- check-in
- check-out
- staff management
- local persistence

The app stores state on-device using `SharedPreferences` and SQLite through `sqflite`.

The flow is intentionally simple:

1. Open the app
2. Choose a task
3. Enter or capture details
4. Confirm
5. Save locally

The project is suited for resume/demo use because the full app can run without a backend.

---

## What This App Is

This app is:

- a local visitor registration tool
- a mobile check-in and check-out log
- a staff directory and host selector
- a photo-assisted enrollment flow
- an Android-first Flutter project
- a resume-friendly offline demo

It uses real device capabilities:

- camera
- gallery access
- speech-to-text
- notifications
- local database

---

## What It Is Not

This app is not:

- a Firebase app
- a cloud sync app
- a multi-device shared system
- a server-backed SaaS
- a web-first product

It does not require:

- authentication server
- cloud database
- remote API keys
- internet-based login

---

## Core Tasks

### 1. Enroll Visitor

The enrollment path collects a visitor identity and stores it locally.

Typical steps:

1. Enter name
2. Enter phone number
3. Capture or pick a photo
4. Optionally add company details
5. Confirm
6. Save to local database

### 2. Check In

The check-in path verifies a visitor and records arrival.

Typical steps:

1. Enter or speak a number
2. Search the local visitor table
3. Select host and location
4. Confirm
5. Save entry-in rows locally

### 3. Check Out

The check-out path closes an active visit.

Typical steps:

1. Search an existing checked-in visitor
2. Review current local record
3. Confirm check-out
4. Store the log-out data locally

### 4. Manage Members

The members view shows:

- enrolled visitors
- staff records
- host list
- searchable local entries

### 5. Add Staff

Staff are also stored locally and can be used as host options in later visits.

---

## Screen Map

| Screen           | File                       | Purpose                         |
| ---------------- | -------------------------- | ------------------------------- |
| Home             | `lib/main.dart`            | Entry point and main navigation |
| Name             | `lib/name.dart`            | Capture visitor name            |
| Mobile           | `lib/mobile.dart`          | Capture visitor phone number    |
| Photo            | `lib/photo.dart`           | Capture or choose photo         |
| Extended Details | `lib/extendeddetails.dart` | Optional company details        |
| Details Confirm  | `lib/detailconfirm.dart`   | Final enrollment confirmation   |
| In               | `lib/in.dart`              | Start the check-in search flow  |
| In Confirm       | `lib/inconfirm.dart`       | Confirm arrival and save visit  |
| Out              | `lib/out.dart`             | Start the check-out search flow |
| Members          | `lib/members.dart`         | View visitors and staff         |
| Add Staff        | `lib/addstaff.dart`        | Create staff records            |

---

## Features

### Local Persistence

- Uses `SharedPreferences` for step state and form memory
- Uses `sqflite` for tables and visit history
- Keeps data in app-private storage

### Enrollment Flow

- Name capture
- Phone capture
- Photo capture
- Company detail capture
- Confirmation screen
- Local insert

### Search and Lookup

- Search by number or ID
- Populate visitor lists from SQLite
- Use local records to validate log-in and log-out

### Photo Handling

- Camera capture
- Gallery selection
- Face detection
- Automatic crop around detected face
- Fallback square crop if no face is found

### Speech Input

- Speech-to-text support for fields
- Numeric sanitization for phone input
- Name and company text capitalization

### Notifications

- Local notifications on creation events
- Android notification channels through plugin support

### UI Style

- Material-based Flutter layout
- Bright gradient backgrounds
- Large buttons
- Simple touch-friendly navigation

---

## Tech Stack

| Layer          | Package / Tech                           |
| -------------- | ---------------------------------------- |
| Framework      | Flutter                                  |
| Language       | Dart                                     |
| Storage        | `sqflite`, `SharedPreferences`           |
| Photos         | `image_picker`, `image_cropper`, `image` |
| Face Detection | `google_mlkit_face_detection`            |
| Speech         | `speech_to_text`                         |
| Notifications  | `flutter_local_notifications`            |
| Paths          | `path`, `path_provider`                  |
| Formatting     | `intl`                                   |
| Background     | `workmanager`                            |
| Utility        | `http`                                   |

---

## Getting Started

### Prerequisites

- Flutter SDK
- Android SDK
- Android device or emulator
- Camera permission
- Microphone permission if speech input is used

### Installation

```bash
flutter pub get
```

### Run

```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Clean

```bash
flutter clean
```

---

## Project Structure

```text
lib/
├── main.dart
├── name.dart
├── mobile.dart
├── photo.dart
├── extendeddetails.dart
├── detailconfirm.dart
├── in.dart
├── inconfirm.dart
├── out.dart
├── members.dart
└── addstaff.dart
```

### High-Level File Roles

- `main.dart` bootstraps the app and clears temporary form state
- `name.dart` captures visitor name
- `mobile.dart` captures visitor number
- `photo.dart` handles image capture and face crop
- `extendeddetails.dart` stores company info
- `detailconfirm.dart` finalizes enrollment and inserts into SQLite
- `in.dart` searches enrolled visitors for check-in
- `inconfirm.dart` records host/location and saves entry history
- `out.dart` searches active visitors for check-out
- `members.dart` lists visitors and staff
- `addstaff.dart` enrolls staff members and persists them locally

---

## Shared Storage

The app uses `SharedPreferences` as a lightweight local memory layer between screens.

### Keys Used

| Key              | Purpose                                        |
| ---------------- | ---------------------------------------------- |
| `name`           | Stores visitor name during enrollment          |
| `number`         | Stores visitor phone number                    |
| `imagePath`      | Stores captured image path                     |
| `extended`       | Marks whether extra company details were added |
| `companyName`    | Stores company name                            |
| `companyAddress` | Stores company address                         |
| `steps`          | Stores the enrollment step list                |

### Why It Matters

This prevents the app from losing the partially completed form when navigating across screens.

---

## Local Database

The code uses SQLite through `sqflite` and stores everything locally under a single database file.

### Database File

- `database.db`

### Tables Observed in Code

| Table         | Role                                    |
| ------------- | --------------------------------------- |
| `users`       | Main visitor enrollments                |
| `entries_in`  | Active or recent check-in records       |
| `entries_out` | Active or recent check-out marker table |
| `users_in`    | Historical check-in log                 |
| `users_out`   | Historical check-out log                |
| `staff`       | Staff records for host selection        |
| `location`    | Local list of meeting locations         |

### General Storage Pattern

The code uses a mixed pattern:

- create table if it does not exist
- query for existence
- insert or replace row data
- delete from the opposite state table when needed

This keeps the app self-contained and usable without a backend.

---

## File-by-File Guide

### main.dart

Purpose:

- app bootstrap
- home screen
- navigation hub
- temporary state reset on launch

Key behavior:

- clears enrollment keys from `SharedPreferences`
- resets the `steps` list to `["1", "2", "3"]`
- exposes buttons for In, Out, Enroll, and Members

Main widgets:

- `MyApp`
- `HomePage`

### name.dart

Purpose:

- capture visitor name
- store name locally
- support speech-to-text input

Key behavior:

- loads previous `name` from `SharedPreferences`
- loads `steps` from `SharedPreferences`
- capitalizes recognized speech
- keeps text cursor at the end of the field

Main widgets:

- `Name`

### mobile.dart

Purpose:

- capture visitor phone number
- support numeric speech entry

Key behavior:

- loads saved number from `SharedPreferences`
- sanitizes speech result to digits only
- stores the number locally
- continues the enrollment step flow

Main widgets:

- `Mobile`

### photo.dart

Purpose:

- capture a photo from camera or gallery
- detect a face
- crop around the face
- store image path locally

Key behavior:

- loads saved image path
- opens camera automatically if no photo exists
- uses ML Kit face detection
- falls back to cropper if no face is found

Main widgets:

- `Photo`

### extendeddetails.dart

Purpose:

- capture company name
- capture company address
- store additional enrollment details

Key behavior:

- loads image, name, and number from `SharedPreferences`
- saves `companyName`
- saves `companyAddress`
- marks the `extended` flag

Main widgets:

- `ExtendedDetails`

### detailconfirm.dart

Purpose:

- show final visitor preview
- save the new visitor into SQLite
- guard against duplicate visitor IDs

Key behavior:

- checks whether `users` table exists
- inserts visitor data into `users`
- shows local notification after creation
- reports duplicate visitor attempts with a snack bar

Main widgets:

- `DetailsConfirm`

### in.dart

Purpose:

- search enrolled visitors for check-in
- prepare the visitor for entry confirmation

Key behavior:

- loads `users`
- uses speech-to-text for number input
- keeps a 15-item recent list
- routes to `InConfirm`

Main widgets:

- `In`

### inconfirm.dart

Purpose:

- confirm host and location
- persist check-in data

Key behavior:

- loads staff list from `staff`
- loads location list from `location`
- inserts into `entries_in`
- inserts into `users_in`
- removes matching items from `entries_out`

Main widgets:

- `InConfirm`

### out.dart

Purpose:

- search active visitors for check-out
- save the checkout log locally

Key behavior:

- loads `entries_in`
- converts stored timestamps into human-readable form
- writes `entries_out`
- deletes matching `entries_in`
- writes `users_out`

Main widgets:

- `Out`

### members.dart

Purpose:

- display visitor and staff records
- search by number or host

Key behavior:

- loads staff data
- loads user data
- keeps separate visitor and staff lists
- supports number-based lookup

Main widgets:

- `Members`

### addstaff.dart

Purpose:

- enroll staff members
- store staff records locally
- provide host options for check-in

Key behavior:

- checks for duplicate staff IDs
- stores `id`, `number`, `experience`, `position`, `url`
- shows a local notification on success

Main widgets:

- `AddStaff`

---

## Screen Reference

### Home Screen

The home screen is the entry point.

Buttons:

- In
- Out
- Enroll
- Members

Behavior:

- resets temporary form state
- displays the main gradient UI
- routes to feature screens

### Name Screen

Purpose:

- capture the visitor's name

Inputs:

- manual text
- speech-to-text

Outputs:

- saves `name` into `SharedPreferences`

### Mobile Screen

Purpose:

- capture the visitor's phone number

Inputs:

- manual digits
- speech input

Outputs:

- saves `number` into `SharedPreferences`

### Photo Screen

Purpose:

- attach a profile image

Inputs:

- camera
- gallery

Outputs:

- saves `imagePath` into `SharedPreferences`

### Extended Details Screen

Purpose:

- record company information

Inputs:

- company name
- company address

Outputs:

- saves `companyName`
- saves `companyAddress`
- sets `extended = true`

### Confirm Screen

Purpose:

- preview and persist final enrollment

Outputs:

- inserts a new `users` row
- shows local notification

### In Screen

Purpose:

- find an enrolled visitor for check-in

Inputs:

- visitor number

Outputs:

- opens InConfirm for a valid record

### InConfirm Screen

Purpose:

- choose host and location
- record check-in

Outputs:

- inserts into `entries_in`
- inserts into `users_in`

### Out Screen

Purpose:

- find an active visitor for check-out

Inputs:

- visitor number

Outputs:

- writes to `entries_out`
- writes to `users_out`
- deletes from `entries_in`

### Members Screen

Purpose:

- browse stored people

Outputs:

- shows visitors
- shows staff

### Add Staff Screen

Purpose:

- create staff records

Outputs:

- writes to `staff`
- updates host list for check-in

---

## Data Flow

### Enrollment Flow

1. Home screen
2. Name screen
3. Mobile screen
4. Photo screen
5. Extended details screen
6. Confirm screen
7. SQLite insert

### Check-In Flow

1. Home screen
2. In screen
3. Search user
4. InConfirm screen
5. Select host
6. Select location
7. Insert visit rows

### Check-Out Flow

1. Home screen
2. Out screen
3. Search active visitor
4. Confirm checkout
5. Save out log
6. Remove active in-row

### Staff Flow

1. Home screen
2. Members screen
3. Add staff screen
4. Insert staff row
5. Use staff as host on later check-ins

---

## Photo Pipeline

The photo workflow is one of the most important parts of the app.

### Capture Path

1. User opens Photo screen
2. App loads the saved image path if one exists
3. If no image exists, the camera opens
4. User captures a new image
5. The app runs ML Kit face detection
6. If a face is found, the crop focuses on the face area
7. If no face is found, the image cropper is used
8. The final image path is stored locally

### Why This Exists

The app is intended for a log-style enrollment flow, so an image helps identify the visitor record later.

### Packages Used

- `image_picker`
- `image_cropper`
- `google_mlkit_face_detection`
- `image`

### Output

The app stores only the local file path, not a remote URL.

---

## Speech Input Flow

Speech input appears throughout the app.

### Used In

- `name.dart`
- `mobile.dart`
- `extendeddetails.dart`
- `addstaff.dart`
- `in.dart`
- `out.dart`
- `members.dart`

### General Pattern

1. Initialize `SpeechToText`
2. Start listening
3. Receive `SpeechRecognitionResult`
4. Sanitize or capitalize text
5. Update the controller
6. Stop listening when complete

### Numeric Sanitization

For phone numbers, the result is filtered to digits only.

### Text Capitalization

For names and addresses, the result is normalized to title-like capitalization.

---

## Notifications

The app uses local notifications in two places:

### Visitor Enrollment

When a user is created, the app shows a success notification.

### Staff Creation

When staff are added, the app shows a success notification.

### Why Local Notifications

They make the app feel more complete without needing any backend service.

### Important Note

These notifications are local device actions, not cloud pushes.

---

## Permissions

The app may require:

| Permission              | Why                        |
| ----------------------- | -------------------------- |
| Camera                  | Photo capture              |
| Microphone              | Speech-to-text             |
| Storage or media access | Image saving and selection |
| Notifications           | Local alerts               |

Because the app is Android-first and uses device features directly, permission grants matter for the full workflow.

---

## Offline Behavior

This project can run offline because:

- all key records are stored locally
- there is no Firebase dependency
- there is no remote auth flow
- there is no required network sync

### Offline-Friendly Surfaces

- enrollment
- search
- staff management
- history logging
- photo storage
- shared state

### Device Services That May Still Matter

Some features depend on the device itself:

- speech recognition service
- camera app
- gallery access

These are device services, not app backend services.

---

## Known Limitations

- Android-focused project
- no cloud backup
- no device-to-device sync
- speech input depends on device support
- image and camera behavior depends on permissions
- database schema is implemented in screens rather than a single helper
- some screens create tables on demand

---

## Troubleshooting

### App starts blank

- check `SharedPreferences` state
- ensure image and text keys were saved properly
- restart the app

### Name is not retained

- verify `name` key in `SharedPreferences`
- ensure the name screen completed successfully

### Photo does not show

- verify camera permission
- verify file path still exists
- check whether the image was saved from camera or gallery

### Check-in says no user found

- verify the visitor was enrolled first
- confirm the phone number matches the saved record
- check the `users` table

### Check-out does not remove active entry

- confirm the `entries_in` record exists
- verify the selected ID is correct
- check that the local database is not stale

### Staff does not appear in host list

- confirm the row exists in `staff`
- verify the ID field is not blank
- restart the Members screen

### Speech input fails

- grant microphone permission
- ensure device speech services are available
- use manual entry if needed

### Local notification does not appear

- grant notification permission
- check Android notification settings

---

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

If you extend this project, keep the local-first approach intact.

---

## Roadmap

Suggested next improvements:

- central database helper
- schema migration helper
- export/import backup
- better validation
- cleaner screen routing
- stronger search matching

---

## License

This project is open source and available under the [MIT License](LICENSE).

---

## Summary

Synergy Visitor Log is already capable of running offline as a local Flutter app.

The current codebase uses:

- local storage
- local database tables
- local image capture
- local speech input
- local notifications

No Firebase configuration is required for the present implementation.

---

Made with ❤️ by [Tanishq Mudaliar](https://github.com/tanishqmudaliar)

**Stop chasing paperwork — log visitors offline, effortlessly. 📋**
