export 'to_stream.dart';

import 'dart:convert';
import 'package:spotidl/errors/not_found.dart';
import 'package:http/http.dart' as http;
import 'package:spotify/spotify.dart';
import 'package:spotidl/crendentials.dart' as creds;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<Stream<List<int>>> toStream(String url) async {
  final credentials = SpotifyApiCredentials(
      creds.spotifyInfos['clientId'], creds.spotifyInfos['clientSecret']);
  final spotify = SpotifyApi(credentials);
  final reg = RegExp(
      r'https?:\/\/(?:embed\.|open\.)(?:spotify\.com\/)(?:(track|playlist|album)\/|\?uri=spotify:(track|playlist|album):)((\w|-){22})');
  if (reg.hasMatch(url)) {
    final matches = reg.allMatches(url);
    final match = matches.elementAt(0);
    final id = match.group(3)!;
    final type = match.group(1)!;
    switch (type) {
      case 'track':
        {
          final track = await spotify.tracks.get(id);
          final _url = Uri.parse(
              'https://youtube.com/results?q=${Uri.encodeComponent('${track.name} - ${track.artists?[0].name}').replaceAll('%20', '+')}&hl=en&sp=EgIQAQ%253D%253D');
          final stream = await _toStream(_url, track);
          return stream;
        }
      // case 'playlist':
      //   {
      //     final playlist = await spotify.playlists.getTracksByPlaylistId(id);
      //     final playlistInfo = await spotify.playlists.get(id);
      //     // Create a directory in the Downloads folder, we're in android
      //     final dir = await getExternalStorageDirectory();
      //     return playlist.tracks
      //         .map((track) => track.audioStream)
      //         .reduce((a, b) => a.merge(b));
      //   }
      // case 'album':
      //   final album = await spotify.getAlbum(id);
      //   return album.tracks
      //       .map((track) => track.audioStream)
      //       .reduce((a, b) => a.merge(b));
      default:
        {
          throw UnsupportedError('Unsupported type');
        }
    }
  }

  throw NotFound('Song not found');
}

Future<Stream<List<int>>> _toStream(Uri url, Track infos) async {
  print(infos);
  final h = await http.get(url, headers: {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36'
  });
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
  // Remove the milliseconds in the duration, we don't need it. Result: 00:00
  final durationWithoutMilliseconds = infos.duration
      .toString()
      .split(':')
      .sublist(1)
      .join(':')
      .split('.')
      .first;
  // Parse the duration to get only the minutes and seconds, result: 0:0
  final durationFromInfos = durationWithoutMilliseconds
      .substring(0, durationWithoutMilliseconds.length - 1)
      .substring(1);

  // Find the first video in the list that approximately matches the duration
  final parsedDetails = details.firstWhere((d) =>
      d['videoRenderer']['lengthText']['simpleText'].substring(
          0, d['videoRenderer']['lengthText']['simpleText'].length - 1) ==
      durationFromInfos);
  // Get the video id
  final videoId = parsedDetails['videoRenderer']?['videoId'];
  final yt = YoutubeExplode();
  final manifest = await yt.videos.streamsClient.getManifest(videoId);
  final streamInfo = manifest.audioOnly.withHighestBitrate();
  final stream = yt.videos.streamsClient.get(streamInfo);

  return stream;
}
