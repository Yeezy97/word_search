
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:word_search/views/screens/home_screen.dart';
import 'package:word_search/views/screens/menu_screen.dart';
import 'package:word_search/views/screens/word_game_screen.dart';
import 'package:word_search/controllers/initial_bindings.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue, // ✅ Define primaryColor to avoid null issue
        colorScheme: ColorScheme.light(
          error: Colors.red, // ✅ Define error color
        ),
      ),
      initialBinding: InitialBindings(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: ()=> HomeScreen()),
        GetPage(name: '/menuScreen', page: ()=> MenuScreen()),
        GetPage(name: '/wordGameScreen', page: ()=> WordGameScreen()),
      ],
      home: MenuScreen(),
    ),
  );
}


