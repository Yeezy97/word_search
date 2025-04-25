import 'package:flutter/material.dart';
import 'package:word_search/constants.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:get/get.dart';
import 'package:word_search/views/widgets/settings_widget.dart';
import 'package:word_search/controllers/difficulty_controller.dart';
import 'package:word_search/controllers/auth_controller.dart';
import 'package:word_search/controllers/progress_controller.dart';
import 'package:word_search/controllers/local_progress_controller.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final cloud = Get.find<ProgressController>();
    final local = Get.find<LocalProgressController>();
    final NavigationController navigationController = Get.find<NavigationController>();
    final DifficultyController difficultyController = Get.find<DifficultyController>();
    return Scaffold(
      body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: screenColor
            ),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox( /// USER INFO CONTAINER
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.account_circle_rounded, color: Colors.white,size: 45, ),
                        Obx(() {
                          if (auth.isPlayingGuest) {
                            return Text(
                              'Hello ${auth.guestName ?? 'Guest'}!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          } else if (auth.isLoggedIn) {
                            return Text(
                              'Hello ${auth.firebaseUser.value!.displayName ?? 'User'}!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          } else {
                            return Text(
                              'Hello Guest!',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            );
                          }
                        }),
                        IconButton(onPressed: (){
                          auth.signOut();
                          Get.offAllNamed('/');
                          }, icon: Icon(Icons.logout, size: 30,)),
                      ],
                    ),
                  ),
                  Container(  /// Score/Rank
                    margin: EdgeInsets.symmetric(vertical: 5),
                    width: double.infinity,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        width: 1,
                        color: Colors.white
                      )
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('score'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                            Text('rank'.tr, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Score:
                            Obx(() => Text(
                              auth.isLoggedIn
                                  ? cloud.score.value.toString()
                                  : local.score.value.toString(),
                              style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Color(0xFFF8BD00)),
                            )),
                            // Rank: only for Google users
                            Obx(() => Text(
                              auth.isLoggedIn
                                  ? (cloud.rank.value > 0 ? cloud.rank.value.toString() : '--')
                                  : '--',
                              style: TextStyle(fontSize:20, fontWeight: FontWeight.bold, color: Color(0xFFF8BD00)),
                            )),
                          ],
                        ),

                      ],
                    ),
                  ),
                  Container( /// LEADERBOARDS BUTTON
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white,
                    ),
                    child: TextButton(onPressed: (){
                      navigationController.navigateTo('/leaderboard');
                    }, child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('leaderboards'.tr,style: TextStyle(fontSize: 25, color: Color(0xFFF8BD00)),),
                        Icon(Icons.leaderboard, color: Color(0xFFF8BD00), size: 25,),
                      ],
                    )),
                  ),
                   /// LOGO
                  Padding(padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Image.asset('assets/images/home_logo.png',
                      height: 140,),),
                  Container( /// MENU BUTTONS
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF8BD00),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 1
                          )
                        ]
                    ),
                    child: TextButton(onPressed: (){},
                        child: Text('continue'.tr, style: TextStyle(
                          fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold,
                        ),)
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF8BD00),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 1
                        )
                      ]
                    ),
                    child: TextButton(onPressed: (){
                      navigationController.navigateTo('/wordGameScreen');
                    },
                        child: Text('new game'.tr, style: TextStyle(
                          fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold,
                        ),)
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFFF8BD00),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 1
                          )
                        ]
                    ),
                    child: TextButton(
                      onPressed: () {
                        navigationController.navigateTo('/levels');
                      },

                      child: Text('levels'.tr, style: TextStyle(fontSize:25,color:Colors.black,fontWeight:FontWeight.bold)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xFFF8BD00),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 1
                          )
                        ]
                    ),
                    child: TextButton(
                      onPressed: () {
                        
                        Widget buildOption(String title, String subtitle, String value) {
                          return Obx(() {
                            final isSelected = difficultyController.selectedDifficulty.value == value;
                            return GestureDetector(
                              onTap: () => difficultyController.selectDifficulty(value),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  border: Border.all(color: isSelected ? Colors.blue : Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(title, style: TextStyle(fontSize: 18))),
                                        if (isSelected) const Icon(Icons.check, color: Colors.blue),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            );
                          });
                        }

                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height: MediaQuery.of(context).size.height * 0.8,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('difficulty'.tr,
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 20),
                                      buildOption(
                                        'Progressive Difficulty',
                                        'Progressive difficulty means the player will experience more challenges as he progresses through the levels',
                                        'Progressive Difficulty',
                                      ),
                                      buildOption(
                                        'Beginner',
                                        'Suitable for language learners with little background in Arabic',
                                        'Beginner',
                                      ),
                                      buildOption(
                                        'Intermediate',
                                        'Moderate difficulty with some hidden letters in the suggested words',
                                        'Intermediate',
                                      ),
                                      buildOption(
                                        'Challenger',
                                        'For players who prefer a challenging experience where word definitions and the majority of the word letters are hidden',
                                        'Challenger',
                                      ),
                                      const SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => Get.back(),
                                          child: Text('close'.tr),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Text('difficulty'.tr,
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color(0xFFF8BD00),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0),
                              blurRadius: 1
                          )
                        ]
                    ),
                    child: TextButton(onPressed: (){
                      Get.dialog(SettingsWidget());
                    },
                        child: Text('settings'.tr, style: TextStyle(
                          fontSize: 25,color: Colors.black, fontWeight: FontWeight.bold,
                        ),)
                    ),
                  ),
                ],
              ),
            ),
          )
      ),
    );
  }
}
