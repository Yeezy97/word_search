
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/views/screens/home_screen.dart';
import 'package:word_search/views/screens/leaderboard_screen.dart';
import 'package:word_search/views/screens/levels_screen.dart';
import 'package:word_search/views/screens/menu_screen.dart';
import 'package:word_search/views/screens/word_game_screen.dart';
import 'package:word_search/controllers/initial_bindings.dart';
import 'package:word_search/models/my_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  Get.put(prefs);

  // Determine starting route
  final firebaseUser = FirebaseAuth.instance.currentUser;
  final hasGuestName = prefs.getString('guest_name') != null;
  final String initialRoute = (firebaseUser != null || hasGuestName)
      ? '/menuScreen'
      : '/';

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue, // ✅ Define primaryColor to avoid null issue
        colorScheme: ColorScheme.light(
          error: Colors.red, // ✅ Define error color
        ),
        // Use Rockwell as the default font for the English locale.
        fontFamily: 'Rockwell',
      ),

      translations: MyTranslations(),
      locale: const Locale('en', 'US'), // initial locale
      fallbackLocale: const Locale('en' , 'US'),
      initialBinding: InitialBindings(),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/', page: ()=> HomeScreen()),
        GetPage(name: '/menuScreen', page: ()=> MenuScreen()),
        GetPage(name: '/wordGameScreen', page: ()=> WordGameScreen()),
        GetPage(name: '/leaderboard', page: () => LeaderboardScreen()),
        GetPage(name: '/levels',     page: () => LevelsScreen()),
      ],
      //home: MenuScreen(),
    ),
  );
}


