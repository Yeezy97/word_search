// dart run tool/extract_arabic_nouns.dart

import 'dart:io';

void main() async {
  final sqlFile   = File('alwassit.sql');
  final outputCsv = File('assets/data/my_arabic_nouns.csv');

  if (!await sqlFile.exists()) {
    print('ERROR: alwassit.sql not found in project root.');
    return;
  }

  final contents = await sqlFile.readAsString();

  // This regex finds each tuple beginning "(..., 'اسم', 'lemma', 'definition', ...)"
  final rowRegexp = RegExp(
    r"\(\s*[^,]+?\s*,\s*'اسم'\s*,\s*'((?:[^']|''?)*)'\s*,\s*'((?:[^']|''?)*)'",
    multiLine: true,
  );

  final matches = rowRegexp.allMatches(contents);
  print('Found ${matches.length} noun entries…');

  // Ensure our output directory exists
  await outputCsv.parent.create(recursive: true);

  final sink = outputCsv.openWrite();
  sink.writeln('lemma,definition'); // header row

  for (final m in matches) {
    // SQL uses '' to escape a single quote
    final rawLemma = m.group(1)!.replaceAll("''", "'");
    final rawDef   = m.group(2)!.replaceAll("''", "'");
    // wrap in quotes and escape any internal quotes
    final lemma    = '"${rawLemma.replaceAll('"', '""')}"';
    final definition = '"${rawDef.replaceAll('"', '""')}"';
    sink.writeln('$lemma,$definition');
  }

  await sink.close();
  print('Wrote ${matches.length} rows → ${outputCsv.path}');
}
