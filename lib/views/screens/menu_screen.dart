import 'package:flutter/material.dart';
import 'package:word_search/constants.dart';
import 'package:word_search/controllers/navigation_controller.dart';
import 'package:get/get.dart';
import 'package:word_search/views/widgets/settings_widget.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.find<NavigationController>();
    return Scaffold(
      body: SafeArea(
          child: Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: screenColor
            ),
            child: Padding(padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
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
                        Text('Hello Guest!', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white
                        ),),
                        Icon(Icons.logout, size: 30,)
                      ],
                    ),
                  ),
                  Container(  /// Score/Rank
                    margin: EdgeInsets.symmetric(vertical: 20),
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
                            Text('--', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF8BD00)),),
                            Text('--', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF8BD00)),),
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
                    child: TextButton(onPressed: (){}, child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text('leaderboards'.tr,style: TextStyle(fontSize: 25, color: Color(0xFFF8BD00)),),
                        Icon(Icons.leaderboard, color: Color(0xFFF8BD00), size: 25,),
                      ],
                    )),
                  ),
                   /// LOGO
                  Padding(padding: EdgeInsets.only(top: 20, bottom: 20),
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
                    margin: EdgeInsets.symmetric(vertical: 10),
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
