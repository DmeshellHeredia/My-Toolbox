import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_image_service.dart';

class PokemonArtwork extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonArtwork({super.key, required this.pokemon});

  @override
  State<PokemonArtwork> createState() => _PokemonArtworkState();
}

class _PokemonArtworkState extends State<PokemonArtwork> {
  late Future<Uint8List> _future;

  @override
  void initState() {
    super.initState();
    _future = PokemonImageService.load(widget.pokemon);
  }

  @override
  void didUpdateWidget(covariant PokemonArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pokemon.id != oldWidget.pokemon.id) {
      _future = PokemonImageService.load(widget.pokemon);
    }
  }

  void _retry() {
    setState(() {
      _future = PokemonImageService.load(widget.pokemon, forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return Image.memory(
            snapshot.data!,
            height: 200,
            width: 200,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return _errorContent();
            },
          );
        }

        return _errorContent();
      },
    );
  }

  Widget _errorContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: Color(0xFF64748B),
        ),
        const SizedBox(height: 6),
        const Text('Imagen no disponible', style: TextStyle(fontSize: 12)),
        TextButton.icon(
          onPressed: _retry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Reintentar imagen'),
        ),
      ],
    );
  }
}
