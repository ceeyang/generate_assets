import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

class PubspecConfig {
  final String output;
  final String className;
  final List<String> assetPaths;
  final List<String> stripPrefixes;

  const PubspecConfig({
    required this.output,
    required this.className,
    required this.assetPaths,
    required this.stripPrefixes,
  });
}

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
