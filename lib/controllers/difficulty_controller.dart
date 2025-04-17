import 'package:get/get.dart';

/// Holds the currently selected difficulty for the game.
class DifficultyController extends GetxController {
  /// The four possible difficulties.
  static const List<String> allDifficulties = [
    'Progressive Difficulty',
    'Beginner',
    'Intermediate',
    'Challenger',
  ];

  /// Reactive string so UI can Obx‑watch changes.
  final RxString selectedDifficulty = 'Progressive Difficulty'.obs;

  /// Call this to change the difficulty.
  void selectDifficulty(String difficulty) {
    if (allDifficulties.contains(difficulty)) {
      selectedDifficulty.value = difficulty;
    }
  }
}
