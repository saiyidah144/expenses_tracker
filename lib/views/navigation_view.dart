import 'package:expenses_tracker/views/reward_view.dart';
import 'package:expenses_tracker/views/statistic_view.dart';
import 'package:flutter/material.dart';
import 'history_view.dart';
import 'package:expenses_tracker/views/profile_view.dart';
import 'home_view.dart';


// TO VIEW THE  BOTTOM NAVIGATION AND RANGKA APP
class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  final primaryColor = const Color(0xFFCE93D8);
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomePage(),
    HistoryPage(),
    StatisticsPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EXPTracker"),
        backgroundColor: primaryColor,
        actions: <Widget>[
          IconButton(icon: Icon(Icons.lightbulb_outline), onPressed: () {
showAlertDialog(context);
          }),
        ],
      ),
      body: _children[_currentIndex],
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.card_giftcard),
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RewardView()));
        },
      ),
      bottomNavigationBar: BottomNavigationBar(

          onTap: onTabTapped,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
              icon: new Icon(Icons.home),
              title: new Text("Home"),
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.history),
              title: new Text("History"),
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.equalizer),
              title: new Text("Statistics"),
              backgroundColor: primaryColor,
            ),
            BottomNavigationBarItem(
              icon: new Icon(Icons.account_circle),
              title: new Text("Account"),
              backgroundColor: primaryColor,
            ),
          ]
      ),
    );
  }
  showAlertDialog (BuildContext context){

    // set up the buttons



    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please UPDATE your spending before 15th of next month to get the chance to GRAB the REWARD !"),
backgroundColor: Colors.orange[300],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}