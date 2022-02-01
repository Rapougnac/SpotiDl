export 'get_infos.dart';
import 'package:spotidl/errors/not_found.dart';
import 'package:spotify/spotify.dart';
import 'package:spotidl/crendentials.dart' as creds;

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
    if (type == null || id == null) throw NotFound('Song not found');
    switch (type) {
      case 'track':
        {
          final track = await spotify.tracks.get(id);
          return track;
        }
      default:
        {
          throw UnsupportedError('Type not supported');
        }
    }
  }

  throw NotFound('Song not found');
}
