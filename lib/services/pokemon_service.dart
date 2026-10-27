import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

class PokemonServiceException implements Exception {
  final String message;

  const PokemonServiceException(this.message);

  @override
  String toString() => message;
}

class PokemonService {
  static final Map<String, Pokemon> _cache = {};

  static Future<Pokemon> search(String input) async {
    final name = input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '-');

    if (name.isEmpty) {
      throw const PokemonServiceException('Introduce el nombre de un Pokémon.');
    }

    final cached = _cache[name];
    if (cached != null) return cached;

    final uri = Uri.https('pokeapi.co', '/api/v2/pokemon/$name');
    String lastError = 'No se pudo consultar PokéAPI.';

    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        final response = await http
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 404) {
          throw PokemonServiceException(
            'No encontramos "$input". Comprueba el nombre.',
          );
        }

        if (response.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is! Map<String, dynamic>) {
            throw const FormatException('JSON inesperado.');
          }
          final pokemon = Pokemon.fromJson(decoded);
          _cache[name] = pokemon;
          return pokemon;
        }

        if (response.statusCode == 429) {
          lastError = 'El servidor está limitando las solicitudes (HTTP 429).';
        } else if (response.statusCode == 408 || response.statusCode >= 500) {
          lastError =
              'Error temporal de PokéAPI (HTTP ${response.statusCode}).';
        } else {
          throw PokemonServiceException(
            'PokéAPI respondió con HTTP ${response.statusCode}.',
          );
        }
      } on TimeoutException catch (error) {
        lastError = 'La solicitud superó el tiempo de espera.';
        debugPrint('PokéAPI intento $attempt: $error');
      } on SocketException catch (error) {
        lastError = 'No hay conexión estable con PokéAPI.';
        debugPrint('PokéAPI intento $attempt: $error');
      } on http.ClientException catch (error) {
        lastError = 'Se interrumpió la conexión con PokéAPI.';
        debugPrint('PokéAPI intento $attempt: $error');
      } on HandshakeException catch (error) {
        lastError = 'Falló la conexión HTTPS.';
        debugPrint('PokéAPI intento $attempt: $error');
      } on FormatException {
        throw const PokemonServiceException(
          'La API devolvió datos inválidos o incompletos.',
        );
      } on TypeError {
        throw const PokemonServiceException(
          'El servidor devolvió un formato inesperado.',
        );
      }

      if (attempt < 3) {
        await Future<void>.delayed(Duration(seconds: attempt));
      }
    }

    throw PokemonServiceException('$lastError Inténtalo nuevamente.');
  }
}
