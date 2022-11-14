import 'package:crud/pages/accountdetails.dart';
import 'package:crud/pages/updates.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  _onItemPressed(int index) {
    setState(() {
      selectedIndex = index;
      print('the current index: $selectedIndex');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: [
        Updates(),
        const AccountDetails(),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onItemPressed,
        currentIndex: selectedIndex,
        backgroundColor: Colors.pinkAccent,
        selectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Posts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box_rounded), label: 'Account')
        ],
      ),
    );
  }
}
