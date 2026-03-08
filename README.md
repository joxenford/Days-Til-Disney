# DaysTilDisney

A mobile app that transforms the wait before a Disney trip into part of the magic. Families create countdowns to their park visits and build anticipation through beautiful park theming, daily Disney tips, and planning tools.

Available on iOS and Android.

---

## Project Structure

```
DaysTilDisney/
  ios/                        # iOS app (SwiftUI, Swift)
    DaysTilDisney/
      App/                    # App entry point, dependency injection setup
      Features/               # Feature modules (Home, TripDetail, AddTrip, Settings)
      Models/                 # Data models and enums
      Repositories/           # Data layer (TripRepository, ContentRepository)
      Services/               # Business logic (ContentEngine, MilestoneManager, ThemeEngine)
      Theme/                  # ParkTheme system, color palettes, asset references
      Persistence/            # SwiftData stack and local storage
      Resources/              # Assets.xcassets, Localizable.strings
    DaysTilDisneyTests/       # Unit tests
    DaysTilDisneyUITests/     # UI tests

  android/                    # Android app (Jetpack Compose, Kotlin)
    app/
      src/
        main/
          kotlin/
            com/daystildisney/
              ui/             # Composable screens and components
              viewmodel/      # ViewModels per feature
              model/          # Data models and enums
              repository/     # Data layer (TripRepository, ContentRepository)
              service/        # Business logic (ContentEngine, MilestoneManager, ThemeEngine)
              theme/          # Compose theme, color palettes
              data/           # Room database, DAOs, DataStore
        test/                 # Unit tests
        androidTest/          # Instrumented tests

  shared/                     # Platform-agnostic assets and documentation
    content/
      daily_content.json      # Curated content library (fun facts, tips, trivia, ride spotlights)
    design/
      color-palettes.md       # Color palette definitions for all 6 Disney resorts

  PRODUCT_BRIEF.md            # Full product requirements and design decisions
  README.md                   # This file
```

---

## Supported Disney Destinations

| Resort | Parks |
|--------|-------|
| Walt Disney World | Magic Kingdom, EPCOT, Hollywood Studios, Animal Kingdom |
| Disneyland Resort | Disneyland, Disney California Adventure |
| Tokyo Disney Resort | Tokyo Disneyland, Tokyo DisneySea |
| Disneyland Paris | Disneyland Park, Walt Disney Studios Park |
| Hong Kong Disneyland | Hong Kong Disneyland Park |
| Shanghai Disneyland | Shanghai Disneyland Park |

---

## Architecture

Both platforms follow **MVVM** with a clean separation of concerns:

- **Views** observe state from ViewModels and handle user input
- **ViewModels** expose immutable state streams and handle UI logic
- **Repositories** abstract data access (local storage today, cloud-ready tomorrow)
- **Services** encapsulate domain logic (ContentEngine, MilestoneManager, ThemeEngine)

The app is fully offline-capable for MVP — no account or network required.

---

## Prerequisites

### iOS

| Tool | Minimum Version |
|------|----------------|
| Xcode | 15.0+ |
| iOS Deployment Target | 17.0+ |
| Swift | 5.9+ |
| macOS (for development) | Sonoma 14.0+ |

### Android

| Tool | Minimum Version |
|------|----------------|
| Android Studio | Hedgehog (2023.1.1)+ |
| Kotlin | 1.9.0+ |
| Android Gradle Plugin | 8.2.0+ |
| Min SDK | 26 (Android 8.0) |
| Target SDK | 35 (Android 15) |
| Java | 17+ |

---

## Getting Started

### iOS

1. Open Xcode and navigate to `ios/DaysTilDisney/`.
2. Open `DaysTilDisney.xcodeproj` (or `.xcworkspace` if CocoaPods/SPM workspace is present).
3. Select your target device or simulator (iPhone running iOS 17+).
4. Press `Cmd+R` to build and run.
5. Run unit tests with `Cmd+U`.

No additional configuration or API keys are required for MVP — all content is bundled locally.

### Android

1. Open Android Studio and select **Open an Existing Project**.
2. Navigate to `android/` and open the project.
3. Wait for Gradle sync to complete.
4. Select a device or emulator running Android 8.0 (API 26)+.
5. Click **Run** or press `Shift+F10`.
6. Run unit tests via **Run > Run Tests in 'app'** or `Ctrl+Shift+F10`.

No `local.properties` API keys are required for MVP.

---

## Content Library

The daily content shown to users is defined in `shared/content/daily_content.json`. Each entry includes:

- `id` — unique string identifier
- `type` — one of `fun_fact`, `planning_tip`, `trivia`, `ride_spotlight`
- `title` — short display title
- `body` — full content text
- `parkFilter` — array of park enum values this content applies to, or `null` for all parks
- `daysOutRange` — object with `min`/`max` days before trip start, or `null` for any time

This file is bundled into both apps at build time and parsed by the `ContentEngine` service on each platform.

---

## Design System

Color palettes for all 6 Disney resorts are documented in `shared/design/color-palettes.md`, including primary, secondary, accent, gradient, and text colors. These values are the source of truth — any updates should be made there first, then propagated to the platform-specific theme implementations.

---

## Contributing

This is a greenfield project under active development. See `PRODUCT_BRIEF.md` for the full product vision, MVP feature scope, data models, and architectural guidelines before making changes.
