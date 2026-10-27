import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_toolbox/models/pokemon.dart';
import 'package:my_toolbox/services/pokemon_image_service.dart';

void main() {
  test('Si falla la imagen principal, utiliza la fuente alternativa', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      if (request.url.host == 'cdn.jsdelivr.net') {
        // PNG mínimo de prueba para la validación del servicio.
        return http.Response.bytes(
          base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRxcAAAAASUVORK5CYII=',
          ),
          200,
          headers: {'content-type': 'image/png'},
        );
      }
      return http.Response('Temporalmente no disponible', 503);
    });

    const pokemon = Pokemon(
      id: 987654,
      name: 'test',
      baseExperience: 1,
      imageUrl: 'https://example.invalid/first.png',
      fallbackImageUrl: 'https://example.invalid/fallback.png',
      cryUrl: null,
      abilities: [],
    );

    final bytes = await PokemonImageService.load(pokemon, client: client);
    expect(bytes.length, greaterThan(8));
    expect(requests, 3);
    final beforeCache = requests;
    await PokemonImageService.load(pokemon, client: client);
    expect(requests, beforeCache);
    client.close();
  });
}
