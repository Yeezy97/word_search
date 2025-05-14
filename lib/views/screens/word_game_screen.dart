import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/word_game_controller.dart';

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({Key? key}) : super(key: key);

  Widget _buildLetterBox(String letter, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF8BD00), width: 2),
      ),
      child: Center(
        child: Text(letter, style: const TextStyle(fontSize: 20, color: Color(0xFFF8BD00))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    final gameController = Get.put(WordGameController());
    final screenWidth = MediaQuery.of(context).size.width;
    final letterAreaWidth = screenWidth - 80;

    // Lay out letters once when the container width is known
    if (gameController.letterBoxPositions.isEmpty) {
      gameController.generateLetterPositions(letterAreaWidth);
    }

    if (!gameController.isInitialized.value) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
                    // Top Bar
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
                                    TextButton(
                                      onPressed: () {
                                        Get.back(); // close the dialog
                                        Get.offNamed('/menuScreen');
                                      },
                                      child: Text('yes'.tr),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          Obx(() {
                            final chapterNumber = gameController.currentChapterNumber;
                            final levelNumber = gameController.currentLevelIndex.value + 1;
                            final wordNumber = gameController.currentWordIndex.value + 1;
                            return Text(
                              '${'chapter'.tr} $chapterNumber - ${'level'.tr} $levelNumber - ${'word'.tr} $wordNumber',
                              style: const TextStyle(color: Color(0xFFF8BD00), fontSize: 20),
                            );
                          }),
                        ],
                      ),
                    ),

                    // Displayed Word
                    Stack(
                      children: [
                        Container(
                          width: screenWidth,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Obx(() => Text(
                              gameController.maskedDisplayedWord,
                              style: const TextStyle(fontSize: 30, color: Color(0xFFF8BD00)),
                            )),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0, right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)), // match your container’s background
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'word'.tr,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Definition (RTL)
                    Stack(
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Container(
                            width: screenWidth,
                            height: 120,
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            child: Obx(() => SingleChildScrollView(
                              child: Text(
                                gameController.displayedDefinition.value,
                                style: const TextStyle(fontSize: 15),
                              ),
                            )),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 0, right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'definition'.tr,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Randomly positioned letter boxes
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        width: letterAreaWidth,
                        height: gameController.boxContainerHeight,
                        padding: EdgeInsets.all(gameController.boxContainerPadding),
                        child: Obx(() {
                          final letterCount = gameController.sanitizedWord.length;
                          // ensure positions match count
                          if (gameController.letterBoxPositions.length != letterCount) {
                            gameController.generateLetterPositions(letterAreaWidth);
                            return const SizedBox();
                          }
                          return Stack(
                            children: List.generate(letterCount, (i) {
                              // wrap each in its own Obx
                              return Obx(() {
                                // if already placed, draw nothing
                                if (gameController.isLetterBoxPlaced[i]) {
                                  return const SizedBox();
                                }
                                final pos = gameController.letterBoxPositions[i];
                                return Positioned(
                                  left: pos.dx,
                                  top: pos.dy,
                                  child: Draggable<int>(
                                    data: i,
                                    feedback: _buildLetterBox(
                                      gameController.sanitizedWord[i],
                                      gameController.letterBoxSize,
                                    ),
                                    childWhenDragging: SizedBox(
                                      width: gameController.letterBoxSize,
                                      height: gameController.letterBoxSize,
                                    ),
                                    child: GestureDetector(
                                      onDoubleTap: () => gameController.autoPlaceLetterBox(i),
                                      child: _buildLetterBox(
                                        gameController.sanitizedWord[i],
                                        gameController.letterBoxSize,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }),
                          );
                        }),
                      ),
                    ),

                    // Drop targets & confirm button
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
                                      duration: const Duration(milliseconds: 400),
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

                    // Confirm button (unchanged)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8BD00),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 1)],
                      ),
                      child: TextButton(
                        onPressed: gameController.confirmUserAnswer,
                        child: Text('confirm'.tr, style: const TextStyle(fontSize: 22, color: Colors.black)),
                      ),
                    ),

                  ],
                ),
              ),

              // Level-complete dialog
              GetX<WordGameController>(
                builder: (_) {
                  if (gameController.levelCompleted.value && !(Get.isDialogOpen ?? false)) {
                    Future.microtask(() {
                      gameController.levelCompleted.value = false;
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          backgroundColor: Color(0xFFF7CC82),
                          elevation: 5,
                          shadowColor: Colors.black54,
                          title: Text('well_done'.tr),
                          content: Text('${'level_complete'.tr} ${gameController.currentLevelIndex.value + 1}'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back();
                                gameController.currentWordIndex.value = 0;
                                gameController.startNextWord();
                              },
                              child: Text('resetLevel'.tr),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                // advance to next level
                                gameController.currentLevelIndex.value++;
                                // persist that new level
                                if (gameController.authController.isLoggedIn) {
                                  gameController.cloudProgressController.updateProgress(
                                      newLevel: gameController.currentLevelIndex.value + 1
                                  );
                                } else if (gameController.authController.isPlayingGuest) {
                                  gameController.guestProgressController.updateLocalProgress(
                                      newLevel: gameController.currentLevelIndex.value + 1
                                  );
                                }
                                gameController.currentWordIndex.value = 0;
                                gameController.startNextWord();
                              },
                              child: Text('nextLevel'.tr),
                            ),
                          ],
                        ),
                      );
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
