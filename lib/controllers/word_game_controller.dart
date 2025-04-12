import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WordGameController extends GetxController {
  // The word to form.
  final String word = 'Doctor';

  // Dimensions for the letter containers.
  final double containerHeight = 210;
  final double boxSize = 40; // smaller box size for both draggables & targets.
  final double containerPadding = 8.0;

  // Reactive variables.
  // Holds the random positions for each letter.
  RxList<Offset> letterPositions = <Offset>[].obs;
  // Tracks if each letter has been placed (index-based).
  RxList<bool> isLetterPlaced = RxList<bool>();
  // Contains the letters placed in the drop targets (null if not placed).
  RxList<String?> placedLetters = RxList<String?>();

  @override
  void onInit() {
    super.onInit();
    isLetterPlaced.value = List<bool>.filled(word.length, false);
    placedLetters.value = List<String?>.filled(word.length, null);
  }

  /// Generates non-colliding random positions for the draggable letters.
  List<Offset> _generateNonCollidingPositions(
      int count,
      double containerWidth,
      double containerHeight,
      double boxSize,
      double padding,
      ) {
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

  /// Call this method from your UI once you know the container's available width.
  void generatePositions(double containerWidth) {
    letterPositions.value = _generateNonCollidingPositions(
      word.length,
      containerWidth,
      containerHeight,
      boxSize,
      containerPadding,
    );
  }

  /// Places a letter in the target slot.
  void placeLetter(int targetIndex, int sourceIndex) {
    placedLetters[targetIndex] = word[sourceIndex];
    isLetterPlaced[sourceIndex] = true;
    update();
  }

  /// Returns the formed word.
  String get formedWord => placedLetters.join();

  /// Checks if the formed word matches the target word.
  bool checkWord() {
    return formedWord.toLowerCase() == word.toLowerCase();
  }

  /// Resets the game state so that all draggable letters are restored.
  void resetGame(double containerWidth) {
    isLetterPlaced.value = List<bool>.filled(word.length, false);
    placedLetters.value = List<String?>.filled(word.length, null);
    // Generate new positions (or use the same positions if desired).
    letterPositions.value = _generateNonCollidingPositions(
      word.length,
      containerWidth,
      containerHeight,
      boxSize,
      containerPadding,
    );
    update();
  }
}
