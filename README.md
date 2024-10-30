# Synergy Visitor Log

Synergy Visitor Log is a Flutter application designed to manage visitor logs efficiently. It integrates with Firebase for data storage and synchronization, ensuring that visitor data is always up-to-date and accessible.

## Features

- **Visitor Check-In and Check-Out**: Log visitor entries and exits.
- **Visitor Enrollment**: Enroll new visitors with their details.
- **Member Management**: Manage and view enrolled visitors.
- **Background Data Synchronization**: Sync data with Firebase in the background.
- **Local Data Storage**: Store data locally using SQLite.

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio or Visual Studio Code
- Firebase account

### Installation

1. **Clone the repository:**

   ```sh
   git clone https://github.com/tanishqmudaliar/Synergy-Visitor-Log.git
   cd Synergy-Visitor-Log

2. **Install dependencies:**

   ```sh
   flutter pub get

3. **Set up Firebase:**

   - Create a Firebase project.
   - Add an Android app to your Firebase project.
   - Download the ``google-services.json`` file and place it in the ``android/app`` directory.
   - Enable Firestore and Firebase Storage in your Firebase project.

4. **Run the app:**

   ```sh
   flutter run

### Usage

- **Enroll a new visitor:** Navigate to the Enroll page and fill in the visitor's details.
- **Check-in a visitor:** Navigate to the In page and log the visitor's entry.
- **Check-out a visitor:** Navigate to the Out page and log the visitor's exit.
- **View members:** Navigate to the Members page to see the list of enrolled visitors.

### Background Tasks

The app uses the ``workmanager`` package to perform background data synchronization with Firebase. This ensures that the local SQLite database and Firebase Firestore are always in sync.

**Background Task Implementation**
The background tasks are handled in the ``callbackDispatcher`` function, which performs the following operations:

- Initialize Firebase: Ensures Firebase is initialized.
- Sync Local Data to Firebase: Uploads local data from SQLite to Firebase Firestore and Firebase Storage.
- Sync Firebase Data to Local: Downloads data from Firebase Firestore and stores it locally in SQLite.

### Contributing
Contributions are welcome! Please fork the repository and create a pull request with your changes.

### Acknowledgements

[Flutter](https://flutter.dev/)
[Firebase](https://firebase.google.com/)
[Workmanager](https://pub.dev/packages/workmanager)
[SQFlite](https://pub.dev/packages/sqflite)
[Shared Preferences](https://pub.dev/packages/shared_preferences)
