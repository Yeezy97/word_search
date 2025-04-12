import 'package:flutter/material.dart';

class WordGameScreen extends StatelessWidget {
  const WordGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF155E95), Color(0xFF6BE2FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_back_outlined, size: 32),
                    ),
                    Text(
                      'Level 1',
                      style: TextStyle(color: Color(0xFFF8BD00), fontSize: 25),
                    ),
                    SizedBox(),
                  ],
                ),
                Container(width: 400, height: 50, margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10), decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white,
                ),child: Center(child: Text('Doctor', style: TextStyle(fontSize: 30, color: Color(0xFFF8BD00)),),),),
                Container(
                  width: 400, height: 120, padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5), margin: EdgeInsets.symmetric(horizontal: 40,vertical: 10), decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white
                ),
                  child: Text('a professional medical practitioner who treats sick people', style: TextStyle(fontSize: 15),),
                ),
                Container( // Column for the randomly placed letter boxes
                  margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  width: 400,
                  height: 210,
                ),
                Divider(),
                Container( // Container for the drag targets of the letters
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  height: 60,
                  width: 400,
                  child: Row(
                    children: [],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  width: 300,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xFFF8BD00),
                  ),
                  child: TextButton(onPressed: (){}, child: Text('Confirm', style: TextStyle(fontSize: 22, color: Colors.black),)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
