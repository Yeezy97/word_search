import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton wrapper around our local SQLite “words.db”,
/// auto-importing your CSV on first launch.
class WordsDatabase {
  WordsDatabase._internal();
  static final WordsDatabase instance = WordsDatabase._internal();

  Database? _database;

  /// Open (or create) the database.
  Future<Database> get database async {
    if (_database != null) return _database!;
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'words.db');
    _database = await openDatabase(
      fullPath,
      version: 1,
      onCreate: _initializeSchemaAndImportCsv,
    );
    return _database!;
  }

  /// Called once when the DB is first created.
  Future<void> _initializeSchemaAndImportCsv(Database db, int version) async {
    // 1) Create table
    await db.execute('''
      CREATE TABLE word_entries (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        lemma       TEXT NOT NULL,
        definition  TEXT NOT NULL
      );
    ''');

    // 2) Load CSV asset and batch-insert all rows
    final rawCsv = await rootBundle.loadString('assets/data/arabic_nouns.csv');
    final List<String> lines = const LineSplitter().convert(rawCsv);
    final batch = db.batch();

    // Skip header row:
    for (var i = 1; i < lines.length; i++) {
      final columns = lines[i].split(',');
      if (columns.length < 2) continue;
      batch.insert('word_entries', {
        'lemma': columns[0].trim(),
        'definition': columns[1].trim(),
      });
    }
    await batch.commit(noResult: true);
  }

  /// How many total levels do we have, at exactly 5 words per level?
  Future<int> getTotalLevelCount() async {
    final db = await database;
    final totalWords = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM word_entries')
    )!;
    return (totalWords / 5).ceil();
  }

  /// Fetch the five words (and definitions) for [zeroBasedLevelIndex].
  Future<List<Map<String, dynamic>>> fetchEntriesForLevel(int zeroBasedLevelIndex) async {
    final db = await database;
    final offset = zeroBasedLevelIndex * 5;
    return db.query(
      'word_entries',
      orderBy: 'id',
      limit: 5,
      offset: offset,
    );
  }
}
