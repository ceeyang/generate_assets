import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Configuration read from the `flutter_generate_assets` key in pubspec.yaml.
class PubspecConfig {
  /// Output path for the generated Dart file, relative to the project root.
  final String output;

  /// Name of the generated Dart class (e.g. `Assets`).
  final String className;

  /// Asset paths declared under `flutter.assets` in pubspec.yaml.
  final List<String> assetPaths;

  /// Prefixes to strip from asset paths before generating variable names.
  final List<String> stripPrefixes;

  /// Creates a [PubspecConfig] with the given values.
  const PubspecConfig({
    required this.output,
    required this.className,
    required this.assetPaths,
    required this.stripPrefixes,
  });
}

/// Reads the `flutter_generate_assets` configuration from [workspaceRoot]/pubspec.yaml.
PubspecConfig readPubspec(String workspaceRoot) {
  final file = File(p.join(workspaceRoot, 'pubspec.yaml'));
  final doc = loadYaml(file.readAsStringSync()) as Map;

  final cfg = (doc['flutter_generate_assets'] as Map?) ?? {};
  final flutter = (doc['flutter'] as Map?) ?? {};
  final rawAssets = flutter['assets'];
  final rawStrip = cfg['strip_prefix'];

  List<String> stripPrefixes;
  if (rawStrip is List) {
    stripPrefixes = rawStrip.map((e) => e.toString()).toList();
  } else if (rawStrip is String) {
    stripPrefixes = [rawStrip];
  } else {
    stripPrefixes = ['assets/'];
  }

  return PubspecConfig(
    output: cfg['output'] as String? ?? 'lib/generated/assets.dart',
    className: cfg['class_name'] as String? ?? 'Assets',
    assetPaths: rawAssets is List
        ? rawAssets.map((e) => e.toString()).toList()
        : [],
    stripPrefixes: stripPrefixes,
  );
}
