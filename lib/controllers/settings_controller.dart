import 'package:get/get.dart';

class SettingsController extends GetxController {
  // An example observable setting for sound.
  RxBool isSoundOn = true.obs;

  // An example observable for language selection.
  RxString selectedLanguage = 'English'.obs;

  /// Toggle the sound on/off.
  void toggleSound() {
    isSoundOn.value = !isSoundOn.value;
  }

  /// Set a new language.
  void setLanguage(String language) {
    selectedLanguage.value = language;
  }
}
