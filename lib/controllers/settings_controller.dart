import 'package:get/get.dart';
import 'package:flutter/material.dart';

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
  /// Set a new language and update the app locale.
  void setLanguage(String language) {
    selectedLanguage.value = language;
    if (language == 'Arabic') {
      Get.updateLocale(const Locale('ar', 'AE')); // You can change locale ID as needed.
    } else if (language == 'English') {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
