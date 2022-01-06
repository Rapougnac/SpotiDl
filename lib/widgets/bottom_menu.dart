export 'bottom_menu.dart';

import 'package:flutter/material.dart';

class BottomMenu extends StatefulWidget {
  const BottomMenu({Key? key}) : super(key: key);

  @override
  _BottomMenuState createState() => _BottomMenuState();
}

class _BottomMenuState extends State<BottomMenu> {
  int _selectedIndex = 0;
  PageController pageController = PageController(initialPage: 0);

  void onTapped(int i) {
    setState(() {
      _selectedIndex = i;
    });
    pageController.animateToPage(
      i,
      duration: const Duration(
        milliseconds: 500,
      ),
      curve: Curves.easeIn,
    );
  }

  void onChanged(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        onPageChanged: onChanged,
        scrollBehavior: const ScrollBehavior(
          androidOverscrollIndicator: AndroidOverscrollIndicator.glow,
        ),
        scrollDirection: Axis.horizontal,
        controller: pageController,
        children: [
          Container(
            color: Colors.red,
          ),
          Container(
            color: Colors.yellow,
          ),
          Container(
            color: Colors.black,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chair_alt),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.h_mobiledata),
            label: 'Home',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        showUnselectedLabels: true,
        onTap: onTapped,
        backgroundColor: const Color(0xFF262626),
      ),
    );
  }
}
