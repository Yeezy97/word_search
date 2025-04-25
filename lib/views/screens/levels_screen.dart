// … other imports …
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
    final gameController   = Get.find<WordGameController>();
    final authController   = Get.find<AuthController>();
    final cloudProgress    = Get.find<ProgressController>();
    final guestProgress    = Get.find<LocalProgressController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('levels'.tr),
        backgroundColor: const Color(0xFFF8BD00),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!gameController.isInitialized.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalLevels   = gameController.totalLevelsCount;
          final totalChapters = gameController.totalChaptersCount;

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
              final startLevel = chapterIndex * WordGameController.levelsPerChapter + 1;
              final endLevel = ((chapterIndex + 1) * WordGameController.levelsPerChapter)
                  .clamp(1, totalLevels);
              final levelsInChapter = List.generate(
                endLevel - startLevel + 1,
                    (i) => startLevel + i,
              );

              return ExpansionTile(
                initiallyExpanded: chapterIndex == 0,
                title: Text(
                  'chapter'.trParams({'num': '${chapterIndex + 1}'}),
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black
                  ),
                ),
                childrenPadding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: levelsInChapter.length,
                    itemBuilder: (ctx, idx) {
                      final levelNumber = levelsInChapter[idx];
                      final isUnlocked  = levelNumber <= maxUnlocked;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUnlocked ? const Color(0xFFF8BD00) : Colors.grey,
                          side: BorderSide(color: Colors.grey[800]!, width: 1),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),   // ← CHANGED: square corners
                          ),
                        ),
                        onPressed: isUnlocked
                            ? () {
                          final zeroBased = levelNumber - 1;
                          final chapIdx = zeroBased ~/ WordGameController.levelsPerChapter;
                          gameController.prepareChapter(chapIdx);
                          gameController.currentLevelIndex.value = zeroBased;
                          gameController.currentWordIndex.value = 0;
                          gameController.startNextWord();
                          Get.toNamed('/wordGameScreen');
                        }
                            : null,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              '$levelNumber',
                              style: TextStyle(
                                  color: isUnlocked ? Colors.black : Colors.white54,
                                  fontSize: 16, fontWeight: FontWeight.bold
                              ),
                            ),
                            if (!isUnlocked)
                              const Positioned(
                                top: 4,
                                child: Icon(Icons.lock, size: 16, color: Colors.white70),
                              ),
                          ],
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
