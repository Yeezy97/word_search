import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/settings_controller.dart';


class SettingsWidget extends StatelessWidget {
  SettingsWidget({super.key});

  // Retrieve or initialize the SettingsController.
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFF7CC82),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                offset: Offset(1, 1),
                blurRadius: 6
              )
            ],
        ),
        padding: const EdgeInsets.all(20),
        width: 300,
        height: 400, // Increased height to avoid bottom overflow.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'settings'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Example: Sound toggle.
            Obx(() => SwitchListTile(
              activeColor: Color(0xff6A80B9),
              title: Text('sound'.tr),
              value: settingsController.isSoundOn.value,
              onChanged: (bool value) {
                settingsController.toggleSound();
              },
            )),
            const SizedBox(height: 20),
            // Language selection.
            Text(
              'language'.tr,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Two vertically stacked TextButtons with selection style.
            Obx(
                  () => Column(
                children: [
                  // Arabic button.
                  TextButton(
                    style: TextButton.styleFrom(
                      elevation: 2,
                      shadowColor: Colors.black,
                      backgroundColor: settingsController.selectedLanguage.value == 'Arabic'
                          ? Color(0xFF6A80B9)
                          : Colors.grey[300],
                      foregroundColor: settingsController.selectedLanguage.value == 'Arabic'
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    onPressed: () {
                      settingsController.setLanguage('Arabic');
                    },
                    child: Text('arabic'.tr),
                  ),
                  const SizedBox(height: 5),
                  // English button.
                  TextButton(
                    style: TextButton.styleFrom(
                      elevation: 2,
                      shadowColor: Colors.black,
                      backgroundColor: settingsController.selectedLanguage.value == 'English'
                          ? Color(0xff6A80B9)
                          : Colors.grey[300],
                      foregroundColor: settingsController.selectedLanguage.value == 'English'
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    onPressed: () {
                      settingsController.setLanguage('English');
                    },
                    child:  Text('english'.tr),
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.back(), // Closes the dialog.
              child: Text('close'.tr, style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}
