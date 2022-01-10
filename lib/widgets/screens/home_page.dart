export 'home_page.dart';

import 'package:flutter/material.dart';
import 'package:spotidl/util/get_infos.dart';
import 'package:spotidl/util/on_submitted.dart';
import 'package:spotidl/util/palette.dart';
import 'package:spotify/spotify.dart' show Track;

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
      children: [
        if (SearchBar.of(context)?.thumbnail != null)
          SearchBar.of(context)!.thumbnail!,
        const SearchBar(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();

  Image? getThumbnail() => _SearchBarState().thumbnail;

  static _SearchBarState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SearchBarState>();
}

class _SearchBarState extends State<SearchBar> {
  bool loading = false;
  Image? thumbnail;
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
      child: Center(
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.search),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    onSubmitted: (s) async {
                      _handleProgress(s);
                      final infos = await getInfos(s);
                      if (infos != null) {
                        handleInfos((infos as Track).album!.images!.first.url!);
                      }
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
            if (thumbnail != null) thumbnail!
          ],
        ),
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

  void handleInfos(String img) {
    setState(
      () => thumbnail = Image.network(img),
    );
  }
}
