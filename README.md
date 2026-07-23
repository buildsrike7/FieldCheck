# FieldCheck — Verified Logs Engine 🛡️

FieldCheck is a clean, reliable Flutter application engineered to execute and manage authenticated field check-in records. By tightly combining real-time hardware telemetry constraints with native on-device camera frames, the app ensures every data entry is anchored to a verified physical location and visual profile.

The user interface uses a clear, sequential linear list view that makes tracking and verifying logs chronological and straightforward.

---

## ✨ Features

*   **Real-Time Hardware Telemetry:** Fetches precise GPS coordinates (`Latitude`, `Longitude`) and accuracy metrics automatically during check-ins.
*   **Secure Hardware Lens Isolation:** Captures camera frames directly within an inline app layer, avoiding raw OS share sheets to ensure data integrity.
*   **Persistent Linear Ledger:** Displays verification logs chronologically in a full-width card layout.
*   **Dismissible Swipe Mechanics:** Provides a clean, gesture-based swipe interaction to remove tracking logs instantly.
*   **Local Permanence Engine:** Saves records directly to the device using secure JSON string serialization so data survives app restarts.
*   **Hardware Guard Rails:** Validates system-level location permissions and hardware availability before allowing access.

---

## 📱 Application Screens

The application flows sequentially through these core views:
1.  **Welcome & System Validation Screen:** An animated backdrop sequence that verifies native device permission states and checks hardware initialization before mounting the main engine.
2.  **Linear Ledger Dashboard:** The central hub displaying a chronological stack of verification records. Features interactive card elements and gestural swipe actions.
3.  **Camera Capture Layer:** A dedicated workspace containing the inline low-latency camera preview pipeline for secure snapshot captures.

---

## 🔌 Plugins & Dependencies

The project relies on the following core plugins to bridge the Flutter framework with native hardware layers:

| Plugin | Purpose |
| :--- | :--- |
| `geolocator` | Handles high-accuracy asynchronous satellite polling for location coordinates. |
| `camera` | Manages low-latency inline image streams directly from the device lens ecosystem. |
| `shared_preferences` | Provides persistent on-device key-value storage via JSON string serialization. |
| `permission_handler` | Gracefully negotiates native OS permission runtime prompts and fallback alerts. |

---

## 📂 Project Structure

The codebase follows a modular structure separated by distinct architecture spaces:

```text
Structure
lib/
│
├── main.dart             # App entry point, global camera initialization, and root MaterialApp
│
├── models/
│   └── check_in_record.dart # Data model for check-in entries (toMap, fromMap)
│
└── screens/
    ├── welcome_screen.dart   # Onboarding / intro screen ("Get Started")
    ├── home_screen.dart      # Dashboard displaying saved logs, refreshing, and deletion
    ├── new_check_in_screen.dart # Screen for capturing location telemetry, photos, and notes
    ├── camera_screen.dart    # Custom camera preview wrapper using the camera package
    └── detail_screen.dart    # Detailed view of an individual check-in record and image preview
```
Prerequisites
Before setting up the project, make sure you have the following software installed on your machine:

Flutter SDK: Version 3.x.x or higher installed.

Dart SDK: Bundled directly with Flutter.

IDE: Visual Studio Code, Android Studio, or IntelliJ IDEA with the Flutter/Dart plugins installed.

Target Device: An Android or iOS device (or an active emulator/simulator) to run the camera and GPS tasks.
