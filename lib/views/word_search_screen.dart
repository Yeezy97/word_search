import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_search_controller.dart';
import 'letter_box.dart';
import 'draggable_letter.dart';

class WordSearchScreen extends StatelessWidget {
  final controller = Get.put(WordSearchController());

  WordSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Word Search")),
      body: Column(
        children: [
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.words[controller.currentWordIndex.value].length,
                  (index) => LetterBox(index: index),
            ),
          )),
          Obx(() => SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              children: controller.availableLetters
                  .map((l) => DraggableLetter(letter: l))
                  .toList(),
            ),
          )),
          ElevatedButton(
            onPressed: controller.onConfirm,
            child: Text("Confirm"),
          ),
          ElevatedButton(onPressed: controller.onReset, child: Text("Reset")),
        ],
      ),
    );
  }
}
