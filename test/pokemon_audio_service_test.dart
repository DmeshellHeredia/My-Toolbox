import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_toolbox/services/pokemon_audio_service.dart';

void main() {
  final oggBytes = Uint8List.fromList([0x4F, 0x67, 0x67, 0x53, 0, 1, 2, 3]);

  test('Descarga un sonido Ogg y lo conserva en caché', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response.bytes(oggBytes, 200);
    });
    addTearDown(client.close);

    final first = await PokemonAudioService.getCry(
      pokemonId: 987651,
      url: 'https://example.com/cries/latest/test1.ogg',
      client: client,
    );
    final second = await PokemonAudioService.getCry(
      pokemonId: 987651,
      url: 'https://example.com/cries/latest/test1.ogg',
      client: client,
    );

    expect(first, oggBytes);
    expect(second, oggBytes);
    expect(calls, 1);
  });

  test('Recupera la descarga cuando aparece un error temporal', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls == 1) return http.Response('temporal', 503);
      return http.Response.bytes(oggBytes, 200);
    });
    addTearDown(client.close);

    final result = await PokemonAudioService.getCry(
      pokemonId: 987652,
      url: 'https://example.com/cries/latest/test2.ogg',
      client: client,
    );

    expect(result, oggBytes);
    expect(calls, 2);
  });

  test('Rechaza una URL sin HTTPS', () {
    expect(
      () => PokemonAudioService.getCry(
        pokemonId: 987653,
        url: 'http://example.com/sound.ogg',
      ),
      throwsA(isA<PokemonAudioException>()),
    );
  });
}
