import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import '../models/word_entry.dart';
import 'difficulty_controller.dart';
import 'auth_controller.dart';
import 'progress_controller.dart';
import 'local_progress_controller.dart';

class WordGameController extends GetxController {
  static const int wordsPerLevel = 5;
  static const int levelsPerChapter = 100;
  static const int wordsPerChapter = wordsPerLevel * levelsPerChapter;
  static final RegExp _arabicDiacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  // Controllers
  final DifficultyController difficultyController = Get.find();
  final ProgressController cloudProgressController = Get.find();
  final LocalProgressController guestProgressController = Get.find();
  final AuthController authController = Get.find();

  // CSV and chapter cache
  late List<List<dynamic>> _allCsvRows;
  final Map<int, List<WordEntry>> _chapterCache = {};

  // Current chapter/level data
  List<List<WordEntry>> levels = [];
  RxInt currentLevelIndex = 0.obs;
  RxInt currentWordIndex = 0.obs;

  // Displayed word/definition
  RxString displayedWord = ''.obs;
  RxString displayedDefinition = ''.obs;
  RxList<bool> hiddenLetterFlags = <bool>[].obs;

  // Drag-drop UI state
  RxList<Offset> letterBoxPositions = <Offset>[].obs;
  RxList<bool> isLetterBoxPlaced = RxList<bool>();
  RxList<String?> lettersInTargets = RxList<String?>();
  RxList<int?> targetToSourceMap = RxList<int?>();
  Rx<Color> targetHighlightColor = Colors.transparent.obs;
  RxBool levelCompleted = false.obs;
  RxBool isInitialized = false.obs;

  // Layout parameters
  double lastBoxContainerWidth = 0;
  final double boxContainerHeight = 210;
  final double letterBoxSize = 40;
  final double boxContainerPadding = 8;

  /// Total number of levels across the entire CSV data.
  int get totalLevelsCount => (_allCsvRows.length / wordsPerLevel).ceil();

  /// Total number of chapters (groups of 100 levels).
  int get totalChaptersCount => (totalLevelsCount / levelsPerChapter).ceil();

  /// One-based current chapter number for UI.
  int get currentChapterNumber => (currentLevelIndex.value ~/ levelsPerChapter) + 1;

  /// One-based current level number for UI.
  int get currentLevelNumber => currentLevelIndex.value + 1;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Load CSV data once
    await _loadCsvData();

    // Determine starting level
    final levelVal = authController.isLoggedIn
        ? cloudProgressController.level.value
        : guestProgressController.level.value;
    final initialIndex = levelVal > 0 ? levelVal - 1 : 0;
    final initialChapter = initialIndex ~/ levelsPerChapter;

    await prepareChapter(initialChapter);
    currentLevelIndex.value = initialIndex;
    currentWordIndex.value = 0;
    await startNextWord();

    // React to progress changes
    ever<int>(cloudProgressController.level, (newLevel) async {
      if (authController.isLoggedIn) {
        final idx = newLevel > 0 ? newLevel - 1 : 0;
        final chap = idx ~/ levelsPerChapter;
        await prepareChapter(chap);
        currentLevelIndex.value = idx;
        currentWordIndex.value = 0;
        await startNextWord();
      }
    });
    ever<int>(guestProgressController.level, (newLevel) async {
      if (!authController.isLoggedIn) {
        final idx = newLevel > 0 ? newLevel - 1 : 0;
        final chap = idx ~/ levelsPerChapter;
        await prepareChapter(chap);
        currentLevelIndex.value = idx;
        currentWordIndex.value = 0;
        await startNextWord();
      }
    });

