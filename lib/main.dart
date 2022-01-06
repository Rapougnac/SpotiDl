import 'package:flutter/material.dart';
import 'util/palette.dart';
import 'widgets/bottom_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Downloader',
      theme: ThemeData(
        primaryColor: Colors.black,
        canvasColor: Colors.black,
        primarySwatch: Palette.spotifyColors,
        fontFamily: 'Montserrat',
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        scaffoldBackgroundColor: const Color(0xFF121212),
        iconTheme: const IconThemeData().copyWith(color: Colors.white),
        drawerTheme: const DrawerThemeData(),
        textTheme: TextTheme(
          headline2: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headline4: TextStyle(
            fontSize: 12,
            color: Colors.green[300],
            fontWeight: FontWeight.w500,
            letterSpacing: 2,
          ),
          bodyText1: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          bodyText2: TextStyle(
            color: Colors.green[300],
            letterSpacing: 1,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Shell extends StatelessWidget {
  const Shell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [],
      ),
    );
  }
}
