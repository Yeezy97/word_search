import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:word_search/controllers/difficulty_controller.dart';
import 'package:word_search/controllers/auth_controller.dart';
import 'package:word_search/controllers/progress_controller.dart';
import 'package:word_search/controllers/local_progress_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies(){
    Get.find<SharedPreferences>();
    Get.put(NavigationController());
    Get.put(DifficultyController());
    Get.put(AuthController());
    Get.put(ProgressController());
    Get.put(LocalProgressController());
  }
}