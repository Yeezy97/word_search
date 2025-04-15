import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:word_search/controllers/word_game_controller.dart';

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({Key? key}) : super(key: key);

  /// Returns a widget for a single letter box.
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
    final NavigationController navigationController = Get.find<NavigationController>();
    final WordGameController controller = Get.put(WordGameController());
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth - 80; // accounting for horizontal margins

    // Ensure letter positions are generated for the current word.
    if (controller.letterPositions.isEmpty) {
      controller.generatePositions(containerWidth);
    }

    // Use a post-frame callback to show the level-complete dialog if needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.levelCompleted.value) {
        Get.dialog(
          AlertDialog(
            title: Text('You finished level ${controller.currentLevel.value + 1}'),
            content: const Text('Choose an option:'),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.resetLevel(containerWidth);
                },
                child: const Text('Reset Level'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.nextLevel(containerWidth);
                },
                child: const Text('Next Level'),
              ),
            ],
          ),
        );
        controller.levelCompleted.value = false;
      }
    });

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
          child: Stack(
            children: [
              // Main content column.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Top Bar with back button and level-word info.
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirm'),
                                  content: const Text(
                                    'Are you sure you want to go back to menu screen?\nCurrent level progress will not be saved.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        navigationController.navigateTo('/menuScreen');
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_back_outlined, size: 32),
                          ),
                          Obx(() => Text(
                            'Level ${controller.currentLevel.value + 1} - Word ${controller.currentWordIndex.value + 1}',
                            style: const TextStyle(color: Color(0xFFF8BD00), fontSize: 25),
                          )),
                          const SizedBox(),
                        ],
                      ),
                    ),
                    // Displayed Word Container.
                    Container(
                      width: screenWidth,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Obx(() => Text(
                          controller.currentWord,
                          style: const TextStyle(fontSize: 30, color: Color(0xFFF8BD00)),
                        )),
                      ),
                    ),
                    // Clue Container.
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
                    // Draggable Letters Container.
                    Expanded(
                      flex: 1,
                      child: Obx(() {
                        if (controller.letterPositions.length != controller.currentWord.length) {
                          controller.generatePositions(containerWidth);
                          return Container();
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          padding: EdgeInsets.all(controller.containerPadding),
                          width: containerWidth,
                          child: Stack(
                            children: List.generate(controller.currentWord.length, (index) {
                              return Positioned(
                                left: controller.letterPositions[index].dx,
                                top: controller.letterPositions[index].dy,
                                child: Obx(() {
                                  if (controller.isLetterPlaced[index]) {
                                    return const SizedBox.shrink();
                                  }
                                  return Draggable<int>(
                                    data: index,
                                    feedback: _buildLetter(controller.currentWord[index], controller.boxSize),
                                    childWhenDragging: Container(
                                      width: controller.boxSize,
                                      height: controller.boxSize,
                                      color: Colors.transparent,
                                    ),
                                    child: GestureDetector(
                                      onDoubleTap: () {
                                        // Auto-place letter on double tap.
                                        controller.autoPlaceLetter(index);
                                      },
                                      child: _buildLetter(controller.currentWord[index], controller.boxSize),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                    // Drag Targets Container.
                    Obx(() {
                      if (controller.placedLetters.length != controller.currentWord.length) {
                        controller.initWord();
                        controller.generatePositions(containerWidth);
                        return Container();
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        width: containerWidth,
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          alignment: WrapAlignment.center,
                          children: List.generate(controller.currentWord.length, (targetIndex) {
                            return GestureDetector(
                              onDoubleTap: () {
                                // Remove placed letter via double tap.
                                controller.removeLetter(targetIndex);
                              },
                              child: DragTarget<int>(
                                onWillAcceptWithDetails: (details) =>
                                controller.placedLetters[targetIndex] == null,
                                onAcceptWithDetails: (details) {
                                  int sourceIndex = details.data;
                                  controller.placeLetter(targetIndex, sourceIndex);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Obx(() => AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    width: controller.boxSize,
                                    height: controller.boxSize,
                                    decoration: BoxDecoration(
                                      color: controller.targetBoxColor.value,
                                      border: Border.all(color: Colors.white, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      controller.placedLetters[targetIndex] ?? '',
                                      style: const TextStyle(fontSize: 20, color: Colors.black),
                                    ),
                                  ));
                                },
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                    // Confirm Button.
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
                          controller.confirmWord(containerWidth);
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
              // The following Obx watches the levelCompleted flag.
              // When true, it triggers a dialog via a Future.microtask.
              Obx(() {
                if (controller.levelCompleted.value) {
                  Future.microtask(() {
                    Get.dialog(
                      AlertDialog(
                        title: Text('You finished level ${controller.currentLevel.value + 1}'),
                        content: const Text('Choose an option:'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back(); // Close dialog.
                              controller.resetLevel(containerWidth);
                            },
                            child: const Text('Reset Level'),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back(); // Close dialog.
                              controller.nextLevel(containerWidth);
                            },
                            child: const Text('Next Level'),
                          ),
                        ],
                      ),
                    );
                    // Reset the flag so dialog shows only once.
                    controller.levelCompleted.value = false;
                  });
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

