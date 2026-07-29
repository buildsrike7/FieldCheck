# FieldCheck — Verified Logs Engine 🛡️

FieldCheck is a clean, reliable Flutter application engineered to execute and manage authenticated field check-in records. By tightly combining real-time hardware telemetry constraints with native on-device camera frames, the app ensures every data entry is anchored to a verified physical location and visual profile.

The user interface uses a clear, sequential linear list view that makes tracking and verifying logs chronological and straightforward.

---

## 📋 Project Implementation Checklist

This checklist tracks the implementation status of core app features, architectural layers, and system requirements:

| Feature / Requirement | Status | Description |
| :--- | :---: | :--- |
| **Welcome Splash Animation** | ✅ **Done** | Animated scale and fade transition screen on startup (`welcome_screen.dart`). |
| **Real-Time GPS Telemetry** | ✅ **Done** | Integrates `geolocator` to capture accurate latitude, longitude, and accuracy metrics. |
| **Secure Hardware Lens Isolation** | ✅ **Done** | Custom inline camera capture workspace (`camera_screen.dart`) avoiding OS share sheets. |
| **Persistent Linear Ledger** | ✅ **Done** | Chronological full-width card view displaying stored logs on the dashboard (`home_screen.dart`). |
| **Local Permanence Engine** | ✅ **Done** | On-device key-value storage via `shared_preferences` using JSON string serialization. |
| **Dismissible Swipe Mechanics** | ✅ **Done** | Gesture-based swipe interactions or delete options to remove tracking logs instantly. |
| **Hardware Guard Rails & Permissions** | ✅ **Done** | Runtime OS permission negotiations using `permission_handler`. |
| **Cloud Synchronization / Remote DB** | ❌ **Not Done** | Future integration for syncing local ledger records to an external backend server. |
| **Biometric Authentication Lock** | ❌ **Not Done** | Fingerprint/FaceID security gate required prior to launching the dashboard. |

---

## ✨ Features

* **Real-Time Hardware Telemetry:** Fetches precise GPS coordinates (`Latitude`, `Longitude`) and accuracy metrics automatically during check-ins.
* **Secure Hardware Lens Isolation:** Captures camera frames directly within an inline app layer or fetches media safely via the native gallery picker.
* **Persistent Linear Ledger:** Displays verification logs chronologically in a full-width card layout.
* **Dismissible Swipe Mechanics:** Provides a clean, gesture-based swipe interaction to remove tracking logs instantly.
* **Local Permanence Engine:** Saves records directly to the device using secure JSON string serialization so data survives app restarts.
* **Hardware Guard Rails:** Validates system-level location permissions and hardware availability before allowing access.

---

## 📱 Application Screens

The application flows sequentially through these core views:
1. **Welcome & System Validation Screen (`welcome_screen.dart`):** An animated backdrop sequence that verifies native device permission states and checks hardware initialization before mounting the main engine.
2. **Linear Ledger Dashboard (`home_screen.dart`):** The central hub displaying a chronological stack of verification records. Features interactive card elements and gestural swipe actions.
3. **Camera Capture Layer (`camera_screen.dart`):** A dedicated workspace containing the inline low-latency camera preview pipeline for secure snapshot captures.
4. **New Check-In Form (`new_check_in_screen.dart`):** Integrates live GPS polling, photo preview (via camera or `image_picker`), and note submission.
5. **Log Detail View (`detail_screen.dart`):** Displays comprehensive metadata, location coordinates, and full snapshots for individual records.

---

## 🔌 Plugins & Dependencies

The project relies on the following core plugins to bridge the Flutter framework with native hardware layers and media storage:

| Plugin | Version | Purpose |
| :--- | :--- | :--- |
| `geolocator` | `^13.0.1` | Handles high-accuracy asynchronous satellite polling for location coordinates. |
| `camera` | `^0.11.0` | Manages low-latency inline image streams directly from the device lens ecosystem. |
| `image_picker` | `^1.1.2` | Enables seamless photo selection from the device's local photo library/gallery. |
| `shared_preferences` | `^2.3.2` | Provides persistent on-device key-value storage via JSON string serialization. |
| `permission_handler` | `^11.3.1` | Gracefully negotiates native OS permission runtime prompts and fallback alerts. |
| `lottie` | `^3.1.0` | Renders fluid vector animation sequences for splash screens and UI feedback. |

---

## 🛠️ Technology Stack

* **Framework:** **Flutter (Material 3)** for cross-platform UI composition, responsive layout design, and smooth widget animations.
* **Language:** **Dart** (Strict null-safe architecture with asynchronous async/await streaming).
* **Location Services:** **Geolocator API** interacting directly with device hardware components to fetch high-precision coordinates, altitude, and accuracy metrics.
* **Camera & Media Integration:** **Flutter Camera Package** and **Image Picker** initializing local lenses and device storage for secure snapshot captures and media loading.
* **Local Persistence:** **SharedPreferences** coupled with JSON string serialization (`jsonEncode` / `jsonDecode`) to store ledger states locally on the device permanently.

---

## 📂 Project Structure

The codebase is organized into modular layers for clean separation of concerns:

```text
lib/
├── main.dart                 # Global app entry point, initialization, & theme setup
├── models/
│   └── check_in_record.dart    # Data model & JSON serialization logic
├── services/
│   └── storage_service.dart    # Local persistence engine using shared_preferences
└── screens/
    ├── welcome_screen.dart     # Splash animation & initialization sequence
    ├── home_screen.dart        # Main dashboard & SharedPreferences ledger stack
    ├── new_check_in_screen.dart# Check-in form (GPS acquisition & image attachment)
    ├── camera_screen.dart      # Custom inline camera capture workspace
    └── detail_screen.dart      # Single log record verification view

## 🚀 Installation & Running
Prerequisites
Before setting up the project, make sure you have the following software installed on your machine:

Flutter SDK: Version 3.x.x or higher installed.

Dart SDK: Bundled directly with Flutter.

IDE: Visual Studio Code, Android Studio, or IntelliJ IDEA with the Flutter/Dart plugins installed.

Target Device: An Android or iOS device (or an active emulator/simulator) to run the camera and GPS tasks.

Setup Sequence:
Follow these precise, step-by-step terminal commands to deploy and run the app:

1. Clone the repository:
git clone [https://github.com/buildsrike7/FieldCheck.git](https://github.com/buildsrike7/FieldCheck.git)

2. Navigate into the project folder
cd field-check

3. Install the dependencies
flutter pub get

4. Run Application
flutter run

 Testing video:
https://youtube.com/shorts/S63emsc-bOw?feature=share

