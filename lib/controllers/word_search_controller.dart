import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import '../models/letter_model.dart';

class WordSearchController extends GetxController {
  final List<String> words = ["APPLE", "TABLE", "CHAIR", "HOUSE", "PLANT"];
  RxInt currentWordIndex = 0.obs;
  RxList<LetterModel> shuffledLetters = <LetterModel>[].obs;

  // List of selected letters placed by the user in the answer boxes
  RxList<String?> selectedLetters = <String?>[].obs;

  // List of letters that are available for dragging
  RxList<LetterModel> availableLetters = <LetterModel>[].obs;

  // Map storing the positions of letters in the draggable area
  RxMap<String, Offset> letterPositions = <String, Offset>{}.obs;

  // constants for the layout of the letter grid
  final double containerWidth = 300;
  final double containerHeight = 150;
  final double boxSize = 50;
  final double margin = 20;

  @override
  void onInit() {
    // Initialize the game by shuffling the first word
    shuffleCurrentWord();
    super.onInit();
  }

  /// Shuffles the letters of the current word and assigns random positions
  void shuffleCurrentWord() {
    String word = words[currentWordIndex.value]; // Get the current word
    List<String> letters = word.split(''); // Split into individual letters

    // Track letter occurrences to ensure unique keys for duplicate letters
    Map<String, int> letterCount = {};
    List<LetterModel> uniqueLetterKeys = letters.map((letter) {
      letterCount[letter] = (letterCount[letter] ?? 0) + 1;
      return LetterModel(letter: letter, index: letterCount[letter]!);
    }).toList();

    // Shuffle the letters randomly
    uniqueLetterKeys.shuffle();

    // Determine grid dimensions for letter placement
    int columns = 3;
    int rows = (letters.length / columns).ceil();
    double cellWidth = (containerWidth - margin * 2) / columns;
    double cellHeight = (containerHeight - margin * 2) / rows;

    Random random = Random();
    List<Offset> positions = [];
    letterPositions.clear(); // Clear previous letter positions

    // Assign random positions for each letter
    for (var key in uniqueLetterKeys) {
      int col, row;
      Offset newPosition;
      do {
        col = random.nextInt(columns);
        row = random.nextInt(rows);
        newPosition = Offset(
          margin + col * cellWidth + (cellWidth - boxSize) / 2,
          margin + row * cellHeight + (cellHeight - boxSize) / 2,
        );
      } while (positions.contains(newPosition)); // Avoid duplicate positions

      positions.add(newPosition);
      letterPositions[key.uniqueKey] = newPosition;
    }

    // Update observable lists with the shuffled letters
    shuffledLetters.assignAll(uniqueLetterKeys);
    availableLetters.assignAll(uniqueLetterKeys);
    selectedLetters.assignAll(List.filled(word.length, null)); // Initialize selection slots
  }

  /// Handles dropping a letter into the correct position in the answer row
  void onLetterDropped(String letter, int index) {
    // Find the dragged letter model in available letters
    LetterModel? letterModel = availableLetters.firstWhereOrNull((l) => l.uniqueKey == letter);

    // Only allow placing a letter if the slot is empty
    if (letterModel != null && selectedLetters[index] == null) {
      availableLetters.remove(letterModel); // Remove from available letters
      selectedLetters[index] = letter; // Place in the selected position
    }
  }

  /// Confirms the selected word order and checks if it is correct
  void onConfirm() {
    // Construct the word from selected letters (removing unique keys)
    String selectedWord = selectedLetters.map((e) => e?.split('_')[0] ?? '').join('');

    if (selectedWord == words[currentWordIndex.value]) {
      // User input is correct, show success message
      Get.snackbar("Correct!", "Good Job!", backgroundColor: Get.theme.primaryColor ?? Colors.green);

      Future.delayed(Duration(seconds: 1), () {
        if (currentWordIndex.value < words.length - 1) {
          currentWordIndex.value++; // Move to next word
          shuffleCurrentWord(); // Shuffle letters for the new word
          update(); // Ensure UI rebuilds
        } else {
          // Game completed, show success message
          Get.snackbar("Game Over! 🎉", "You finished all words!");
        }
      });
    } else {
      // Incorrect input, show error message and reset selection
      Get.snackbar("Try Again", "Incorrect word!", backgroundColor: Get.theme.colorScheme.error ?? Colors.red);
      selectedLetters.assignAll(List.filled(words[currentWordIndex.value].length, null));
      update(); // Ensure UI updates
    }
  }

  /// Returns a letter to the available letters list when removed from selection
  void returnLetter(String letter) {
    int index = selectedLetters.indexOf(letter);

    if (index != -1) {
      selectedLetters[index] = null; // Clear the selected slot
      LetterModel? letterModel = shuffledLetters.firstWhereOrNull((l) => l.uniqueKey == letter);

      if (letterModel != null && !availableLetters.contains(letterModel)) {
        availableLetters.add(letterModel); // Add back to available letters
      }
    }
  }

  /// Resets the current word by reshuffling the letters
  void onReset() {
    shuffleCurrentWord(); // Reshuffle the letters for the current word
  }
}
