import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProgressController extends GetxController {
  final _prefs = Get.find<SharedPreferences>();
  final score  = 0.obs;
  final level  = 1.obs;

  @override
  void onInit() {
    super.onInit();
    score.value = _prefs.getInt('guest_score') ?? 0;
    level.value = _prefs.getInt('guest_level') ?? 1;
    everAll([score, level], (_) => _save());
  }

  void _save() {
    _prefs.setInt('guest_score', score.value);
    _prefs.setInt('guest_level', level.value);
  }

  void updateLocalProgress({required int newLevel, int addScore = 50}) {
    score.value += addScore;
    level.value  = newLevel;
  }
}
