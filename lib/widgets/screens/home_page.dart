export 'home_page.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spotidl/util/palette.dart';
import 'package:spotify/spotify.dart';
import 'package:spotidl/crendentials.dart' as creds;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

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

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

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
              onSubmitted: (song) async {
                if (song.isEmpty) return;

                final stream = await toStream(song);
                final infos = await getInfos(song);
                if (infos is Track) {
                  // await Directory(safeFileName(tr));
                  final file = File('D:\\' + safeFileName(infos.name!) + '.opus');
                  final fileStream = file.openWrite();
                  await stream.pipe(fileStream);
                  await fileStream.flush();
                  await fileStream.close();
                }
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for a song',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Stream<List<int>>> toStream(String url) async {
  final credentials = SpotifyApiCredentials(
      creds.spotifyInfos['clientId'], creds.spotifyInfos['clientSecret']);
  final spotify = SpotifyApi(credentials);
  final reg = RegExp(
      r'https?:\/\/(?:embed\.|open\.)(?:spotify\.com\/)(?:(track|playlist|album)\/|\?uri=spotify:(track|playlist|album):)((\w|-){22})');
  if (reg.hasMatch(url)) {
    final matches = reg.allMatches(url);
    final match = matches.elementAt(0);
    final id = match.group(3);
    final type = match.group(1);
    if (type == null || id == null) {}
    switch (type) {
      case 'track':
        {
          final track = await spotify.tracks.get(id!);
          final _url = Uri.parse(
              'https://youtube.com/results?q=${Uri.encodeComponent('${track.name} - ${track.artists?[0].name}').replaceAll('%20', '+')}&hl=en&sp=EgIQAQ%253D%253D');
          final stream = await _toStream(_url);
          return stream;
        }
      // case 'playlist':
      //   final playlist = await spotify.getPlaylist(id);
      //   return playlist.tracks
      //       .map((track) => track.audioStream)
      //       .reduce((a, b) => a.merge(b));
      // case 'album':
      //   final album = await spotify.getAlbum(id);
      //   return album.tracks
      //       .map((track) => track.audioStream)
      //       .reduce((a, b) => a.merge(b));
    }
  }

  throw UnimplementedError('Please implement this function');
}

String safeFileName(String name, {String replacment = '\''}) {
  var regexPattern = r'((\<|\>)|(\:)|(\")|(\\)|(\/)|(\|)|(\?)|(\*))';
  var reg = RegExp(regexPattern);
  return name.replaceAll(reg, replacment);
}

Future<Stream<List<int>>> _toStream(Uri url) async {
  final h = await http.get(url);
  var html = h.body;
  var details = [];
  var fetched = false;

  // Rewritten from: https://github.com/DevAndromeda/youtube-sr/blob/rewrite/src/Util.ts#L108
  try {
    var data = html
        .split('ytInitialData = JSON.parse(\'')[1]
        .split('\');</script>')
        .first;
    html = data.replaceAllMapped(
        RegExp(r'\\x([0-9A-F]{2})', caseSensitive: false),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)));
    // ignore: empty_catches
  } catch (e) {}
  try {
    details = jsonDecode(html
        .split('{"itemSelectionRenderer":{"contents":')
        .last
        .split(',"continuations":[{')
        .first);
    fetched = true;
    // ignore: empty_catches
  } catch (e) {}
  if (!fetched) {
    try {
      details = jsonDecode(html
          .split('{"itemSectionRenderer":')
          .last
          .split('},{"continuationItemRenderer":{')
          .first)['contents'];
      fetched = true;
      // ignore: empty_catches
    } catch (e) {}
  }
  final videoId = details[0]['videoRenderer']['videoId'];
  final yt = YoutubeExplode();
  final manifest = await yt.videos.streamsClient.getManifest(videoId);
  final streamInfo = manifest.audioOnly.withHighestBitrate();
  final stream = yt.videos.streamsClient.get(streamInfo);

  return stream;
}

getInfos(String url) async {
  final credentials = SpotifyApiCredentials(
      creds.spotifyInfos['clientId'], creds.spotifyInfos['clientSecret']);
  final spotify = SpotifyApi(credentials);
  final reg = RegExp(
      r'https?:\/\/(?:embed\.|open\.)(?:spotify\.com\/)(?:(track|playlist|album)\/|\?uri=spotify:(track|playlist|album):)((\w|-){22})');
  if (reg.hasMatch(url)) {
    final matches = reg.allMatches(url);
    final match = matches.elementAt(0);
    final id = match.group(3);
    final type = match.group(1);
    if (type == null || id == null) {}
    switch (type) {
      case 'track':
        {
          final track = await spotify.tracks.get(id!);
          return track;
        }
    }
  }
}