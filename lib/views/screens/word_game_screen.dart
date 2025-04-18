import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:word_search/controllers/word_game_controller.dart';

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({Key? key}) : super(key: key);

  Widget _buildLetterBox(String letter, double size) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFF8BD00), width: 2),
    ),
    child: Center(child: Text(letter, style: const TextStyle(fontSize: 20, color: Color(0xFFF8BD00)))),
  );

  @override
  Widget build(BuildContext context) {
    final navController  = Get.find<NavigationController>();
    final gameController = Get.put(WordGameController());
    final screenWidth    = MediaQuery.of(context).size.width;
    final letterAreaWidth= screenWidth - 80;

    // Layout letters if first build
    if (gameController.letterBoxPositions.isEmpty) {
      gameController.generateLetterPositions(letterAreaWidth);
    }

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155E95), Color(0xFF6BE2FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Top bar
                    SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_outlined, size: 32),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: Text('confirm'.tr),
                                  content: Text('back_confirmation'.tr),
                                  actions: [
                                    TextButton(onPressed: () => Get.back(), child: Text('no'.tr)),
                                    TextButton(onPressed: () {
                                      Get.back();
                                      navController.navigateTo('/menuScreen');
                                    }, child: Text('yes'.tr)),
                                  ],
                                ),
                              );
                            },
                          ),
                          Obx(() => Text(
                            'Level ${gameController.currentLevelIndex.value + 1}   '
                                'Word  ${gameController.currentWordIndex.value  + 1}',
                            style: const TextStyle(color: Color(0xFFF8BD00), fontSize: 20),
                          )),
                        ],
                      ),
                    ),

                    // Displayed word (masked/unmasked)
                    Container(
                      width: screenWidth,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Obx(() => Text(
                          gameController.maskedDisplayedWord,
                          style: const TextStyle(fontSize: 30, color: Color(0xFFF8BD00)),
                        )),
                      ),
                    ),

                    // Definition
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                        width: screenWidth,
                        height: 120,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Obx(() => Text(
                          gameController.displayedDefinition.value,
                          style: const TextStyle(fontSize: 15),
                        )),
                      ),
                    ),

                    // Draggable letters
                    Expanded(
                      child: Obx(() {
                        final length = gameController.sanitizedWord.length;
                        if (gameController.letterBoxPositions.length != length) {
                          gameController.generateLetterPositions(letterAreaWidth);
                          return const SizedBox();
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          padding: EdgeInsets.all(gameController.letterContainerPadding),
                          width: letterAreaWidth,
                          child: Stack(
                            children: List.generate(length, (i) {
                              final pos = gameController.letterBoxPositions[i];
                              return Positioned(
                                left: pos.dx,
                                top: pos.dy,
                                child: Obx(() {
                                  if (gameController.isLetterBoxPlaced[i]) return const SizedBox();
                                  return Draggable<int>(
                                    data: i,
                                    feedback: _buildLetterBox(gameController.sanitizedWord[i], gameController.letterBoxSize),
                                    childWhenDragging: SizedBox(width: gameController.letterBoxSize, height: gameController.letterBoxSize),
                                    child: GestureDetector(
                                      onDoubleTap: () => gameController.autoPlaceLetterBox(i),
                                      child: _buildLetterBox(gameController.sanitizedWord[i], gameController.letterBoxSize),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        );
                      }),
                    ),

                    // Drop targets
                    Obx(() {
                      final length = gameController.sanitizedWord.length;
                      if (gameController.lettersInTargets.length != length) {
                        gameController.resetPlacementState();
                        gameController.generateLetterPositions(letterAreaWidth);
                        return const SizedBox();
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        width: letterAreaWidth,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            alignment: WrapAlignment.center,
                            children: List.generate(length, (ti) {
                              return GestureDetector(
                                onDoubleTap: () => gameController.removeLetterFromTarget(ti),
                                child: DragTarget<int>(
                                  onWillAcceptWithDetails: (_) => gameController.lettersInTargets[ti] == null,
                                  onAcceptWithDetails: (details) => gameController.placeLetterInTarget(ti, details.data),
                                  builder: (_, __, ___) {
                                    return Obx(() => AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      width: gameController.letterBoxSize,
                                      height: gameController.letterBoxSize,
                                      decoration: BoxDecoration(
                                        color: gameController.targetHighlightColor.value,
                                        border: Border.all(color: Colors.white, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        gameController.lettersInTargets[ti] ?? '',
                                        style: const TextStyle(fontSize: 20, color: Colors.black),
                                      ),
                                    ));
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    }),

                    // Confirm button
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BD00),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0,1), blurRadius: 1)],
                      ),
                      child: TextButton(
                        onPressed: gameController.confirmUserAnswer,
                        child: Text('confirm'.tr, style: const TextStyle(fontSize: 22, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              ),

              // Level‑complete dialog
              GetX<WordGameController>(builder: (_) {
                if (gameController.levelCompleted.value) {
                  gameController.levelCompleted.value = false;
                  Future.microtask(() {
                    Get.dialog(
                      AlertDialog(
                        title: Text('well_done'.tr),
                        content: Text('level_complete'.trParams({
                          'level': '${gameController.currentLevelIndex.value + 1}'
                        })),
                        actions: [
                          TextButton(onPressed: () {
                            Get.back();
                            gameController.currentWordIndex.value = 0;
                            gameController.startNextWord();
                            gameController.levelCompleted.value = false;
                          }, child: Text('resetLevel'.tr)),
                          TextButton(onPressed: () {
                            Get.back();
                            gameController.currentLevelIndex.value++;
                            gameController.currentWordIndex.value = 0;
                            gameController.startNextWord();
                            gameController.levelCompleted.value = false;
                          }, child: Text('nextLevel'.tr)),
                        ],
                      ),
                    );
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
