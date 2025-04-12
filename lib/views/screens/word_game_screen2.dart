import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/word_game_controller.dart';

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({Key? key}) : super(key: key);

  /// Helper method to build a letter box widget.
  Widget _buildLetter(String letter, double boxSize) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF8BD00), width: 2),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(fontSize: 20, color: Color(0xFFF8BD00)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WordGameController controller = Get.put(WordGameController());

    // Calculate available container width based on screen width and margins.
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth - 80; // subtract horizontal margins

    if (controller.letterPositions.isEmpty) {
      controller.generatePositions(containerWidth);
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155E95), Color(0xFF6BE2FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Top Bar (fixed height).
                SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_back_outlined, size: 32),
                      ),
                      const Text(
                        'Level 1',
                        style: TextStyle(color: Color(0xFFF8BD00), fontSize: 25),
                      ),
                      const SizedBox(),
                    ],
                  ),
                ),
                // Displayed Word Container (fixed height).
                Container(
                  width: screenWidth,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      controller.word,
                      style: const TextStyle(fontSize: 30, color: Color(0xFFF8BD00)),
                    ),
                  ),
                ),
                // Clue Container (fixed height).
                Container(
                  width: screenWidth,
                  height: 120,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white,
                  ),
                  child: const Text(
                    'a professional medical practitioner who treats sick people',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                // Random Letter Container (Expanded to take remaining space).
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    padding: EdgeInsets.all(controller.containerPadding),
                    width: containerWidth,
                    child: Stack(
                      children: List.generate(controller.word.length, (index) {
                        return Positioned(
                          left: controller.letterPositions[index].dx,
                          top: controller.letterPositions[index].dy,
                          child: Obx(() {
                            if (controller.isLetterPlaced[index]) {
                              return const SizedBox.shrink();
                            }
                            return Draggable<int>(
                              data: index,
                              feedback: _buildLetter(controller.word[index], controller.boxSize),
                              childWhenDragging: Container(
                                width: controller.boxSize,
                                height: controller.boxSize,
                                color: Colors.transparent,
                              ),
                              child: _buildLetter(controller.word[index], controller.boxSize),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
                // Drag Targets for letters using a Wrap.
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  width: containerWidth,
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: List.generate(controller.word.length, (targetIndex) {
                      return DragTarget<int>(
                        onWillAcceptWithDetails: (details) =>
                        controller.placedLetters[targetIndex] == null,
                        onAcceptWithDetails: (details) {
                          int sourceIndex = details.data;
                          controller.placeLetter(targetIndex, sourceIndex);
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Container(
                            width: controller.boxSize,
                            height: controller.boxSize,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Obx(
                                  () => Text(
                                controller.placedLetters[targetIndex] ?? '',
                                style: const TextStyle(fontSize: 20, color: Colors.black),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
                // Confirm Button (fixed height).
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  width: 300,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: const Color(0xFFF8BD00),
                  ),
                  child: TextButton(
                    onPressed: () {
                      if (controller.checkWord()) {
                        Get.snackbar("Result", "Correct!");
                      } else {
                        Get.snackbar("Result",
                            "Try again! You formed ${controller.formedWord}");
                        // Reset game state when the answer is wrong.
                        controller.resetGame(containerWidth);
                      }
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontSize: 22, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
