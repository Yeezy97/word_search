// lib/controllers/word_game_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import '../models/word_entry.dart';
import 'difficulty_controller.dart';

class WordGameController extends GetxController {
  // Number of words per level
  static const int wordsPerLevel = 5;

  // Regex matching Arabic diacritic combining marks
  static final RegExp _arabicDiacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  // DifficultyController (injected via InitialBindings)
  final DifficultyController difficultyController = Get.find<DifficultyController>();

  // Full word bank (deduped + shuffled)
  final RxList<WordEntry> wordBank = <WordEntry>[].obs;

  // Split into levels (sublists of exactly [wordsPerLevel])
  late final List<List<WordEntry>> levels;

  // Current level & word indices (0-based)
  RxInt currentLevelIndex = 0.obs;
  RxInt currentWordIndex  = 0.obs;

  // The word & its definition shown at top
  RxString displayedWord       = ''.obs;
  RxString displayedDefinition = ''.obs;

  // Flags for which letters to hide (Progressive difficulty)
  RxList<bool> hiddenLetterFlags = RxList<bool>();

  // Positions for draggable letter boxes
  RxList<Offset> letterBoxPositions = <Offset>[].obs;

  // Tracks which source boxes have been placed
  RxList<bool> isLetterBoxPlaced    = RxList<bool>();

  // Letters the user has dropped into each target slot
  RxList<String?> lettersInTargets  = RxList<String?>();

  // Map each target slot back to its source index
  RxList<int?> targetToSourceMapping = RxList<int?>();

  // Target highlight color for blink animation
  Rx<Color> targetHighlightColor = Colors.transparent.obs;

  // Last measured width used to layout boxes
  double lastContainerWidth = 0;

