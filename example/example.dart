// ignore_for_file: avoid_print
import 'dart:io';

import 'package:generate_assets/src/asset_scanner.dart';
import 'package:generate_assets/src/code_generator.dart';
import 'package:generate_assets/src/pubspec_reader.dart';

/// Demonstrates reading pubspec config and generating a Dart constants file.
void main() {
  final root = Directory.current.path;

  // Read flutter_generate_assets config from pubspec.yaml
  final config = readPubspec(root);
  print('Output : ${config.output}');
  print('Class  : ${config.className}');
  print('Prefixes: ${config.stripPrefixes}');

  // Scan declared asset paths and generate Dart source
  final assets = scanAssets(root, config.assetPaths);
  final code = generateDartCode(
    config.className,
    assets,
    stripPrefixes: config.stripPrefixes,
  );

  print('\n--- Generated code ---\n$code');
}
