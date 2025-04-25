import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/word_game_controller.dart';
import 'package:word_search/controllers/auth_controller.dart';
import 'package:word_search/controllers/progress_controller.dart';
import 'package:word_search/controllers/local_progress_controller.dart';

class LevelsScreen extends StatelessWidget {
  const LevelsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gameController = Get.find<WordGameController>();
    final authController = Get.find<AuthController>();
    final cloudProgress = Get.find<ProgressController>();
    final guestProgress = Get.find<LocalProgressController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Levels'.tr),
        backgroundColor: const Color(0xFFF8BD00),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!gameController.isInitialized.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final int totalLevels = gameController.totalLevelsCount;
          final int totalChapters = gameController.totalChaptersCount;

          // Determine the highest unlocked level
          int maxUnlocked;
          if (authController.isLoggedIn) {
            maxUnlocked = cloudProgress.level.value;
          } else if (authController.isPlayingGuest) {
            maxUnlocked = guestProgress.level.value;
          } else {
            maxUnlocked = 1;
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: totalChapters,
            itemBuilder: (context, chapterIndex) {
              final int startLevel = chapterIndex * WordGameController.levelsPerChapter + 1;
              final int endLevel = ((chapterIndex + 1) * WordGameController.levelsPerChapter)
                  .clamp(1, totalLevels);
              final levelsInChapter = List.generate(
                endLevel - startLevel + 1,
                    (i) => startLevel + i,
              );

              return ExpansionTile(
                initiallyExpanded: chapterIndex == 0,
                title: Text(
                  'Chapter ${chapterIndex + 1}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: levelsInChapter.length,
                    itemBuilder: (ctx, idx) {
                      final int levelNumber = levelsInChapter[idx];
                      final bool isUnlocked = levelNumber <= maxUnlocked;
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUnlocked
                              ? const Color(0xFFF8BD00)
                              : Colors.grey,
                        ),
                        onPressed: isUnlocked
                            ? () {
                          final int zeroBased = levelNumber - 1;
                          final int chapIdx = zeroBased ~/
                              WordGameController.levelsPerChapter;
                          gameController.prepareChapter(chapIdx);
                          gameController.currentLevelIndex.value = zeroBased;
                          gameController.currentWordIndex.value = 0;
                          gameController.startNextWord();
                          Get.toNamed('/wordGameScreen');
                        }
                            : null,
                        child: Text(
                          '$levelNumber',
                          style: TextStyle(
                            color:
                            isUnlocked ? Colors.black : Colors.white54,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
