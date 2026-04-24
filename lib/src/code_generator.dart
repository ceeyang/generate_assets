String toVariableName(
  String filePath, {
  bool includeExt = false,
  List<String> stripPrefixes = const ['assets/'],
}) {
  // Strip the first matching prefix
  var s = filePath;
  for (final prefix in stripPrefixes) {
    if (filePath.startsWith(prefix)) {
      s = filePath.substring(prefix.length);
      break;
    }
  }

  final extMatch = RegExp(r'\.([^/.]+)$').firstMatch(s);
  final ext = extMatch?.group(1) ?? '';
  s = s.replaceAll(RegExp(r'\.[^/.]+$'), '');
  if (includeExt && ext.isNotEmpty) s = '${s}_$ext';

  final words = s
      .split(RegExp(r'[/\-_.\s]+'))
      .where((w) => w.isNotEmpty)
      .toList();

  if (words.isEmpty) return 'a';

  final camel = words.first.toLowerCase() +
      words
          .skip(1)
          .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
          .join('');

  return RegExp(r'^\d').hasMatch(camel) ? 'a$camel' : camel;
}

String generateDartCode(
  String className,
  List<String> assets, {
  List<String> stripPrefixes = const ['assets/'],
}) {
  final unique = assets.toSet().toList();

  // First pass: detect base-name collisions
  final baseCounts = <String, int>{};
  for (final path in unique) {
    final base = toVariableName(path, includeExt: false, stripPrefixes: stripPrefixes);
    baseCounts[base] = (baseCounts[base] ?? 0) + 1;
  }

  final seen = <String, int>{};
  final lines = [
    '// GENERATED CODE — DO NOT MODIFY BY HAND',
    '// ─────────────────────────────────────────────────────────────',
    '//  Flutter Generate Assets',
    '//  VSCode  https://github.com/ceeyang/flutter_generate_assets',
    '//  CLI     https://github.com/ceeyang/generate_assets',
    '// ─────────────────────────────────────────────────────────────',
    '// ignore_for_file: lines_longer_than_80_chars, constant_identifier_names',
    '// dart format off',
    '',
    'class $className {',
  ];

  for (final assetPath in unique) {
    final base = toVariableName(assetPath, includeExt: false, stripPrefixes: stripPrefixes);
    final useExt = (baseCounts[base] ?? 1) > 1;
    var varName = toVariableName(assetPath, includeExt: useExt, stripPrefixes: stripPrefixes);

    if (seen.containsKey(varName)) {
      var count = seen[varName]! + 1;
      var candidate = '$varName$count';
      while (seen.containsKey(candidate)) {
        count++;
        candidate = '$varName$count';
      }
      seen[varName] = count;
      seen[candidate] = 1;
      varName = candidate;
    } else {
      seen[varName] = 1;
    }

    lines.add("  static const String $varName = '$assetPath';");
  }

  lines.add('}');
  return '${lines.join('\n')}\n';
}
