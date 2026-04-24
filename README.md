# generate_assets

[English](README.md) | [中文](README.zh.md)

A Dart CLI tool to generate asset constants from your Flutter project's `pubspec.yaml`, with unused asset detection and batch deletion.

> Also available as a **VSCode Extension**: [flutter_generate_assets](https://github.com/ceeyang/flutter_generate_assets) — provides the same functionality with a GUI, status bar, and hover preview.

## Installation

Add to `dev_dependencies` in your Flutter project:

```yaml
dev_dependencies:
  generate_assets: ^0.2.0
```

Then run:

```bash
dart pub get
```

## Commands

```bash
# Generate lib/generated/assets.dart (or configured output path)
dart run generate_assets

# List unused assets by scanning lib/*.dart
dart run generate_assets find-unused

# Interactively delete unused assets (including 2x/3x variants)
dart run generate_assets delete-unused
```

## Configuration

Add a `flutter_generate_assets` section to the **root** of your `pubspec.yaml`:

```yaml
flutter_generate_assets:
  output: lib/common/assets.dart   # default: lib/generated/assets.dart
  class_name: Assets               # default: Assets

flutter:
  assets:
    - assets/images/
    - assets/icons/
```

## Generated Output

```dart
// GENERATED CODE — DO NOT MODIFY BY HAND
// ─────────────────────────────────────────────────────────────
//  Flutter Generate Assets
//  VSCode  https://github.com/ceeyang/flutter_generate_assets
//  CLI     https://github.com/ceeyang/generate_assets
// ─────────────────────────────────────────────────────────────
// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names
// dart format off

class Assets {
  static const String imagesLogo = 'assets/images/logo.png';
  static const String imagesBgHome = 'assets/images/bg_home.jpg';
  static const String iconsArrowLeft = 'assets/icons/arrow-left.svg';
}
```

When two files share the same name but different extensions, the extension is appended automatically:

```dart
static const String copyToClipboardPng = 'assets/copy_to_clipboard.png';
static const String copyToClipboardSvg = 'assets/copy_to_clipboard.svg';
```

## Naming Rules

- Path segments, `_`, `-`, `.`, and spaces are all treated as word separators
- Output is **lowerCamelCase** including directory segments (`assets/icons/arrow_left.svg` → `iconsArrowLeft`)
- Resolution variant directories (`2x`, `3x`, `1.5x`) are ignored during scanning
- `.DS_Store` and hidden files are ignored
- Duplicate paths are deduplicated automatically

## Unused Asset Detection

`find-unused` scans every `.dart` file under `lib/` (excluding the generated file) and checks for:

1. String literal usage — `'assets/icons/logo.svg'`
2. Constant reference — `Assets.iconsLogo`

> **Note:** String interpolation (`'assets/$name.png'`) cannot be statically detected and may be reported as unused.

`delete-unused` shows a confirmation prompt listing all files to be deleted, including resolution variants (`2x/3x`), before making any changes.

## Requirements

- Dart SDK >= 3.0.0
- A Flutter project with `pubspec.yaml` at the working directory root

## License

MIT
