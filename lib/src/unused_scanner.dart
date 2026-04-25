import 'dart:io';
import 'package:path/path.dart' as p;

final _resolutionDirRe = RegExp(r'^\d+(?:\.\d+)?x$');

/// An asset constant that is not referenced anywhere in `lib/`.
class UnusedEntry {
  /// The original asset path (e.g. `assets/images/logo.png`).
  final String assetPath;

  /// The generated Dart variable name (e.g. `imagesLogo`).
  final String varName;

  /// Zero-based line number in the generated file where this constant appears.
  final int line;

  /// Creates an [UnusedEntry].
  const UnusedEntry({
    required this.assetPath,
    required this.varName,
    required this.line,
  });
}

/// Scans `lib/` Dart files and returns constants in [generatedFilePath] that
/// are not referenced by string literal or `ClassName.varName` access.
List<UnusedEntry> findUnused(
  String workspaceRoot,
  String className,
  String generatedFilePath,
) {
  final genFile = File(generatedFilePath);
  if (!genFile.existsSync()) return [];

  final genLines = genFile.readAsLinesSync();
  final lineRe = RegExp(r"^\s*static const String (\w+) = '([^']+)';");
  final entries = <UnusedEntry>[];

  for (var i = 0; i < genLines.length; i++) {
    final m = lineRe.firstMatch(genLines[i]);
    if (m != null) {
      entries.add(UnusedEntry(
        varName: m.group(1)!,
        assetPath: m.group(2)!,
        line: i,
      ));
    }
  }

  if (entries.isEmpty) return [];

  final libDir = Directory(p.join(workspaceRoot, 'lib'));
  final dartFiles = _collectDart(libDir, generatedFilePath);
  final allContents = dartFiles.map((f) {
    try {
      return File(f).readAsStringSync();
    } catch (_) {
      return '';
    }
  }).join('\n');

  return entries.where((e) {
    final literalUsed = allContents.contains("'${e.assetPath}'") ||
        allContents.contains('"${e.assetPath}"');
    final constUsed = allContents.contains('$className.${e.varName}');
    return !literalUsed && !constUsed;
  }).toList();
}

/// Returns sibling resolution-variant paths (`2x/`, `3x/`) for [assetPath].
List<String> findResolutionVariants(
    String workspaceRoot, String assetPath) {
  final absAsset = p.join(workspaceRoot, assetPath);
  final parentDir = Directory(p.dirname(absAsset));
  final filename = p.basename(absAsset);
  final variants = <String>[];

  try {
    for (final entry in parentDir.listSync()) {
      final name = p.basename(entry.path);
      if (entry is Directory && _resolutionDirRe.hasMatch(name)) {
        final candidate = p.join(entry.path, filename);
        if (File(candidate).existsSync()) {
          variants.add(
            p.relative(candidate, from: workspaceRoot).replaceAll('\\', '/'),
          );
        }
      }
    }
  } catch (_) {}

  return variants;
}

List<String> _collectDart(Directory dir, String excludePath) {
  final results = <String>[];
  if (!dir.existsSync()) return results;
  try {
    for (final entry in dir.listSync(recursive: true)) {
      if (entry is File &&
          entry.path.endsWith('.dart') &&
          p.canonicalize(entry.path) != p.canonicalize(excludePath)) {
        results.add(entry.path);
      }
    }
  } catch (_) {}
  return results;
}
