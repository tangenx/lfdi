import 'dart:convert';

import 'package:http/http.dart';

class API {
  static const String baseUrl = 'ws.audioscrobbler.com';

  static dynamic fetch(Map<String, String> query) async {
    Uri uri = Uri.http(baseUrl, '/2.0/', query);
    Response response = await get(uri, headers: {
      'Accept': 'application/json; charset=UTF-8',
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36',
    });
    Map decodedResponse = {};
    try {
      decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      if (response.body.contains('<html>')) {
        decodedResponse = {'error': 'Server respond the HTML page'};
      }
    }

    return decodedResponse;
  }

  static Future<dynamic> getRecentTrack(String username, String apiKey) {
    return fetch({
      'method': 'user.getrecenttracks',
      'user': username,
      'api_key': apiKey,
      'format': 'json',
      'limit': '1'
    });
  }

  static Future<dynamic> getTrackInfo(
    String username,
    String apiKey,
    String track,
    String artist,
  ) {
    return fetch({
      'method': 'track.getInfo',
      'user': username,
      'track': track,
      'artist': artist,
      'api_key': apiKey,
      'format': 'json'
    });
  }

  static checkAPI(Map response) {
    Map<String, dynamic> result = {'status': '', 'message': ''};

    if (response['error'] != null) {
      result['status'] = 'error';
      result['message'] = 'Unknown error';

      if (response['error'] == 6) {
        result['message'] = 'Last.fm user not found';
      }

      if (response['error'] == 8) {
        result['message'] = 'Last.fm backend error';
      }

      if (response['error'] == 10) {
        result['message'] = 'Invalid last.fm API key';
      }

      return result;
    }

    result['status'] = 'pass';
    result['message'] = response;

    return result;
  }
}
