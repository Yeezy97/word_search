import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/letter_model.dart';
import '../controllers/word_search_controller.dart';

class DraggableLetter extends StatelessWidget {
  final LetterModel letter;
  const DraggableLetter({super.key, required this.letter});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WordSearchController>(
      builder: (controller) {
        bool isAvailable = controller.availableLetters.contains(letter);

        return isAvailable
            ? Positioned(
          left: controller.letterPositions[letter.uniqueKey]!.dx,
          top: controller.letterPositions[letter.uniqueKey]!.dy,
          child: Draggable<String>(
            data: letter.uniqueKey,
            feedback: Material(
              color: Colors.transparent,
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(letter.letter, style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3, // Makes the original letter fade while dragging
              child: Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(letter.letter, style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            ),
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(letter.letter, style: TextStyle(fontSize: 24, color: Colors.white)),
            ),
          ),
        )
            : SizedBox(); // Hide letter if it's no longer available
      },
    );
  }
}
