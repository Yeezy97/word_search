import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/word_search_controller.dart';

class LetterBox extends StatelessWidget {
  final int index;
  const LetterBox({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WordSearchController>(
      builder: (controller) {
        return DragTarget<String>(
          onWillAcceptWithDetails: (details) {
            return controller.selectedLetters[index] == null;
          },
          onAcceptWithDetails: (details) {
            String letter = details.data;
            if (controller.selectedLetters[index] == null) {
              controller.selectedLetters[index] = letter;
              controller.availableLetters.removeWhere((l) => l.uniqueKey == letter);
              controller.update();
            }
          },
          builder: (context, candidateData, rejectedData) {
            return GestureDetector(
              onTap: () {
                if (controller.selectedLetters[index] != null) {
                  controller.returnLetter(controller.selectedLetters[index]!);
                  controller.selectedLetters[index] = null;
                  controller.update();
                }
              },
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                margin: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: controller.selectedLetters[index] != null
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.transparent,
                ),
                child: Text(
                  controller.selectedLetters[index]?.split('_')[0] ?? "_",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

