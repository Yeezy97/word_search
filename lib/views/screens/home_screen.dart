import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:word_search/controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Scaffold(
        body: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors:
              [
                Color(0xFF155E95),
                Color(0xFF6BE2FC)
              ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 20, bottom: 20),
                  child: Image.asset('assets/images/home_logo.png',
                  height: 200,),),
                  Divider(
                    height: 1,
                    color: Colors.black54,
                  ),
                  Container(
                    height: 100,
                    width: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/images/word_search_text.png'))
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.black54,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 40, bottom: 40),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8BD00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                        onPressed: () async {
                          // ask user for a local “guest name”
                          final ctrl = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text('Enter your name'),
                              content: TextField(controller: ctrl, decoration: InputDecoration(hintText: 'Guest name')),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                                TextButton(onPressed: () {
                                  final name = ctrl.text.trim();
                                  if (name.isNotEmpty) {
                                    auth.signUpAsGuest(name);
                                    Navigator.pop(context);
                                    Get.toNamed('/menuScreen');
                                  }
                                }, child: Text('OK')),
                              ],
                            ),
                          );
                          Get.toNamed('/menuScreen');
                        },
                        child:Text(
                          'Play As Guest',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black54,
                          ),
                        ),
                    ),
                  ),
                  Text('Or sign in with',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),),
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () async {
                        await auth.signInWithGoogle();
                        Get.toNamed('/menuScreen');
                      },
                      child:Row(
                        children: [
                          Icon(FontAwesomeIcons.google),
                          Text(
                            'Google',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black54,
                            ),
                          ),
                        ],
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
