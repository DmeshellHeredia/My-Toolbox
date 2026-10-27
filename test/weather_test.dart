import 'package:flutter_test/flutter_test.dart';
import 'package:my_toolbox/models/weather_report.dart';

void main() {
  test('Interpreta correctamente la respuesta del clima', () {
    final report = WeatherReport.fromJson({
      'current': {
        'time': '2026-10-26T17:00',
        'temperature_2m': 29.5,
        'apparent_temperature': 34.2,
        'relative_humidity_2m': 78,
        'wind_speed_10m': 12.6,
        'weather_code': 2,
        'is_day': 1,
      },
      'daily': {
        'time': ['2026-10-26'],
        'temperature_2m_max': [32.1],
        'temperature_2m_min': [24.3],
        'precipitation_probability_max': [65],
      },
    });

    expect(report.temperature, 29.5);
    expect(report.feelsLike, 34.2);
    expect(report.humidity, 78);
    expect(report.maxTemperature, 32.1);
    expect(report.minTemperature, 24.3);
    expect(report.rainProbability, 65);
    expect(report.condition, 'Parcialmente nublado');
    expect(report.updateTime, '17:00');
    expect(report.isDay, true);
  });

  test('Permite probabilidad de lluvia no disponible', () {
    final report = WeatherReport.fromJson({
      'current': {
        'time': '2026-10-26T20:00',
        'temperature_2m': 27,
        'apparent_temperature': 29,
        'relative_humidity_2m': 80,
        'wind_speed_10m': 9,
        'weather_code': 0,
        'is_day': 0,
      },
      'daily': {
        'time': ['2026-10-26'],
        'temperature_2m_max': [30],
        'temperature_2m_min': [23],
        'precipitation_probability_max': [null],
      },
    });

    expect(report.rainProbability, isNull);
    expect(report.condition, 'Cielo despejado');
    expect(report.isDay, false);
  });
}
