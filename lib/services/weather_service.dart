import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather_report.dart';

class WeatherServiceException implements Exception {
  final String message;

  const WeatherServiceException(this.message);

  @override
  String toString() => message;
}

class WeatherService {
  static Future<WeatherReport> getTodayWeather() async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '18.4861',
      'longitude': '-69.9312',
      'current': [
        'temperature_2m',
        'relative_humidity_2m',
        'apparent_temperature',
        'weather_code',
        'wind_speed_10m',
        'is_day',
      ].join(','),
      'daily': [
        'temperature_2m_max',
        'temperature_2m_min',
        'precipitation_probability_max',
      ].join(','),
      'timezone': 'America/Santo_Domingo',
      'forecast_days': '1',
    });

    String lastError = 'No fue posible obtener el clima.';

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode == 200) {
          final data = jsonDecode(
            utf8.decode(response.bodyBytes),
          ) as Map<String, dynamic>;

          return WeatherReport.fromJson(data);
        }

        if (response.statusCode >= 500 || response.statusCode == 408) {
          lastError = 'El servidor meteorológico no está disponible.';
        } else {
          throw WeatherServiceException(
            'Error del servidor: HTTP ${response.statusCode}',
          );
        }
      } on TimeoutException {
        lastError = 'La conexión tardó demasiado.';
      } on SocketException {
        lastError = 'No hay conexión con el servidor.';
      } on http.ClientException {
        lastError = 'Se interrumpió la conexión.';
      } on HandshakeException {
        lastError = 'Falló la conexión segura con el servidor.';
      } on FormatException {
        throw const WeatherServiceException(
          'La API devolvió datos inválidos o incompletos.',
        );
      } on TypeError {
        throw const WeatherServiceException(
          'La respuesta meteorológica tiene un formato inesperado.',
        );
      }

      if (attempt < 2) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    throw WeatherServiceException(lastError);
  }
}
