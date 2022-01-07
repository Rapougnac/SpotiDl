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
          throw NotFound('Song not found');
        }
    }
  }

  throw NotFound('Song not found');
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
