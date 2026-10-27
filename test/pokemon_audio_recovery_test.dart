import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_toolbox/services/pokemon_audio_service.dart';

void main() {
  final ogg = Uint8List.fromList([0x4f, 0x67, 0x67, 0x53, 0, 1, 2, 3]);

  test(
    'Reintenta cuando el servidor devuelve HTTP 200 sin Ogg válido',
    () async {
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return calls == 1
            ? http.Response('<html>temporal</html>', 200)
            : http.Response.bytes(ogg, 200);
      });
      addTearDown(client.close);

      final data = await PokemonAudioService.getCry(
        pokemonId: 900001,
        url: 'https://example.com/latest/900001.ogg',
        client: client,
      );

      expect(data, ogg);
      expect(calls, 2);
    },
  );

  test(
    'Cambia al CDN alternativo si GitHub responde contenido inválido',
    () async {
      var primaryCalls = 0;
      var mirrorCalls = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'raw.githubusercontent.com') {
          primaryCalls++;
          return http.Response('error temporal', 200);
        }
        if (request.url.host == 'cdn.jsdelivr.net') {
          mirrorCalls++;
          expect(
            request.url.path,
            '/gh/PokeAPI/cries@main/cries/pokemon/latest/900002.ogg',
          );
          return http.Response.bytes(ogg, 200);
        }
        return http.Response('No encontrado', 404);
      });
      addTearDown(client.close);

      final data = await PokemonAudioService.getCry(
        pokemonId: 900002,
        url: 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/900002.ogg',
        client: client,
      );

      expect(data, ogg);
      expect(primaryCalls, 3);
      expect(mirrorCalls, 1);
    },
  );
}
