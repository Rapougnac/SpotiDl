export 'to_stream.dart';

import 'dart:convert';
import '../errors/not_found.dart';
import 'package:http/http.dart' as http;
import '../models/sponsor_block.dart';
import '../models/video_renderer.dart';
import 'package:spotify/spotify.dart';
import '../crendentials.dart' as creds;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:math' as math;

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
  var parsed = details.map((d) => VideoRenderer.fromJson(d)).toList();
  final firstVid = parsed[0x00];
  final hash = toSha256(firstVid.videoId).substring(0, 4);
  final apiUrl =
      'https://sponsor.ajay.app/api/skipSegments/$hash?categories=["sponsor","poi_highlight","music_offtopic","preview","outro","intro","interaction","selfpromo","exclusive_access"]&actionTypes=["skip","mute","full"]&userAgent=sponsorBlocker@ajay.app';
  final res = await http.get(Uri.parse(apiUrl));
  final json = jsonDecode(res.body);
  // Re type with nullable, because otherwise it's not possible to use the `orElse()` method in the `firstWhere()` method
  final parsedJson =
      (json as List).map((j) => SponsorBlock.fromJson(j)).toList();
  SponsorBlock? firstVidWithoutSponsor;
  // `orElse` clause is causing a type issue
  try {
    firstVidWithoutSponsor =
        parsedJson.firstWhere((j) => j.videoID == firstVid.videoId);
  } on StateError {
    firstVidWithoutSponsor = null;
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
  final durationFromInfos = durationWithoutMilliseconds.substring(
      1, durationWithoutMilliseconds.length - 1);
  final parsedDuration = parsed.firstWhere(
    (el) =>
        el.duration.substring(0, el.duration.length - 1) == durationFromInfos,
  );
  // If no sponsor is found, return the original stream
  if (firstVidWithoutSponsor == null) {
    // Find the first video in the list that approximately matches the duration
    final parsedDetails = parsed.firstWhere(
      (d) =>
          d.duration.substring(0, d.duration.length - 1) == durationFromInfos,
      orElse: () => parsed[0],
    );

    final videoId = parsedDetails.videoId;
    final yt = YoutubeExplode();
    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final streamInfo = manifest.audioOnly.withHighestBitrate();
    final stream = yt.videos.streamsClient.get(streamInfo);
    return stream;
  } else {
    final timestampsDuration = getTimestampsDuration(
      firstVidWithoutSponsor.segments.map((s) => s.segment).toList(),
    );
    var videoDuration = firstVid.duration;
    final trueDurationInSeconds = convertStringTimeToSeconds(videoDuration) -
        (timestampsDuration ?? 0).ceil();
    final trueDurationOfVideo = convertSecondsToStringTime(
      trueDurationInSeconds,
    );
    final approximativeDuration = trueDurationOfVideo.substring(
      1,
      trueDurationOfVideo.length - 1,
    );
    if (approximativeDuration == durationFromInfos) {
      final videoId = firstVidWithoutSponsor.videoID;
      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = yt.videos.streamsClient.get(streamInfo);

      return stream;
    } else {
      final videoId = parsedDuration.videoId;
      final yt = YoutubeExplode();
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.audioOnly.withHighestBitrate();
      final stream = yt.videos.streamsClient.get(streamInfo);
      return stream;
    }
  }
}

/// Converts a string to a SHA256 hashed string
/// ```dart
/// toSha256('hello world');
///   // => 'b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9'
/// ```
String toSha256(String s) {
  final bytes = utf8.encode(s);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Converts a time string to seconds
/// ```dart
/// convertStringTimeToSeconds('01:15');
///  // => 75
/// ```
int convertStringTimeToSeconds(String time) {
  final timeSplit = time.split(':');
  final seconds = int.parse(timeSplit[0]) * 60 + int.parse(timeSplit[1]);
  return seconds;
}

/// Converts seconds to a time string
/// ```dart
/// convertSecondsToStringTime(75);
/// // => '01:15'
/// ```
String convertSecondsToStringTime(int seconds) {
  final minutes = (seconds / 60).floor();
  final secondsLeft = seconds % 60;
  return '${minutes.toString().padLeft(2, '0')}:${secondsLeft.toString().padLeft(2, '0')}';
}

num? getTimestampsDuration(List<List<num>> timestamps) {
  return getMergedTimestamps(timestamps)
      ?.fold(0, (acc, range) => (acc ?? 0) + (range[1] - range[0]));
}

List<List<num>>? getMergedTimestamps(List<List<num>> timestamps) {
  // Rewritten from: https://github.com/ajayyy/SponsorBlock/blob/master/src/utils.ts#L189
  var deduped = <List<num>>[];
  for (var range in timestamps) {
    final startOverlaps = deduped
        .indexWhere((other) => range[0] >= other[0] && range[0] <= other[1]);
    final endOverlaps = deduped
        .indexWhere((other) => range[1] >= other[0] && range[1] <= other[1]);

    if (~startOverlaps != 0 && ~endOverlaps != 0) {
      if (startOverlaps == endOverlaps) return null;
      final other1 = deduped.sublist(
        math.max(startOverlaps, endOverlaps),
        1,
      )[0];
      final other2 = deduped.sublist(
        math.min(startOverlaps, endOverlaps),
        1,
      )[0];

      deduped.add(
        [
          math.min(other1[0], other2[0]),
          math.max(other1[1], other2[1]),
        ],
      );
    } else if (~startOverlaps != 0) {
      deduped[startOverlaps][1] = range[1];
    } else if (~endOverlaps != 0) {
      deduped[endOverlaps][0] = range[0];
    } else {
      deduped.add(range.sublist(0));
    }

    deduped = deduped
        .where((other) => !(other[0] > range[0] && other[1] < range[1]))
        .toList();
  }

  return deduped;
}