  // UI sizing
  final double letterContainerHeight = 210;
  final double letterBoxSize         = 40;
  final double letterContainerPadding= 8;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadAndPrepareWordBank();
    _splitBankIntoLevels();
    startNextWord();
  }

  /// 1) Load CSV → 2) dedupe → 3) shuffle
  Future<void> _loadAndPrepareWordBank() async {
    final rawCsv = await rootBundle.loadString('assets/data/arabic_nouns.csv');
    final csvRows = const CsvToListConverter(eol: '\n').convert(rawCsv);

    final List<WordEntry> tempList = [];
    for (var row = 1; row < csvRows.length; row++) {
      tempList.add(WordEntry(
        lemma:      csvRows[row][0].toString(),
        definition: csvRows[row][1].toString(),
      ));
    }
    // Deduplicate
    final seenLemmas = <String>{};
    final uniqueList = tempList.where((e) => seenLemmas.add(e.lemma)).toList();
    // Shuffle
    uniqueList.shuffle();
    wordBank.value = uniqueList;
  }

  /// Chunk into levels of [wordsPerLevel]
  void _splitBankIntoLevels() {
    levels = [];
    for (var i = 0; i + wordsPerLevel <= wordBank.length; i += wordsPerLevel) {
      levels.add(wordBank.getRange(i, i + wordsPerLevel).toList());
    }
  }

  /// Word without diacritics
  String get sanitizedWord => displayedWord.value.replaceAll(_arabicDiacritics, '');

  /// Masked word for Progressive difficulty
  String get maskedDisplayedWord {
    if (difficultyController.selectedDifficulty.value != 'Progressive Difficulty') {
      return displayedWord.value;
    }
    final base = sanitizedWord;
    final buffer = StringBuffer();
    for (var i = 0; i < base.length; i++) {
      buffer.write(hiddenLetterFlags[i] ? '_' : base[i]);
    }
    return buffer.toString();
  }

  /// Start the next word in the current level
  void startNextWord() {
    if (levels.isEmpty) return;
    final entry = levels[currentLevelIndex.value][currentWordIndex.value];
    displayedWord.value       = entry.lemma;
    displayedDefinition.value = entry.definition;
    _configureHiddenLetters();
    resetPlacementState();
    _layoutLetterBoxes();
    update();
  }

  /// Determine which letters to hide based on difficulty & level
  void _configureHiddenLetters() {
    final int letterCount = sanitizedWord.length;
    hiddenLetterFlags.value = List<bool>.filled(letterCount, false);

    if (difficultyController.selectedDifficulty.value != 'Progressive Difficulty') {
      return;
    }

    double hideFraction = 0;
    if (currentLevelIndex.value > 20) {
      hideFraction = 4 / 6;
    } else if (currentLevelIndex.value > 10) {
      hideFraction = 3 / 6;
    } else if (currentLevelIndex.value > 2) {
      hideFraction = 2 / 6;
    }
    int hideCount = (letterCount * hideFraction).floor();
    if (letterCount.isOdd && hideCount > 0) hideCount--;

    final rnd = Random();
    final chosen = <int>{};
    while (chosen.length < hideCount && chosen.length < letterCount) {
      chosen.add(rnd.nextInt(letterCount));
    }
    for (var idx in chosen) {
      hiddenLetterFlags[idx] = true;
    }
  }

  /// Clear all drag/drop trackers
  void resetPlacementState() {
    final int count = sanitizedWord.length;
    isLetterBoxPlaced.value    = List<bool>.filled(count, false);
    lettersInTargets.value     = List<String?>.filled(count, null);
    targetToSourceMapping.value= List<int?>.filled(count, null);
    letterBoxPositions.value   = [];
    targetHighlightColor.value = Colors.transparent;
  }

  /// Compute random non‑overlapping positions
  void _layoutLetterBoxes() {
    final int count = sanitizedWord.length;
    final rnd = Random();
    final pad = letterContainerPadding;
    final ew  = lastContainerWidth - pad * 2 - letterBoxSize;
    final eh  = letterContainerHeight - pad * 2 - letterBoxSize;

    final positions = <Offset>[];
    int attempts = 0;
    while (positions.length < count && attempts < 2000) {
      final dx = pad + rnd.nextDouble() * ew;
      final dy = pad + rnd.nextDouble() * eh;
      final rect = Rect.fromLTWH(dx, dy, letterBoxSize, letterBoxSize);

      bool overlap = positions.any((o) {
        final existing = Rect.fromLTWH(o.dx, o.dy, letterBoxSize, letterBoxSize);
        return existing.overlaps(rect);
      });

      if (!overlap) positions.add(Offset(dx, dy));
      attempts++;
    }
    letterBoxPositions.value = positions;
  }

  /// Call once you know container width
  void generateLetterPositions(double containerWidth) {
    lastContainerWidth = containerWidth;
    _layoutLetterBoxes();
  }

  /// Place a letter into target
  void placeLetterInTarget(int targetIndex, int sourceIndex) {
    lettersInTargets[targetIndex]      = sanitizedWord[sourceIndex];
    targetToSourceMapping[targetIndex] = sourceIndex;
    isLetterBoxPlaced[sourceIndex]     = true;
    update();
  }

  /// Remove a letter back to pool
  void removeLetterFromTarget(int targetIndex) {
    final src = targetToSourceMapping[targetIndex];
    if (src != null) {
      isLetterBoxPlaced[src]            = false;
      lettersInTargets[targetIndex]     = null;
      targetToSourceMapping[targetIndex] = null;
      update();
    }
  }

  /// Double‑tap shortcut
  void autoPlaceLetterBox(int sourceIndex) {
    if (isLetterBoxPlaced[sourceIndex]) return;
    final slot = lettersInTargets.indexWhere((l) => l == null);
    if (slot >= 0) placeLetterInTarget(slot, sourceIndex);
  }

  bool get isCurrentWordComplete => !lettersInTargets.contains(null);
  bool checkUserAnswer() => lettersInTargets.join().toLowerCase() == sanitizedWord.toLowerCase();

  /// Called when Confirm is tapped
  Future<void> confirmUserAnswer() async {
    if (!isCurrentWordComplete) return;

    if (checkUserAnswer()) {
      targetHighlightColor.value = Colors.green;
      await Future.delayed(const Duration(milliseconds: 500));

      if (currentWordIndex.value < wordsPerLevel - 1) {
        currentWordIndex.value++;
        startNextWord();
      } else {
        levelCompleted.value = true;
      }

    } else {
      targetHighlightColor.value = Colors.red;
      await Future.delayed(const Duration(milliseconds: 500));
      resetPlacementState();
      generateLetterPositions(lastContainerWidth);
    }

    targetHighlightColor.value = Colors.transparent;
    update();
  }

  /// Triggers the “level complete” dialog
  RxBool levelCompleted = false.obs;

  /// The user‑formed word
  String get formedWord => lettersInTargets.join();
}
