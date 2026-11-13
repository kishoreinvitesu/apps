# Muggu Studio

Flutter Android app for discovering, learning and creating Muggu and Kolam
designs. The product and release requirements are documented in
[Muggu_Studio_README.md](Muggu_Studio_README.md).

Development progress, setup notes, issues and fixes are tracked in
[DEVELOPMENT_README.md](DEVELOPMENT_README.md).

## Sprint 1

The foundation includes:

- Material 3 theme using the documented Muggu Studio palette.
- English, Telugu and Tamil localization.
- Language selection saved on the device.
- Home, Explore, Create and Saved navigation.
- Muggu Studio Android app label, launcher icon and warm-cream launch screen.
- Placeholder states for features planned in later sprints.

The Android application ID currently uses the setup placeholder
`com.example.muggu_studio`. Choose the permanent publisher ID before release.

## Run

With the Android emulator running or a device connected:

```powershell
flutter pub get
flutter run
```

Validate the project with:

```powershell
dart format .
flutter analyze
flutter test
```