    isInitialized.value = true;
  }

  Future<void> _loadCsvData() async {
    final dataString = await rootBundle.loadString('assets/data/arabic_nouns.csv');
    final rows = const CsvToListConverter().convert(dataString);
    _allCsvRows = rows.length > 1 ? rows.sublist(1) : [];
    print('[CSV] Loaded total entries: ${_allCsvRows.length}');
  }

  /// Load and cache a chapter (500 words).
  Future<void> _loadChapter(int chapterIndex) async {
    if (_chapterCache.containsKey(chapterIndex)) return;
    final start = chapterIndex * wordsPerChapter;
    final end = (start + wordsPerChapter).clamp(0, _allCsvRows.length);
    final slice = _allCsvRows.sublist(start, end);
    final entries = slice.map((columns) {
      return WordEntry(
        lemma: columns[0].toString(),
        definition: columns[1].toString(),
      );
    }).toList();
    _chapterCache[chapterIndex] = entries;
    print('[CSV] Cached chapter ${chapterIndex + 1} with ${entries.length} entries');
  }

  /// Prepare level list for a chapter.
  Future<void> prepareChapter(int chapterIndex) async {
    await _loadChapter(chapterIndex);
    final allEntries = _chapterCache[chapterIndex]!;
    levels = [];
    for (int i = 0; i < allEntries.length; i += wordsPerLevel) {
      final end = (i + wordsPerLevel).clamp(0, allEntries.length);
      levels.add(allEntries.sublist(i, end));
    }
    final computedLevels = (allEntries.length / wordsPerLevel).ceil();
    print('[CSV] Prepared $computedLevels levels for chapter ${chapterIndex + 1}');
  }

  String get sanitizedWord => displayedWord.value.replaceAll(_arabicDiacritics, '');

  String get maskedDisplayedWord {
    final diff = difficultyController.selectedDifficulty.value;
    if (diff == 'Beginner') return displayedWord.value;
    final base = sanitizedWord;
    final flags = hiddenLetterFlags;
    final buffer = StringBuffer();
    for (int i = 0; i < base.length; i++) {
      buffer.write(flags[i] ? '_' : base[i]);
    }
    return buffer.toString();
  }

  /// Advance to the next word in the current chapter.
  Future<void> startNextWord() async {
    final levelIndex = currentLevelIndex.value;
    final chapterIndex = levelIndex ~/ levelsPerChapter;
    if (!_chapterCache.containsKey(chapterIndex)) {
      await prepareChapter(chapterIndex);
    }
    final entry = levels[levelIndex % levelsPerChapter][currentWordIndex.value];
    displayedWord.value = entry.lemma;
    displayedDefinition.value = entry.definition;
    computeHiddenLetterFlags();
    resetPlacementState();
    generateLetterBoxes();
    update();
  }

  void computeHiddenLetterFlags() {
    final base = sanitizedWord;
    final length = base.length;
    final diff = difficultyController.selectedDifficulty.value;
    double fraction;
    switch (diff) {
      case 'Beginner': fraction = 0.0; break;
      case 'Intermediate': fraction = 2 / 6; break;
      case 'Challenger': fraction = 4 / 6; break;
      default:
        if (currentLevelIndex.value > 20) fraction = 4 / 6;
        else if (currentLevelIndex.value > 10) fraction = 3 / 6;
        else if (currentLevelIndex.value > 2) fraction = 2 / 6;
        else fraction = 0.0;
    }
    int hideCount = (length * fraction).floor();
    if (length.isOdd && hideCount > 0) hideCount--;
    hiddenLetterFlags.value = List<bool>.filled(length, false);
    final random = Random();
    final chosen = <int>{};
    while (chosen.length < hideCount && chosen.length < length) {
      chosen.add(random.nextInt(length));
    }
    for (final idx in chosen) hiddenLetterFlags[idx] = true;
  }

  void resetPlacementState() {
    final count = sanitizedWord.length;
    isLetterBoxPlaced.value = List<bool>.filled(count, false);
    lettersInTargets.value = List<String?>.filled(count, null);
    targetToSourceMap.value = List<int?>.filled(count, null);
    letterBoxPositions.value = [];
    targetHighlightColor.value = Colors.transparent;
  }

  void generateLetterBoxes() {
      //  if we haven’t yet measured the parent width, skip layout entirely
      if (lastBoxContainerWidth <= 0) {
        letterBoxPositions.clear();
        return;
      }

    final int count = sanitizedWord.length;
    final random = Random();
    final pad = boxContainerPadding;
    final widthLimit = lastBoxContainerWidth - pad * 2 - letterBoxSize;
    final heightLimit = boxContainerHeight    - pad * 2 - letterBoxSize;

    final positions = <Offset>[];
    int attempts = 0;
    while (positions.length < count && attempts < 2000) {
      double x = pad + random.nextDouble() * widthLimit;
      double y = pad + random.nextDouble() * heightLimit;

      // <<< clamp so the box never gets closer than 'pad' to any border
      x = x.clamp(pad, pad + widthLimit)         as double;
      y = y.clamp(pad, pad + heightLimit)        as double;

      final rect = Rect.fromLTWH(x, y, letterBoxSize, letterBoxSize);
      final overlap = positions.any((existing) =>
          Rect.fromLTWH(existing.dx, existing.dy, letterBoxSize, letterBoxSize)
              .overlaps(rect)
      );
      if (!overlap) positions.add(Offset(x, y));
      attempts++;
    }

    letterBoxPositions.value = positions;
  }


  /// Called by the UI to layout draggable letters
  void generateLetterPositions(double width) {
    lastBoxContainerWidth = width;
    generateLetterBoxes();
  }

  /// Place a letter into a target slot
  void placeLetterInTarget(int targetIndex, int sourceIndex) {
    lettersInTargets[targetIndex] = sanitizedWord[sourceIndex];
    targetToSourceMap[targetIndex] = sourceIndex;
    isLetterBoxPlaced[sourceIndex] = true;
    update();
  }

  /// Remove a letter from its slot
  void removeLetterFromTarget(int targetIndex) {
    final sourceIndex = targetToSourceMap[targetIndex];
    if (sourceIndex != null) {
      isLetterBoxPlaced[sourceIndex] = false;
      lettersInTargets[targetIndex] = null;
      targetToSourceMap[targetIndex] = null;
      update();
    }
  }

  /// Auto-fill the next available slot with a letter
  void autoPlaceLetterBox(int sourceIndex) {
    if (isLetterBoxPlaced[sourceIndex]) return;
    final targetIndex = lettersInTargets.indexWhere((l) => l == null);
    if (targetIndex >= 0) placeLetterInTarget(targetIndex, sourceIndex);
  }

  /// Confirm user answer and advance
  Future<void> confirmUserAnswer() async {
    if (lettersInTargets.contains(null)) return;
    if (lettersInTargets.join().toLowerCase() ==
        sanitizedWord.toLowerCase()) {
      targetHighlightColor.value = Colors.green;
      await Future.delayed(const Duration(milliseconds: 500));
      if (authController.isLoggedIn) {
        await cloudProgressController.updateProgress(
            newLevel: currentLevelIndex.value + 1);
      } else if (authController.isPlayingGuest) {
        guestProgressController.updateLocalProgress(
            newLevel: currentLevelIndex.value + 1);
      }
      if (currentWordIndex.value < wordsPerLevel - 1) {
        currentWordIndex.value++;
        await startNextWord();
      } else {
        levelCompleted.value = true;
      }
    } else {
      targetHighlightColor.value = Colors.red;
      await Future.delayed(const Duration(milliseconds: 500));
      resetPlacementState();
      generateLetterBoxes();
    }
    targetHighlightColor.value = Colors.transparent;
    update();
  }
}
