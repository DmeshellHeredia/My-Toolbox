import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonImageException implements Exception {
  final String message;

  const PokemonImageException(this.message);

  @override
  String toString() => message;
}

/// Descarga imágenes con fuentes alternativas y caché temporal en memoria.
class PokemonImageService {
  static final Map<int, Uint8List> _cache = {};
  static final Map<int, Future<Uint8List>> _inProgress = {};

  static Future<Uint8List> load(
    Pokemon pokemon, {
    bool forceRefresh = false,
    http.Client? client,
  }) {
    if (forceRefresh) _cache.remove(pokemon.id);

    if (!forceRefresh) {
      final saved = _cache[pokemon.id];
      if (saved != null) return Future.value(saved);
    }

    final pending = _inProgress[pokemon.id];
    if (pending != null) return pending;

    final future = _loadAndCache(pokemon, client: client);
    _inProgress[pokemon.id] = future;
    return future;
  }

  static Future<Uint8List> _loadAndCache(
    Pokemon pokemon, {
    http.Client? client,
  }) async {
    try {
      final bytes = await _download(pokemon, client: client);
      _cache.remove(pokemon.id);
      _cache[pokemon.id] = bytes;

      // Límite básico para no acumular imágenes en la memoria de la app.
      if (_cache.length > 20) {
        _cache.remove(_cache.keys.first);
      }
      return bytes;
    } finally {
      _inProgress.remove(pokemon.id);
    }
  }

  static Future<Uint8List> _download(
    Pokemon pokemon, {
    http.Client? client,
  }) async {
    // La URL de respaldo usa otra infraestructura (jsDelivr), no solo
    // otra ruta del mismo servidor raw.githubusercontent.com.
    final candidates = <String>{
      if (pokemon.imageUrl != null && pokemon.imageUrl!.isNotEmpty)
        pokemon.imageUrl!,
      'https://cdn.jsdelivr.net/gh/PokeAPI/sprites@master/sprites/pokemon/other/official-artwork/${pokemon.id}.png',
      if (pokemon.fallbackImageUrl != null &&
          pokemon.fallbackImageUrl!.isNotEmpty)
        pokemon.fallbackImageUrl!,
    }.toList();

    String lastReason = 'No se encontró ninguna imagen disponible.';

    for (var index = 0; index < candidates.length; index++) {
      final url = candidates[index];
      final uri = Uri.tryParse(url);
      if (uri == null || uri.scheme != 'https') continue;

      // Reintentar la imagen oficial; los respaldos se prueban una vez.
      final attempts = index == 0 ? 2 : 1;
      for (var attempt = 1; attempt <= attempts; attempt++) {
        try {
          final response = await (client?.get(uri) ?? http.get(uri)).timeout(
            const Duration(seconds: 10),
          );

          if (response.statusCode == 200 &&
              _hasImageSignature(response.bodyBytes)) {
            debugPrint(
              'Pokémon ${pokemon.id}: imagen descargada de ${uri.host}',
            );
            return response.bodyBytes;
          }

          lastReason =
              'HTTP ${response.statusCode} o imagen inválida en ${uri.host}';
          debugPrint('Pokémon ${pokemon.id}: $lastReason');
          if (response.statusCode == 404) break;
        } catch (error) {
          lastReason = '$error';
          debugPrint(
            'Pokémon ${pokemon.id}: imagen falló en ${uri.host}: $error',
          );
        }

        if (attempt < attempts) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      }
    }

    throw PokemonImageException('No se pudo descargar la imagen. $lastReason');
  }

  static bool _hasImageSignature(Uint8List bytes) {
    if (bytes.length < 8) return false;
    final png =
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    final jpeg = bytes[0] == 0xFF && bytes[1] == 0xD8;
    final webp =
        bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    return png || jpeg || webp;
  }
}
