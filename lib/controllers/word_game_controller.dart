import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WordGameController extends GetxController {
  // Define two levels (each level: 5 words)
  final List<List<String>> levels = [
    ['Doctor', 'Nurse', 'Hospital', 'Medicine', 'Patient'],
    ['Stethoscope', 'Diagnosis', 'Pharmacy', 'Surgery', 'Ambulance'],
  ];

  // Track current level and current word index (both 0-based).
  RxInt currentLevel = 0.obs;
  RxInt currentWordIndex = 0.obs;

  /// Convenience getter for the current word.
  String get currentWord => levels[currentLevel.value][currentWordIndex.value];

  // Dimensions for letter container.
  final double containerHeight = 210;
  final double boxSize = 40;
  final double containerPadding = 8.0;

  // Observables for draggable letters.
  RxList<Offset> letterPositions = <Offset>[].obs;
  RxList<bool> isLetterPlaced = RxList<bool>();
  RxList<String?> placedLetters = RxList<String?>();
  // To remember which draggable (source index) was placed in each target.
  RxList<int?> placedIndices = RxList<int?>();

  // Observable to animate drag targets upon confirmation.
  Rx<Color> targetBoxColor = Colors.transparent.obs;

  // Flag to indicate the level has been completed.
  RxBool levelCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    initWord();
  }

  /// Initializes the state for the current word.
  void initWord() {
    int len = currentWord.length;
    isLetterPlaced.value = List<bool>.filled(len, false);
    placedLetters.value = List<String?>.filled(len, null);
    placedIndices.value = List<int?>.filled(len, null);
    letterPositions.value = [];
    levelCompleted.value = false;
    targetBoxColor.value = Colors.transparent;
  }

  /// Generates non-colliding random positions for draggable letters.
  List<Offset> _generateNonCollidingPositions(
      int count,
      double containerWidth,
      double containerHeight,
      double boxSize,
      double padding) {
    List<Offset> positions = [];
    Random random = Random();
    double effectiveWidth = containerWidth - padding * 2;
    double effectiveHeight = containerHeight - padding * 2;
    int attempts = 0;
    while (positions.length < count && attempts < 1000) {
      double left = padding + random.nextDouble() * (effectiveWidth - boxSize);
      double top = padding + random.nextDouble() * (effectiveHeight - boxSize);
      Offset candidate = Offset(left, top);
      Rect candidateRect = Rect.fromLTWH(candidate.dx, candidate.dy, boxSize, boxSize);
      bool collides = positions.any((pos) {
        Rect existing = Rect.fromLTWH(pos.dx, pos.dy, boxSize, boxSize);
        return candidateRect.overlaps(existing);
      });
      if (!collides) {
        positions.add(candidate);
      }
      attempts++;
    }
    return positions;
  }

  /// Generates letter positions for the current word.
  void generatePositions(double containerWidth) {
    letterPositions.value = _generateNonCollidingPositions(
      currentWord.length,
      containerWidth,
      containerHeight,
      boxSize,
      containerPadding,
    );
  }

  /// Places a letter into a target slot.
  void placeLetter(int targetIndex, int sourceIndex) {
    placedLetters[targetIndex] = currentWord[sourceIndex];
    placedIndices[targetIndex] = sourceIndex;
    isLetterPlaced[sourceIndex] = true;
    update();
  }

  /// Removes a letter from a target (e.g. on double tap).
  void removeLetter(int targetIndex) {
    int? sourceIndex = placedIndices[targetIndex];
    if (sourceIndex != null) {
      isLetterPlaced[sourceIndex] = false;
      placedLetters[targetIndex] = null;
      placedIndices[targetIndex] = null;
      update();
    }
  }
  /// Automatically places the letter from [sourceIndex] into the first available target slot.
  void autoPlaceLetter(int sourceIndex) {
    // If already placed, do nothing.
    if (isLetterPlaced[sourceIndex]) return;
    // Find the first empty target slot.
    int targetIndex = placedLetters.indexWhere((element) => element == null);
    if (targetIndex != -1) {
      placeLetter(targetIndex, sourceIndex);
    }
  }

  /// Returns true if every target slot is filled.
  bool isWordComplete() {
    return !placedLetters.contains(null);
  }

  /// Checks whether the formed word matches the current word.
  bool checkWord() {
    return placedLetters.join().toLowerCase() == currentWord.toLowerCase();
  }

  /// Verifies the word and animates the target boxes.
  Future<void> confirmWord(double containerWidth) async {
    if (!isWordComplete()) return;
    if (checkWord()) {
      targetBoxColor.value = Colors.green;
      await Future.delayed(const Duration(milliseconds: 500));
      if (currentWordIndex.value < levels[currentLevel.value].length - 1) {
        currentWordIndex.value++;
        initWord();
        generatePositions(containerWidth);
      } else {
        levelCompleted.value = true;
      }
      targetBoxColor.value = Colors.transparent;
      update();
    } else {
      targetBoxColor.value = Colors.red;
      await Future.delayed(const Duration(milliseconds: 500));
      resetCurrentWord(containerWidth);
      targetBoxColor.value = Colors.transparent;
      update();
    }
  }

  /// Resets the current word (clearing placements).
  void resetCurrentWord(double containerWidth) {
    initWord();
    generatePositions(containerWidth);
    update();
  }

  /// Resets the current level (starting at word 1).
  void resetLevel(double containerWidth) {
    currentWordIndex.value = 0;
    levelCompleted.value = false;
    initWord();
    generatePositions(containerWidth);
    update();
  }

  /// Advances to the next level if available.
  void nextLevel(double containerWidth) {
    if (currentLevel.value < levels.length - 1) {
      currentLevel.value++;
      currentWordIndex.value = 0;
      levelCompleted.value = false;
      initWord();
      generatePositions(containerWidth);
      update();
    } else {
      // Optionally handle end-of-game.
    }
  }

  String get formedWord => placedLetters.join();
}



