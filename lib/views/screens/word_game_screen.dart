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
    final navigationController = Get.find<NavigationController>();
    final controller = Get.put(WordGameController());
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 80;

    // Ensure letter positions are generated for the current word.
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
          child: Stack(
            children: [
              // Main content column
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Top bar
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: Text('confirm'.tr),
                                  content: Text('back_confirmation'.tr),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: Text('no'.tr),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Get.back();
                                        navigationController.navigateTo('/menuScreen');
                                      },
                                      child: Text('yes'.tr),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.arrow_back_outlined, size: 32),
                          ),
                          Obx(() => Text(
                            'Level ${controller.currentLevel.value + 1} - Word ${controller.currentWordIndex.value + 1}',
                            style: const TextStyle(
                                color: Color(0xFFF8BD00), fontSize: 25),
                          )),
                          const SizedBox(width: 32),
                        ],
                      ),
                    ),

                    // Displayed Word
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
                          style: const TextStyle(
                              fontSize: 30, color: Color(0xFFF8BD00)),
                        )),
                      ),
                    ),

                    // Clue
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

                    // Draggable Letters
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
                            children: List.generate(
                                controller.currentWord.length, (index) {
                              return Positioned(
                                left: controller.letterPositions[index].dx,
                                top: controller.letterPositions[index].dy,
                                child: Obx(() {
                                  if (controller.isLetterPlaced[index]) {
                                    return const SizedBox.shrink();
                                  }
                                  return Draggable<int>(
                                    data: index,
                                    feedback: _buildLetter(
                                        controller.currentWord[index],
                                        controller.boxSize),
                                    childWhenDragging: Container(
                                      width: controller.boxSize,
                                      height: controller.boxSize,
                                      color: Colors.transparent,
                                    ),
                                    child: GestureDetector(
                                      onDoubleTap: () {
                                        controller.autoPlaceLetter(index);
                                      },
                                      child: _buildLetter(
                                          controller.currentWord[index],
                                          controller.boxSize),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        );
                      }),
                    ),

                    // Drag Targets
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
                          children: List.generate(
                              controller.currentWord.length, (targetIndex) {
                            return GestureDetector(
                              onDoubleTap: () {
                                controller.removeLetter(targetIndex);
                              },
                              child: DragTarget<int>(
                                onWillAcceptWithDetails: (details) =>
                                controller.placedLetters[targetIndex] == null,
                                onAcceptWithDetails: (details) {
                                  controller.placeLetter(
                                      targetIndex, details.data);
                                },
                                builder: (context, candidateData, rejectedData) {
                                  return Obx(() => AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    width: controller.boxSize,
                                    height: controller.boxSize,
                                    decoration: BoxDecoration(
                                      color: controller.targetBoxColor.value,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      controller.placedLetters[targetIndex] ?? '',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          color: Colors.black),
                                    ),
                                  ));
                                },
                              ),
                            );
                          }),
                        ),
                      );
                    }),

                    // Confirm Button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: const Color(0xFFF8BD00),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0, 1),
                              blurRadius: 1)
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          controller.confirmWord(containerWidth);
                        },
                        child: Text(
                          'confirm'.tr,
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Reactive dialog trigger
              GetX<WordGameController>(
                builder: (_) {
                  if (controller.levelCompleted.value) {
                    Future.microtask(() {
                      Get.dialog(
                        AlertDialog(
                          title: Text('well_done'.tr),
                          content: Text(
                            'level_complete'.trParams({'level': '${controller.currentLevel.value + 1}'}),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.resetLevel(containerWidth);
                              },
                              child: Text('resetLevel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                controller.nextLevel(containerWidth);
                              },
                              child: Text('nextLevel'.tr),
                            ),
                          ],
                        ),
                      );
                      controller.levelCompleted.value = false;
                    });
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
