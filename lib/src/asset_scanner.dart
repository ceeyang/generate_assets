import 'dart:io';
import 'package:path/path.dart' as p;

final _resolutionDirRe = RegExp(r'^\d+(?:\.\d+)?x$');
const _ignoredFiles = {'Thumbs.db', 'desktop.ini', 'ehthumbs.db'};

bool _isIgnored(String name) =>
    name.startsWith('.') || _ignoredFiles.contains(name);

List<String> scanAssets(String workspaceRoot, List<String> assetPaths) {
  final results = <String>{};

  for (final assetPath in assetPaths) {
    final trimmed = assetPath.trim().replaceAll(RegExp(r'/$'), '');
    if (trimmed.isEmpty) continue;

    final abs = p.join(workspaceRoot, trimmed);
    final isDir = Directory(abs).existsSync();
    final isFile = !isDir && File(abs).existsSync();

    if (isDir) {
      _collectFiles(Directory(abs), workspaceRoot, results);
    } else if (isFile && !_isIgnored(p.basename(trimmed))) {
      results.add(trimmed.replaceAll('\\', '/'));
    }
  }

  return results.toList()..sort();
}

void _collectFiles(
    Directory dir, String workspaceRoot, Set<String> results) {
  try {
    for (final entry in dir.listSync()) {
      final name = p.basename(entry.path);
      if (entry is Directory) {
        if (_resolutionDirRe.hasMatch(name)) continue;
        _collectFiles(entry, workspaceRoot, results);
      } else if (entry is File && !_isIgnored(name)) {
        final rel = p.relative(entry.path, from: workspaceRoot)
            .replaceAll('\\', '/');
        results.add(rel);
      }
    }
  } catch (_) {}
}
