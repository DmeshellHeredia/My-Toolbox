import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/university.dart';

class UniversityServiceException implements Exception {
  final String message;

  const UniversityServiceException(this.message);

  @override
  String toString() => message;
}

class UniversityService {
  static const int _maxAttempts = 3;
  static const Duration _proxyTimeout = Duration(seconds: 10);
  static const Duration _backupTimeout = Duration(seconds: 18);

  // Guarda las búsquedas satisfactorias durante la sesión actual.
  static final Map<String, List<University>> _cache = {};

  static Future<List<University>> search(
    String country, {
    http.Client? client,
  }) async {
    final name = country.trim();
    if (name.isEmpty) {
      throw const UniversityServiceException(
        'Introduce el nombre de un país en inglés.',
      );
    }

    final key = name.toLowerCase();
    final cached = _cache[key];
    if (cached != null) {
      return List<University>.unmodifiable(cached);
    }

    final httpClient = client ?? http.Client();
    final proxyUrl = Uri.https('adamix.net', '/proxy.php', {'country': name});
    final backupUrl = Uri.https(
      'raw.githubusercontent.com',
      '/Hipo/university-domains-list/master/world_universities_and_domains.json',
    );

    // Una respuesta vacía de la API principal puede ser legítima.
    // Se conserva si la comprobación con la fuente de respaldo falla.
    bool proxyReturnedEmpty = false;

    try {
      for (var attempt = 1; attempt <= _maxAttempts; attempt++) {
        try {
          final response = await httpClient
              .get(proxyUrl, headers: const {'Accept': 'application/json'})
              .timeout(_proxyTimeout);

          if (response.statusCode != 200) {
            throw UniversityServiceException(
              'El servidor respondió con HTTP ${response.statusCode}.',
            );
          }

          final results = _parseUniversities(response.bodyBytes);

          if (results.isNotEmpty) {
            _cache[key] = results;
            return List<University>.unmodifiable(results);
          }

          proxyReturnedEmpty = true;
          break;
        } catch (_) {
          // Retrasos breves evitan que un fallo temporal interrumpa la búsqueda.
          if (attempt < _maxAttempts) {
            await Future<void>.delayed(Duration(milliseconds: 400 * attempt));
          }
        }
      }

      // Si adamix falla, se utiliza el JSON público del proyecto Hipo.
      // La fuente es HTTPS y contiene nombre, país, dominios y páginas web.
      try {
        final response = await httpClient
            .get(backupUrl, headers: const {'Accept': 'application/json'})
            .timeout(_backupTimeout);

        if (response.statusCode != 200) {
          throw UniversityServiceException(
            'La fuente de respaldo respondió con HTTP ${response.statusCode}.',
          );
        }

        final results = _parseUniversities(response.bodyBytes)
            .where(
              (university) => university.country.trim().toLowerCase() == key,
            )
            .toList();

        _cache[key] = results;
        return List<University>.unmodifiable(results);
      } catch (_) {
        if (proxyReturnedEmpty) {
          _cache[key] = <University>[];
          return const <University>[];
        }

        throw const UniversityServiceException(
          'No fue posible consultar las universidades en este momento. '
          'Revisa tu conexión e intenta nuevamente.',
        );
      }
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  static List<University> _parseUniversities(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));

    if (decoded is! List) {
      throw const FormatException('Se esperaba una lista JSON.');
    }

    final universities = <University>[];
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        final university = University.fromJson(item);
        if (university.name.isNotEmpty) {
          universities.add(university);
        }
      }
    }

    universities.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return universities;
  }
}
