import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

class PokemonAudioException implements Exception {
  final String message;

  const PokemonAudioException(this.message);

  @override
  String toString() => message;
}

class PokemonAudioService {
  static final Map<String, Uint8List> _cache = {};
  static final Map<String, Future<Uint8List>> _pending = {};

  static Future<Uint8List> getCry({
    required int pokemonId,
    required String url,
    http.Client? client,
  }) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.scheme != 'https') {
      throw const PokemonAudioException('La URL del sonido no es válida.');
    }

    final key = '$pokemonId|$url';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    final inProgress = _pending[key];
    if (inProgress != null) return inProgress;

    late final Future<Uint8List> pending;
    pending = _download(uri, pokemonId: pokemonId, client: client)
        .then((bytes) {
          _cache[key] = bytes;
          if (_cache.length > 24) {
            _cache.remove(_cache.keys.first);
          }
          return bytes;
        })
        .whenComplete(() {
          _pending.remove(key);
        });

    _pending[key] = pending;
    return pending;
  }

  static bool _isOgg(Uint8List bytes) {
    return bytes.length >= 4 &&
        bytes[0] == 0x4f &&
        bytes[1] == 0x67 &&
        bytes[2] == 0x67 &&
        bytes[3] == 0x53;
  }

  static List<Uri> _sources(Uri original, int pokemonId) {
    final sources = <Uri>[original];
    if (original.host == 'raw.githubusercontent.com' &&
        original.path.startsWith('/PokeAPI/cries/main/cries/pokemon/latest/')) {
      final mirror = Uri.https(
        'cdn.jsdelivr.net',
        '/gh/PokeAPI/cries@main/cries/pokemon/latest/$pokemonId.ogg',
      );
      sources.add(mirror);
    }
    return sources;
  }

  static Future<Uint8List> _download(
    Uri original, {
    required int pokemonId,
    http.Client? client,
  }) async {
    var lastError = 'No se pudo descargar el sonido.';

    for (final uri in _sources(original, pokemonId)) {
      for (var attempt = 1; attempt <= 3; attempt++) {
        var retry = true;
        try {
          final response = await (client?.get(uri) ?? http.get(uri)).timeout(
            const Duration(seconds: 12),
          );

          if (response.statusCode == 200) {
            final bytes = response.bodyBytes;
            if (_isOgg(bytes)) {
              debugPrint('Pokémon audio: Ogg descargado de ${uri.host}');
              return bytes;
            }
            lastError = 'La respuesta recibida no contiene audio Ogg válido.';
            final type = response.headers['content-type'] ?? 'desconocido';
            debugPrint(
              'Pokémon audio: respuesta inválida en ${uri.host}, '
              'intento $attempt, bytes=${bytes.length}, tipo=$type',
            );
          } else if (response.statusCode == 404) {
            lastError = 'No se encontró el sonido latest en ${uri.host}.';
            retry = false;
          } else if (response.statusCode == 408 ||
              response.statusCode == 429 ||
              response.statusCode >= 500) {
            lastError =
                'El servidor de audio respondió HTTP ${response.statusCode}.';
            debugPrint(
              'Pokémon audio: HTTP ${response.statusCode} en ${uri.host}',
            );
          } else {
            lastError =
                'El servidor de audio respondió HTTP ${response.statusCode}.';
            retry = false;
          }
        } on TimeoutException catch (error) {
          lastError = 'La descarga del sonido tardó demasiado.';
          debugPrint('Pokémon audio: $error');
        } on SocketException catch (error) {
          lastError = 'Se interrumpió la conexión con el sonido.';
          debugPrint('Pokémon audio: $error');
        } on http.ClientException catch (error) {
          lastError = 'Falló la conexión con el servidor del sonido.';
          debugPrint('Pokémon audio: $error');
        } on HandshakeException catch (error) {
          lastError = 'Falló la conexión segura con el sonido.';
          debugPrint('Pokémon audio: $error');
        }

        if (!retry) break;
        if (attempt < 3) {
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    throw PokemonAudioException('$lastError Intenta reproducirlo nuevamente.');
  }
}
