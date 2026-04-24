import 'dart:io';

import 'package:generate_assets/src/asset_scanner.dart';
import 'package:generate_assets/src/code_generator.dart';
import 'package:generate_assets/src/pubspec_reader.dart';
import 'package:generate_assets/src/unused_scanner.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  final command = args.isEmpty ? 'generate' : args.first;
  final root = Directory.current.path;

  switch (command) {
    case 'generate':
      _generate(root);
    case 'find-unused':
      _findUnused(root);
    case 'delete-unused':
      _deleteUnused(root);
    default:
      _printUsage();
  }
}

void _generate(String root) {
  final config = readPubspec(root);
  final assets = scanAssets(root, config.assetPaths);
  final code = generateDartCode(config.className, assets, stripPrefixes: config.stripPrefixes);

  final outPath = p.join(root, config.output);
  final outDir = Directory(p.dirname(outPath));
  if (!outDir.existsSync()) outDir.createSync(recursive: true);
  File(outPath).writeAsStringSync(code);

  print('✓ Generated ${config.output} (${assets.length} assets)');
}

void _findUnused(String root) {
  final config = readPubspec(root);
  final genPath = p.join(root, config.output);

  if (!File(genPath).existsSync()) {
    print('✗ Generated file not found. Run "generate" first.');
    exit(1);
  }

  final unused = findUnused(root, config.className, genPath);
  if (unused.isEmpty) {
    print('✓ No unused assets found');
    return;
  }

  print('⚠ Found ${unused.length} unused asset(s):');
  for (final e in unused) {
    print('  - ${e.assetPath}');
  }
}

void _deleteUnused(String root) {
  final config = readPubspec(root);
  final genPath = p.join(root, config.output);

  if (!File(genPath).existsSync()) {
    print('✗ Generated file not found. Run "generate" first.');
    exit(1);
  }

  final unused = findUnused(root, config.className, genPath);
  if (unused.isEmpty) {
    print('✓ No unused assets found');
    return;
  }

  final toDelete = <String>[];
  for (final e in unused) {
    toDelete.add(e.assetPath);
    toDelete.addAll(findResolutionVariants(root, e.assetPath));
  }

  print('The following ${toDelete.length} file(s) will be deleted:');
  for (final f in toDelete) {
    print('  $f');
  }
  stdout.write('Confirm? [y/N] ');
  final input = stdin.readLineSync()?.trim().toLowerCase();
  if (input != 'y') {
    print('Cancelled');
    return;
  }

  var deleted = 0;
  for (final rel in toDelete) {
    try {
      File(p.join(root, rel)).deleteSync();
      print('  ✓ Deleted $rel');
      deleted++;
    } catch (e) {
      print('  ✗ Failed: $rel ($e)');
    }
  }

  print('\nDeleted $deleted file(s). Run "generate" to update constants.');
}

void _printUsage() {
  print('''
Usage: dart run generate_assets <command>

Commands:
  generate        Generate Dart asset constants (default)
  find-unused     List unused assets by scanning lib/
  delete-unused   Interactively delete unused assets and their 2x/3x variants
''');
}
