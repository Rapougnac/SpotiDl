export 'home_page.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spotidl/util/on_submitted.dart';
import 'package:spotidl/util/palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Spotify Downloader'),
        centerTitle: true,
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 45,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Palette.spotifyColors, Colors.black],
              begin: Alignment.bottomRight,
              end: Alignment.topLeft,
              tileMode: TileMode.decal,
            ),
          ),
        ),
      ),
      body: const HomePageBody(),
    );
  }
}

class HomePageBody extends StatelessWidget {
  const HomePageBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SearchBar(),
        SizedBox(height: 20),
      ],
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(top: 45),
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.search),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              autocorrect: false,
              onSubmitted: (s) async {
                _handleProgress(s);
                await onSubmitted(s, context);
                _stopProgress();
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for a song',
              ),
            ),
          ),
          if (loading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _handleProgress(String s) {
    setState(
      () => loading = true,
    );
  }

  void _stopProgress() {
    setState(
      () => loading = false,
    );
  }
}
