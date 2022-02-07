export 'home.dart';

import 'package:flutter/material.dart';
import './screens/settings_page.dart';
import 'screens/home_page.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
          const HomePage(),
          Container(
            color: Colors.yellow,
          ),
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        showUnselectedLabels: false,
        onTap: onTapped,
        backgroundColor: const Color.fromARGB(200, 38, 38, 37),
      ),
    );
  }
}
