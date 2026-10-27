import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/university.dart';

class UniversityServiceException implements Exception {
  final String message;

  const UniversityServiceException(this.message);

  @override
  String toString() => message;
}

class UniversityService {
  static Future<List<University>> search(String country) async {
    final name = country.trim();

    if (name.isEmpty) {
      throw const UniversityServiceException(
        'Introduce el nombre de un país en inglés.',
      );
    }

    final uri = Uri.https('adamix.net', '/proxy.php', {'country': name});

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw UniversityServiceException(
          'El servidor respondió con HTTP ${response.statusCode}.',
        );
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! List) {
        throw const UniversityServiceException(
          'El servidor devolvió un formato inesperado.',
        );
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
    } on TimeoutException {
      throw const UniversityServiceException(
        'La consulta tardó demasiado. Intenta nuevamente.',
      );
    } on SocketException {
      throw const UniversityServiceException(
        'No se pudo conectar con el servidor.',
      );
    } on http.ClientException {
      throw const UniversityServiceException(
        'Ocurrió un problema con la conexión.',
      );
    } on FormatException {
      throw const UniversityServiceException(
        'La API devolvió datos JSON inválidos.',
      );
    }
  }
}
