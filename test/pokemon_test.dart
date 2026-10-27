import 'package:flutter_test/flutter_test.dart';
import 'package:my_toolbox/models/pokemon.dart';

void main() {
  test('Interpreta los datos completos de un Pokémon', () {
    final pokemon = Pokemon.fromJson({
      'id': 25,
      'name': 'pikachu',
      'base_experience': 112,
      'sprites': {
        'front_default': 'https://example.com/sprite.png',
        'other': {
          'official-artwork': {
            'front_default': 'https://example.com/pikachu.png',
          },
        },
      },
      'cries': {'latest': 'https://example.com/pikachu.ogg'},
      'abilities': [
        {
          'ability': {'name': 'static'},
          'is_hidden': false,
        },
        {
          'ability': {'name': 'lightning-rod'},
          'is_hidden': true,
        },
      ],
    });

    expect(pokemon.id, 25);
    expect(pokemon.displayName, 'Pikachu');
    expect(pokemon.baseExperience, 112);
    expect(pokemon.imageUrl, 'https://example.com/pikachu.png');
    expect(pokemon.cryUrl, 'https://example.com/pikachu.ogg');
    expect(pokemon.abilities, ['static', 'lightning-rod']);
    expect(pokemon.fallbackImageUrl, 'https://example.com/sprite.png');
  });

  test('Permite datos opcionales no disponibles', () {
    final pokemon = Pokemon.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'base_experience': 64,
      'sprites': {'front_default': null},
      'cries': {'latest': null},
      'abilities': [],
    });

    expect(pokemon.imageUrl, isNull);
    expect(pokemon.cryUrl, isNull);
    expect(pokemon.abilities, isEmpty);
    expect(pokemon.fallbackImageUrl, isNull);
  });

  test('Rechaza respuestas incompletas', () {
    expect(() => Pokemon.fromJson({'name': 'pikachu'}), throwsFormatException);
  });
}
