import 'dart:io';

// matches INSERT lines with PartofSpeech = 'اسم'
final regex = RegExp(
  r"INSERT INTO `alwassit`.*?VALUES\s*\(\d+,\s*'اسم',\s*'([^']*)',\s*'([^']*)'",
  multiLine: true,
);

Future<void> main() async {
  final inFile = File('alwassit.sql');
  if (!await inFile.exists()) {
    print('alwassit not found in project root.');
    return;
  }
  final contents = await inFile.readAsString();
  final outFile = File('arabic_nouns.csv').openWrite();
  outFile.writeln('lemma,definition');

  for (final m in regex.allMatches(contents)) {
    // group(1)=lemma, group(2)=definition
    final lemma = m.group(1)!.replaceAll('"', '""');
    final def   = m.group(2)!.replaceAll('"', '""');
    outFile.writeln('"$lemma","$def"');
  }
  await outFile.close();
  print('Extracted ${regex.allMatches(contents).length} rows to arabic_nouns.csv');
}
