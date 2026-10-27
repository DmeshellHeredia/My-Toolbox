import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/random_person.dart';

class RandomUserException implements Exception {
  final String message;

  const RandomUserException(this.message);

  @override
  String toString() => message;
}

class RandomUserService {
  static final Uri _endpoint = Uri.https('randomuser.me', '/api/', {
    'results': '1',
    'inc': 'name,dob,picture',
  });

  static Future<RandomPerson> fetchPerson() async {
    const maxAttempts = 3;

    String lastError = 'No se pudo conectar con Random User.';

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http
            .get(_endpoint, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 12));

        if (response.statusCode == 429) {
          throw const RandomUserException(
            'Demasiadas solicitudes. Intenta nuevamente más tarde.',
          );
        }

        if (response.statusCode == 408 || response.statusCode >= 500) {
          lastError =
              'El servidor no está disponible temporalmente '
              '(HTTP ${response.statusCode}).';
        } else if (response.statusCode != 200) {
          throw RandomUserException(
            'La API respondió con HTTP ${response.statusCode}.',
          );
        } else {
          final data = jsonDecode(response.body);

          if (data is! Map<String, dynamic>) {
            throw const RandomUserException(
              'La API devolvió una respuesta inválida.',
            );
          }

          if (data.containsKey('error')) {
            lastError = 'La API informó un error temporal.';
          } else {
            final results = data['results'];

            if (results is! List || results.isEmpty) {
              throw const RandomUserException(
                'La API no devolvió ningún perfil.',
              );
            }

            try {
              return RandomPerson.fromJson(
                results.first as Map<String, dynamic>,
              );
            } catch (_) {
              throw const RandomUserException(
                'Los datos del perfil están incompletos.',
              );
            }
          }
        }
      } on TimeoutException {
        lastError = 'La solicitud tardó demasiado.';
      } on SocketException {
        lastError = 'No hay conexión estable con el servidor.';
      } on http.ClientException {
        lastError = 'La conexión con la API fue interrumpida.';
      } on FormatException {
        throw const RandomUserException(
          'El servidor devolvió datos JSON inválidos.',
        );
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: attempt));
      }
    }

    throw RandomUserException(
      '$lastError Se realizaron $maxAttempts intentos.',
    );
  }
}
