
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:word_search/views/screens/menu_screen.dart';

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
      home: MenuScreen(),
    ),
  );
}


