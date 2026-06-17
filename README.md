# ZenithTimer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# Zenith Timer ⏳✨

A beautifully crafted, frameless desktop focus timer designed for ultimate productivity. Zenith Timer blends a signature dark-neon Glassmorphism aesthetic with powerful local data management, ensuring your focus sessions are both effective and visually stunning.

## ✨ Key Features

* **Dual Desktop Modes**: Switch between a compact, always-on-top **Floating Widget** for quick glances, or double-click to transform the timer into a massive, borderless **Ambient Wallpaper** (Rainmeter style).
* **Smart Window Management**: Frameless design, custom drag-to-move areas, and native Windows state synchronization.
* **Session Journaling**: Log your focus sessions with custom titles and notes right after completion. 
* **Optimistic UI**: Lightning-fast UI responses for editing and deleting past sessions without waiting for database operations.
* **Privacy First**: 100% offline. All your journal entries and statistics are stored securely on your local machine.

## 🛠️ Tech Stack

* **Framework**: [Flutter](https://flutter.dev/) (Windows Desktop)
* **State Management**: [Riverpod](https://riverpod.dev/)
* **Local Database**: [Isar Database](https://isar.dev/) (NoSQL, lightning-fast)
* **System Integration**: `window_manager` for native desktop controls

## 🚀 Getting Started

Follow these steps to run the application on your local machine:

### Prerequisites
* Flutter SDK (configured for Windows Desktop)
* Visual Studio with C++ workload (for Windows compilation)

### Installation

**Clone the repository:**
   ```bash
   git clone [https://github.com/Suyumm/zenith-timer.git](https://github.com/Suyumm/zenith-timer.git)
   ```
**1-Navigate to the project directory and fetch dependencies:**

   ```bash
   cd zenith-timer
   flutter pub get
   ```
**2-CRITICAL STEP - Generate Isar Schema:**
Since Isar requires auto-generated .g.dart files for the database schema, you must run the build runner before launching the app, otherwise it will crash.

```bash 
dart run build_runner build --delete-conflicting-outputs
```

**3-Run the application:**

```bash 
flutter run -d windows
```

🎨 Design Philosophy
Zenith Timer steps away from traditional, bulky desktop applications. By utilizing a transparent scaffold and the window_manager package, the app seamlessly blends into your desktop wallpaper, creating a distraction-free, "Glassmorphism" environment.

Crafted with precision by Suyumm
