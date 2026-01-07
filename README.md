# FitnessX — Learning-backed Flutter project

This project was scaffolded with `flutter create` and then updated to follow the topics learned:

- Project structure: `lib/models`, `lib/data`, `lib/ui`.
- Simple data model in `lib/models` and a sample data service.
- Responsive UI using `LayoutBuilder` and `SafeArea`.
- Three rounded square boxes centered on an orange background.
- Tap boxes to navigate to `Workouts` and `Profile` pages.
- Bottom navigation bar with three tabs.
- Basic widget test updated to validate navigation.

Run the app:

```bash
cd "my_flutter_app"
flutter run
```

If you run on Web (Chrome):

- Saved data is stored per `localhost` *port*.
- If Flutter picks a different port next time, it can look like the app "forgot" your saved data.

Also: when you use `flutter run -d chrome`, Flutter may launch a temporary Chrome profile. If you close that Chrome window and re-run, the temporary profile can be new, so saved data looks reset.

Use a fixed port so it always remembers:

```bash
flutter run -d chrome --web-port 5050
```

If it still resets, force a persistent Chrome profile directory:

```bash
flutter run -d chrome --web-port 5050 --web-browser-flag=--user-data-dir="$PWD/.chrome_profile"
```

Important: quit Chrome completely (Cmd+Q) before running this command. If Chrome is already running, it may ignore `--user-data-dir`.

Most reliable option (recommended): run as a web server and open it in your normal Chrome (persistent profile):

```bash
flutter run -d web-server --web-port 5050
```

Then open:

- http://localhost:5000
- http://localhost:5050

Run tests:

```bash
flutter test
```
# my_flutter_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# FinalProject
