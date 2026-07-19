# FieldCheck — Verified Logs Engine 🛡️

FieldCheck is a clean, reliable Flutter application engineered to execute and manage authenticated field check-in records. By tightly combining real-time hardware telemetry with native on-device camera frames, the app ensures every data entry is anchored to a verified physical location and visual profile.

The user interface uses a clear, sequential linear list view that makes tracking and verifying logs chronological and straightforward.

---

## 🏗️ Core Architectural Modules

The platform is split into four distinct system spaces:

*   **Welcome Animation Engine:** A custom-scaled backdrop sequence managing system-wide hardware availability checks before mounting the main framework.
*   **The Linear Ledger Dashboard:** A chronological full-width card layout displaying your verification records. Items can be checked or removed easily using integrated dismissible swipe mechanics.
*   **Telemetry Acquisition Hub:** Handles async permission parsing and polling of satellite configurations to resolve `Latitude`, `Longitude`, and `Accuracy Radius` metrics down to sub-meter metrics.
*   **Hardware Lens Layer:** An inline camera preview pipeline built to circumvent raw OS capture sheets for secure, dedicated document and space isolation.

---

## 🛠️ Technical Stack & Dependencies

*   **Framework:** Flutter (Material 3 Adaptive Design)
*   **Storage Framework:** Local storage persistence via `shared_preferences` JSON string serialization.
*   **Location API:** High-accuracy real-time polling using `geolocator`.
*   **Camera Pipeline:** Low-latency image streams controlled directly via the `camera` subsystem.
*   **Permission Controller:** `permission_handler` routine for handling native hardware restrictions gracefully.

---

## 🚀 Getting Started

### Prerequisites
Ensure your local environment has the Flutter SDK correctly configured:
```bash
flutter doctor
