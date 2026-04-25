## 0.3.1

- Shorten package description to satisfy pub.dev scoring
- Add dartdoc comments to all public API symbols
- Add `example/example.dart` to satisfy pub.dev example requirement

## 0.3.0

- Add `strip_prefix` config option in `pubspec.yaml` under `flutter_generate_assets`
- Supports single string or list of prefixes; first match wins; default `assets/`

## 0.2.0

- Unify generated file header with links to both VSCode extension and CLI tool
- Cross-link with VSCode extension in README
- Add CI/CD workflow for automatic pub.dev publishing on version tags

## 0.1.0

- Initial release
- `generate` — generate Dart asset constants from `pubspec.yaml`
- `find-unused` — scan `lib/` and list unused assets
- `delete-unused` — interactively delete unused assets including 2x/3x resolution variants
