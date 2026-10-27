import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/wordpress_post.dart';

class WordpressServiceException implements Exception {
  final String message;

  const WordpressServiceException(this.message);

  @override
  String toString() => message;
}

class WordpressService {
  static const siteUrl = 'https://wptavern.com/';
  static const siteIconUrl =
      'https://wptavern.com/wp-content/uploads/2021/12/cropped-tavern-favicon.png';

  static final _apiUri = Uri.https('wptavern.com', '/wp-json/wp/v2/posts', {
    'per_page': '3',
    'orderby': 'date',
    'order': 'desc',
    '_fields': 'id,date,link,title,excerpt',
  });

  static final _rssUri = Uri.https('wptavern.com', '/feed/');

  /// Primero intenta la API REST de WordPress. Si falla, utiliza RSS.
  static Future<List<WordpressPost>> fetchLatest() async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await http
            .get(_apiUri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw WordpressServiceException(
            'Respuesta HTTP ${response.statusCode} de WordPress.',
          );
        }

        final json = jsonDecode(utf8.decode(response.bodyBytes));
        if (json is! List) {
          throw const FormatException('La API no devolvió una lista.');
        }

        final posts = json
            .whereType<Map<String, dynamic>>()
            .map(WordpressPost.fromJson)
            .where((post) => post.isValid)
            .take(3)
            .toList();

        if (posts.isNotEmpty) return posts;
        throw const FormatException('No hay noticias válidas en la API.');
      } catch (error) {
        debugPrint('WordPress REST intento $attempt: $error');
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      }
    }

    // Plan B: WP Tavern también publica noticias mediante RSS.
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await http
            .get(
              _rssUri,
              headers: {
                'Accept': 'application/rss+xml, application/xml, text/xml',
              },
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw WordpressServiceException(
            'Respuesta HTTP ${response.statusCode} del feed RSS.',
          );
        }

        final document = XmlDocument.parse(utf8.decode(response.bodyBytes));
        final posts = document
            .findAllElements('item')
            .map(WordpressPost.fromRss)
            .where((post) => post.isValid)
            .take(3)
            .toList();

        if (posts.isNotEmpty) {
          debugPrint('WordPress: publicaciones obtenidas mediante RSS.');
          return posts;
        }
        throw const FormatException('El feed RSS no contiene noticias.');
      } catch (error) {
        debugPrint('WordPress RSS intento $attempt: $error');
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      }
    }

    throw const WordpressServiceException(
      'No pudimos cargar las noticias de WP Tavern. '
      'Comprueba tu conexión e intenta nuevamente.',
    );
  }
}
