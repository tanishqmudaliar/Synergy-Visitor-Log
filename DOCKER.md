# Docker Environment for Synergy Visitor Log

This directory provides containerized Docker capabilities for building, testing, and developing the Synergy Visitor Log Flutter application without requiring local Android SDK or Flutter installations.

---

## What Is Dockerized?

| Feature | Docker Support | Description |
|---|---|---|
| **Debug APK Build** | Fully Dockerized | Compiles `app-debug.apk` in an isolated container and writes to host. |
| **Release APK Build** | Fully Dockerized | Compiles `app-release.apk` with all Android optimizations. |
| **App Bundle Build** | Fully Dockerized | Compiles production `.aab` for Google Play deployment. |
| **Static Analysis** | Fully Dockerized | Executes `flutter analyze` inside the container. |
| **Unit & Widget Tests** | Fully Dockerized | Runs headless unit/widget tests via `flutter test`. |
| **CI/CD Pipelines** | Fully Dockerized | Self-contained multi-stage `Dockerfile` with BuildKit export. |
| **Dependency Caching** | Fully Dockerized | Persists Gradle and Pub dependencies via Docker volumes. |
| **Interactive Shell** | Fully Dockerized | Provides full Flutter and Android CLI inside bash container. |
| **Device Execution (`run`)** | Supported via Network ADB | Can connect to wireless devices or the host's ADB server. |

---

## Quick Start with Docker Compose

Ensure Docker Desktop / Docker Engine is running on your system.

### 1. Build Debug APK
Builds `app-debug.apk` directly into `build/app/outputs/flutter-apk/` on the host:
```bash
docker compose run --rm build-debug
```

### 2. Build Release APK
Builds `app-release.apk` directly into `build/app/outputs/flutter-apk/` on the host:
```bash
docker compose run --rm build-release
```

### 3. Build Google Play App Bundle (.aab)
Builds `app-release.aab` into `build/app/outputs/bundle/release/` on the host:
```bash
docker compose run --rm build-bundle
```

### 4. Run Static Analysis & Tests
Runs `flutter analyze` and `flutter test` inside the container:
```bash
docker compose run --rm test
```

### 5. Interactive Development Shell
Opens a Bash terminal inside the Flutter/Android container environment with the project mounted:
```bash
docker compose run --rm dev
```

Inside the shell, you can run any Flutter or Dart command:
```bash
flutter doctor
flutter analyze
flutter build apk --debug
```

---

## Connecting to Devices from Docker

To run the app on a connected physical device from inside Docker:

### Option A: Wireless ADB (Recommended)
If your Android phone is connected wirelessly on your local Wi-Fi network:
1. Open the interactive dev container:
   ```bash
   docker compose run --rm dev
   ```
2. Connect ADB over TCP:
   ```bash
   adb connect <device-ip>:<port>
   ```
3. Run the app:
   ```bash
   flutter run -d <device-ip>:<port>
   ```

### Option B: Forwarding Host ADB Server
On your Windows host, start the ADB server listening on all network interfaces:
```cmd
adb kill-server
adb -a nodaemon server start
```
Then inside the Docker container:
```bash
adb -H host.docker.internal devices
flutter run -d <device-id>
```

---

## Standalone Dockerfile Usage (CI / CD)

### Hermetic Container Build
Build an isolated container image using the multi-stage Dockerfile:
```bash
# Debug APK build
docker build -t synergyvisitorlog:debug --build-arg BUILD_TYPE=debug .

# Release APK build
docker build -t synergyvisitorlog:release --build-arg BUILD_TYPE=release .
```

### Extracting Built APK to Host via BuildKit
Compile and export the APK directly to an `output/` directory on your host without spinning up a container:
```bash
DOCKER_BUILDKIT=1 docker build --target export --output type=local,dest=./output .
```
