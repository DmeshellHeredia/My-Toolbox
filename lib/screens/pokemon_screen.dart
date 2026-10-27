import 'dart:async';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/pokemon.dart';
import '../services/pokemon_audio_service.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_artwork.dart';

const _primary = Color(0xFF4F46E5);
const _ink = Color(0xFF172033);

class PokemonScreen extends StatefulWidget {
  const PokemonScreen({super.key});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  final _controller = TextEditingController(text: 'pikachu');
  final _player = AudioPlayer();

  StreamSubscription<PlayerState>? _audioSubscription;

  Pokemon? _pokemon;
  String? _error;

  bool _loading = false;
  bool _playing = false;
  bool _audioBusy = false;

  @override
  void initState() {
    super.initState();

    _audioSubscription = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playing = state == PlayerState.playing;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchPokemon();
    });
  }

  Future<void> _searchPokemon() async {
    if (_loading || _audioBusy) return;

    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() {
        _error = 'Introduce el nombre de un Pokémon.';
        _pokemon = null;
      });
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _pokemon = null;
    });

    try {
      await _player.stop();

      final result = await PokemonService.search(name);

      if (!mounted) return;

      setState(() {
        _pokemon = result;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error is PokemonServiceException
            ? error.message
            : 'No fue posible consultar el Pokémon.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleSound() async {
    final pokemon = _pokemon;

    if (pokemon == null || _audioBusy) return;

    final isPikachu = pokemon.id == 25;
    final url = pokemon.cryUrl;

    // Pikachu utiliza el sonido latest guardado localmente.
    // Los demás Pokémon utilizan el servicio de audio remoto.
    if (!isPikachu && (url == null || url.isEmpty)) return;

    if (_playing) {
      try {
        await _player.stop();
      } catch (error) {
        debugPrint('Pokémon audio: error al detener: $error');
      }
      return;
    }

    setState(() => _audioBusy = true);

    try {
      final bytes = isPikachu
          ? await _loadLocalPikachuCry()
          : await PokemonAudioService.getCry(pokemonId: pokemon.id, url: url!);

      if (!mounted || _pokemon?.id != pokemon.id) return;

      // Pikachu tiene un MP3 real, aunque el archivo original
      // de PokéAPI se distribuye con extensión .ogg.
      final mimeType = isPikachu ? 'audio/mpeg' : 'audio/ogg';

      // Reintentar si el reproductor falla al preparar el sonido.
      for (var attempt = 1; attempt <= 2; attempt++) {
        try {
          await _player.stop();

          await _player.play(BytesSource(bytes, mimeType: mimeType));

          return;
        } catch (error) {
          debugPrint('Pokémon audio reproducción $attempt: $error');

          if (attempt == 2) rethrow;

          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
      }
    } catch (error) {
      debugPrint('Pokémon audio error final: $error');

      if (mounted) {
        final message = error is PokemonAudioException
            ? error.message
            : 'No fue posible reproducir el sonido. Intenta nuevamente.';

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) {
        setState(() => _audioBusy = false);
      }
    }
  }

  // Carga el sonido latest de Pikachu sin conexión a Internet.
  Future<Uint8List> _loadLocalPikachuCry() async {
    final data = await rootBundle.load('assets/pokemon/25.mp3');

    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioSubscription?.cancel();
    _player.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),

            const Center(
              child: Icon(
                Icons.catching_pokemon,
                color: Color(0xFFEA580C),
                size: 65,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Explora el mundo Pokémon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Busca un Pokémon y descubre su imagen, '
              'experiencia, habilidades y sonido.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),

            const SizedBox(height: 26),

            TextField(
              controller: _controller,
              enabled: !_loading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _searchPokemon(),
              decoration: InputDecoration(
                labelText: 'Nombre del Pokémon',
                hintText: 'Ejemplo: pikachu',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Limpiar',
                  icon: const Icon(Icons.close),
                  onPressed: _controller.clear,
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _searchPokemon,
                icon: _loading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(_loading ? 'Buscando...' : 'Buscar Pokémon'),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickSearch('pikachu'),
                _quickSearch('charizard'),
                _quickSearch('bulbasaur'),
              ],
            ),

            const SizedBox(height: 25),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_error != null) _errorCard(),

            if (_pokemon != null) _pokemonCard(_pokemon!),

            if (!_loading && _error == null && _pokemon == null)
              const Center(child: Text('Busca un Pokémon para comenzar.')),
          ],
        ),
      ),
    );
  }

  Widget _quickSearch(String name) {
    return ActionChip(
      label: Text(Pokemon.formatName(name)),
      onPressed: _loading || _audioBusy
          ? null
          : () {
              _controller.text = name;
              _searchPokemon();
            },
    );
  }

  Widget _pokemonCard(Pokemon pokemon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '#${pokemon.id.toString().padLeft(4, '0')}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Imágenes locales para Pikachu, Charizard y Bulbasaur.
          // Los demás Pokémon utilizan PokemonArtwork.
          Container(
            width: double.infinity,
            height: 210,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(22),
            ),
            child: {1, 6, 25}.contains(pokemon.id)
                ? Image.asset(
                    'assets/pokemon/${pokemon.id}.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return PokemonArtwork(
                        key: ValueKey(pokemon.id),
                        pokemon: pokemon,
                      );
                    },
                  )
                : PokemonArtwork(key: ValueKey(pokemon.id), pokemon: pokemon),
          ),

          const SizedBox(height: 19),

          Text(
            pokemon.displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_outlined, color: _primary),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Experiencia base',
                    style: TextStyle(color: _ink, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '${pokemon.baseExperience} EXP',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Habilidades',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: _ink,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: pokemon.abilities.isEmpty
                ? const Text('Sin habilidades disponibles.')
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: pokemon.abilities.map((ability) {
                      return Chip(
                        avatar: const Icon(
                          Icons.bolt,
                          size: 17,
                          color: _primary,
                        ),
                        label: Text(Pokemon.formatName(ability)),
                        backgroundColor: const Color(0xFFEDE9FE),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 25),

          // Botón de reproducción de sonido.
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  (pokemon.id != 25 && pokemon.cryUrl == null) || _audioBusy
                  ? null
                  : _toggleSound,
              icon: _audioBusy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      _playing
                          ? Icons.stop_circle_outlined
                          : Icons.volume_up_outlined,
                    ),
              label: Text(
                _audioBusy
                    ? 'Preparando sonido...'
                    : pokemon.id != 25 && pokemon.cryUrl == null
                    ? 'Sonido no disponible'
                    : _playing
                    ? 'Detener sonido'
                    : 'Reproducir sonido',
              ),
            ),
          ),

          const SizedBox(height: 11),

          const Text(
            'Sonido Pokémon (latest) proporcionado por PokéAPI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 45, color: Color(0xFFBE123C)),

          const SizedBox(height: 12),

          const Text(
            'No se pudo cargar el Pokémon',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 10),

          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9F1239)),
          ),

          const SizedBox(height: 15),

          TextButton.icon(
            onPressed: _loading ? null : _searchPokemon,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar búsqueda'),
          ),
        ],
      ),
    );
  }
}
