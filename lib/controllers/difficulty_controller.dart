import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late final SharedPreferences _prefs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _prefs = Get.find<SharedPreferences>();
    // Load saved difficulty if it exists
    final saved = _prefs.getString('selected_difficulty');          // ← NEW
    if (saved != null && allDifficulties.contains(saved)) {
      selectedDifficulty.value = saved;                             // ← NEW
    }

    // Persist any changes
    ever<String>(selectedDifficulty, (val) {                        // ← NEW
      _prefs.setString('selected_difficulty', val);                // ← NEW
    });
  }
  /// Call this to change the difficulty.
  void selectDifficulty(String difficulty) {
    if (allDifficulties.contains(difficulty)) {
      selectedDifficulty.value = difficulty;
    }
  }
}
