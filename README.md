[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
![Dart CI](https://github.com/bobagold/minesweeper/workflows/Dart%20CI/badge.svg)
[![play-store](https://img.shields.io/badge/playstore-published-brightgreen)](https://play.google.com/store/apps/details?id=com.actvst.bobagold.minesweeper)
[![app-store](https://img.shields.io/badge/appstore-published-brightgreen)](https://apps.apple.com/de/app/meinsweeper/id1521149028)
[![itsallwidgets](https://img.shields.io/badge/itsallwidgets-published-brightgreen)](https://itsallwidgets.com/minesweeper-game)

# minesweeper

Minesweeper game.

## Screenshots
<p align="center">
    <img src="screenshots/fail_fast.png" width="200">
    <img src="screenshots/fail_late.png" width="200">
    <img src="screenshots/win_by_open.png" width="200">
</p>

## Features

* Responsive design - fits portrait, landscape, split-screen, tablet
* Tests
* Rive animations:
    * https://rive.app/community/files/11975-22809-kawaii-animals-crying/
    * https://rive.app/community/files/11976-22810-kawaii-animals-giving-love/

## Development

iOS and macOS native dependencies use Swift Package Manager. CocoaPods is not
required. Open the platform's `Runner.xcworkspace` when working in Xcode.

After fetching dependencies, prepare Rive's native library for widget tests:

```sh
flutter pub get
dart run rive_native:setup --clean --platform macos
flutter test
```

Use `--platform linux` or `--platform windows` on those hosts. Repeat the setup
after `flutter clean`, which removes the native test library from the build folder.
The setup command's `--clean` flag restores that library even when the download
was previously cached.
App builds download their required Rive libraries automatically.

## Todo

* Performance #2
* Cell widget
* Improve code style
