class Pokemon {
  final int id;
  final String name;
  final int baseExperience;
  final String? imageUrl;
  final String? fallbackImageUrl;
  final String? cryUrl;
  final List<String> abilities;

  const Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.imageUrl,
    required this.fallbackImageUrl,
    required this.cryUrl,
    required this.abilities,
  });

  String get displayName => formatName(name);

  static String formatName(String value) {
    return value
        .split('-')
        .map((part) {
          if (part.isEmpty) return part;
          return part[0].toUpperCase() + part.substring(1);
        })
        .join(' ');
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final experience = json['base_experience'];
    final name = json['name'];

    if (id is! num || experience is! num || name is! String) {
      throw const FormatException('Datos del Pokémon incompletos.');
    }

    String? imageUrl;
    String? fallbackImageUrl;

    final sprites = json['sprites'];

    if (sprites is Map<String, dynamic>) {
      fallbackImageUrl = sprites['front_default'] as String?;

      final other = sprites['other'];

      if (other is Map<String, dynamic>) {
        final artwork = other['official-artwork'];

        if (artwork is Map<String, dynamic>) {
          imageUrl = artwork['front_default'] as String?;
        }

        final home = other['home'];
        if (fallbackImageUrl == null && home is Map<String, dynamic>) {
          fallbackImageUrl = home['front_default'] as String?;
        }

        final dreamWorld = other['dream_world'];
        if (fallbackImageUrl == null && dreamWorld is Map<String, dynamic>) {
          fallbackImageUrl = dreamWorld['front_default'] as String?;
        }
      }
    }

    String? cryUrl;
    final cries = json['cries'];

    if (cries is Map<String, dynamic>) {
      cryUrl = cries['latest'] as String?;
    }

    final abilities = <String>[];
    final rawAbilities = json['abilities'];

    if (rawAbilities is List) {
      for (final item in rawAbilities) {
        if (item is Map<String, dynamic>) {
          final ability = item['ability'];

          if (ability is Map<String, dynamic>) {
            final abilityName = ability['name'];

            if (abilityName is String) {
              abilities.add(abilityName);
            }
          }
        }
      }
    }

    return Pokemon(
      id: id.toInt(),
      name: name,
      baseExperience: experience.toInt(),
      imageUrl: imageUrl,
      fallbackImageUrl: fallbackImageUrl,
      cryUrl: cryUrl,
      abilities: abilities,
    );
  }
}
