# syntax=docker/dockerfile:1.4
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /workspace

# Configure git and suppress Flutter analytics
RUN git config --global --add safe.directory /workspace && \
    flutter config --no-analytics

# Cache dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source tree
COPY . .

# Run static analysis
RUN flutter analyze

# Build APK (debug by default, release configurable via --build-arg BUILD_TYPE=release)
ARG BUILD_TYPE=debug
RUN if [ "$BUILD_TYPE" = "release" ]; then \
      flutter build apk --release; \
    else \
      flutter build apk --debug; \
    fi

# BuildKit local export target
FROM scratch AS export
COPY --from=builder /workspace/build/app/outputs/flutter-apk/*.apk /

# Default lightweight container holding the artifact
FROM alpine:latest AS runner
WORKDIR /app
COPY --from=builder /workspace/build/app/outputs/flutter-apk/*.apk ./
CMD ["sh", "-c", "echo 'Build successful. APKs available in /app:' && ls -la /app"]
