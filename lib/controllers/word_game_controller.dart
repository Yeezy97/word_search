import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import '../models/word_entry.dart';
import 'difficulty_controller.dart';

class WordGameController extends GetxController {
  static const int wordsPerLevel = 5;
  static final RegExp _arabicDiacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');

  final DifficultyController difficultyController = Get.find<DifficultyController>();

  RxList<WordEntry> wordBank = <WordEntry>[].obs;
  late final List<List<WordEntry>> levels;

  RxInt currentLevelIndex = 0.obs;
  RxInt currentWordIndex  = 0.obs;

  RxString displayedWord       = ''.obs;
  RxString displayedDefinition = ''.obs;

  /// Computed once per word, not in a getter!
  RxList<bool> hiddenLetterFlags = RxList<bool>();

  RxList<Offset> letterBoxPositions = <Offset>[].obs;
  RxList<bool>   isLetterBoxPlaced  = RxList<bool>();
  RxList<String?> lettersInTargets  = RxList<String?>();
  RxList<int?>   targetToSourceMap  = RxList<int?>();

  Rx<Color>  targetHighlightColor = Colors.transparent.obs;
  RxBool    levelCompleted       = false.obs;

  double    lastContainerWidth    = 0;
  final double letterContainerHeight = 210;
  final double letterBoxSize         = 40;
  final double letterContainerPadding= 8;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadWordBank();
    _splitIntoLevels();
    startNextWord();
  }

  Future<void> _loadWordBank() async {
    final raw = await rootBundle.loadString('assets/data/arabic_nouns.csv');
    final rows = const CsvToListConverter(eol: '\n').convert(raw);
    final temp = <WordEntry>[];
    for (var i = 1; i < rows.length; i++) {
      temp.add(WordEntry(lemma: rows[i][0].toString(), definition: rows[i][1].toString()));
    }
    final seen = <String>{};
    final uniq = temp.where((e) => seen.add(e.lemma)).toList();
    uniq.shuffle();
    wordBank.value = uniq;
  }

  void _splitIntoLevels() {
    levels = [];
    for (var i = 0; i + wordsPerLevel <= wordBank.length; i += wordsPerLevel) {
      levels.add(wordBank.getRange(i, i + wordsPerLevel).toList());
    }
  }

  /// Word without diacritics
  String get sanitizedWord =>
      displayedWord.value.replaceAll(_arabicDiacritics, '');

  /// Simply read the flags, don’t modify anything here
  String get maskedDisplayedWord {
    final diff = difficultyController.selectedDifficulty.value;
    final base = sanitizedWord;
    // Beginner: no masking
    if (diff == 'Beginner') return displayedWord.value;

    final flags = hiddenLetterFlags;
    final buffer = StringBuffer();
    for (var i = 0; i < base.length; i++) {
      buffer.write(flags[i] ? '_' : base[i]);
    }
    return buffer.toString();
  }

  /// Public: advance to the next word
  void startNextWord() {
    if (levels.isEmpty) return;
    final entry = levels[currentLevelIndex.value][currentWordIndex.value];
    displayedWord.value       = entry.lemma;
    displayedDefinition.value = entry.definition;

    _computeHiddenFlags();       // ← compute flags once here
    resetPlacementState();
    _layoutLetterBoxes();
    update();
  }

  /// Based on selectedDifficulty and level, build hiddenLetterFlags
  void _computeHiddenFlags() {
    final diff = difficultyController.selectedDifficulty.value;
    final base = sanitizedWord;
    final length = base.length;

    // Determine fraction to hide
    double fraction;
    switch (diff) {
      case 'Beginner':
        fraction = 0.0;
        break;
      case 'Intermediate':
        fraction = 2/6;
        break;
      case 'Challenger':
        fraction = 4/6;
        break;
      default: // Progressive
        if (currentLevelIndex.value > 20) fraction = 4/6;
        else if (currentLevelIndex.value > 10) fraction = 3/6;
        else if (currentLevelIndex.value > 2)  fraction = 2/6;
        else fraction = 0.0;
    }

    int hideCount = (length * fraction).floor();
    if (length.isOdd && hideCount > 0) hideCount--;

    hiddenLetterFlags.value = List<bool>.filled(length, false);
    final rnd = Random();
    final chosen = <int>{};
    while (chosen.length < hideCount && chosen.length < length) {
      chosen.add(rnd.nextInt(length));
    }
    for (var idx in chosen) {
      hiddenLetterFlags[idx] = true;
    }
  }

  void resetPlacementState() {
    final count = sanitizedWord.length;
    isLetterBoxPlaced.value = List<bool>.filled(count, false);
    lettersInTargets.value  = List<String?>.filled(count, null);
    targetToSourceMap.value = List<int?>.filled(count, null);
    letterBoxPositions.value= [];
    targetHighlightColor.value = Colors.transparent;
  }

  void _layoutLetterBoxes() {
    final count = sanitizedWord.length;
    final rnd   = Random();
    final pad   = letterContainerPadding;
    final ew    = lastContainerWidth - pad*2 - letterBoxSize;
    final eh    = letterContainerHeight - pad*2 - letterBoxSize;

    final positions = <Offset>[];
    int tries = 0;
    while (positions.length < count && tries < 2000) {
      final dx = pad + rnd.nextDouble()*ew;
      final dy = pad + rnd.nextDouble()*eh;
      final rect = Rect.fromLTWH(dx, dy, letterBoxSize, letterBoxSize);
      final overlap = positions.any((o) {
        final r2 = Rect.fromLTWH(o.dx, o.dy, letterBoxSize, letterBoxSize);
        return r2.overlaps(rect);
      });
      if (!overlap) positions.add(Offset(dx, dy));
      tries++;
    }
    letterBoxPositions.value = positions;
  }

  /// Call after layout measurement
  void generateLetterPositions(double width) {
    lastContainerWidth = width;
    _layoutLetterBoxes();
  }

  void placeLetterInTarget(int tIdx, int sIdx) {
    lettersInTargets[tIdx]     = sanitizedWord[sIdx];
    targetToSourceMap[tIdx]    = sIdx;
    isLetterBoxPlaced[sIdx]    = true;
    update();
  }

  void removeLetterFromTarget(int tIdx) {
    final sIdx = targetToSourceMap[tIdx];
    if (sIdx != null) {
      isLetterBoxPlaced[sIdx]     = false;
      lettersInTargets[tIdx]      = null;
      targetToSourceMap[tIdx]     = null;
      update();
    }
  }

  void autoPlaceLetterBox(int sIdx) {
    if (isLetterBoxPlaced[sIdx]) return;
    final tIdx = lettersInTargets.indexWhere((l) => l == null);
    if (tIdx >= 0) placeLetterInTarget(tIdx, sIdx);
  }

  bool get isCurrentWordComplete => !lettersInTargets.contains(null);
  bool checkUserAnswer() =>
      lettersInTargets.join().toLowerCase() == sanitizedWord.toLowerCase();

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
}
