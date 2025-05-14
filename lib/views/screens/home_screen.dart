import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/auth_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:word_search/controllers/settings_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final settings = Get.find<SettingsController>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 30),
          width: double.infinity,
          //height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155E95), Color(0xFF6BE2FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Flexible(
                  child: Padding(
                    padding: EdgeInsets.only(top: 20, bottom: 20),
                    child: Image.asset(
                      'assets/images/home_logo.png',
                      height: 200,
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.black54),
                Flexible(
                  child: Container(
                    height: 100,
                    width: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/word_search_text.png'),
                      ),
                    ),
                  ),
                ),
                Divider(height: 1, color: Colors.black54),

                /// LANGUAGE TOGGLE ROW
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => settings.setLanguage('Arabic'),
                            icon: Image.asset(
                              'assets/images/uae_icon.png',
                              width: 45,
                              height: 45,
                            ),
                            iconSize: 15,
                          ),
                          Obx(
                            () => Text(
                              'arabic'.tr,
                              style: TextStyle(
                                color:
                                    settings.selectedLanguage.value == 'Arabic'
                                        ? Color(0xFFF8BD00) // yellow accent
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => settings.setLanguage('English'),
                            icon: Image.asset(
                              'assets/images/uk_icon.png',
                              width: 45,
                              height: 45,
                            ),
                            iconSize: 15,
                          ),
                          Obx(
                            () => Text(
                              'english'.tr,
                              style: TextStyle(
                                color:
                                    settings.selectedLanguage.value == 'English'
                                        ? Color(0xFFF8BD00)
                                        : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8BD00),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: () {
                      final ctrl = TextEditingController();
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          title:  Text('enterName'.tr),
                          content: TextField(
                            controller: ctrl,
                            decoration:  InputDecoration(
                              hintText: 'guestName'.tr,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(), // just close
                              child:  Text('cancel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                final name = ctrl.text.trim();
                                if (name.isNotEmpty) {
                                  auth.signUpAsGuest(name);
                                  Get.back(); // close dialog
                                  Get.toNamed(
                                    '/menuScreen',
                                  ); // navigate only when a valid name was entered
                                }
                              },
                              child:  Text('enter'.tr),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'playAsGuest'.tr,
                      style: TextStyle(fontSize: 20, color: Colors.black54),
                    ),
                  ),
                ),
                Text(
                  'signInWith'.tr,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shadowColor: Colors.black,
                    minimumSize: Size(70, 40),
                  ),
                  onPressed: () async {
                    await auth.signInWithGoogle();
                    if (auth.isLoggedIn) {
                      Get.toNamed('/menuScreen');
                    }
                  },
                  child: SvgPicture.asset(
                    'assets/images/google_logo.svg',
                    height: 24,
                    width: 70,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
