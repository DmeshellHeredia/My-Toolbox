import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_report.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const primary = Color(0xFF4F46E5);
  static const ink = Color(0xFF172033);

  late Future<WeatherReport> weatherFuture;

  @override
  void initState() {
    super.initState();
    weatherFuture = WeatherService.getTodayWeather();
  }

  void refreshWeather() {
    setState(() {
      weatherFuture = WeatherService.getTodayWeather();
    });
  }

  IconData weatherIcon(WeatherReport weather) {
    final code = weather.weatherCode;

    if (code == 0 || code == 1) {
      return weather.isDay ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
    }

    if (code == 2 || code == 3 || code == 45 || code == 48) {
      return Icons.cloud_rounded;
    }

    if (code >= 95) {
      return Icons.thunderstorm_rounded;
    }

    if (code >= 51 && code <= 82) {
      return Icons.water_drop_rounded;
    }

    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clima RD'),
        actions: [
          IconButton(
            tooltip: 'Actualizar clima',
            onPressed: refreshWeather,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<WeatherReport>(
          future: weatherFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 18),
                    Text('Consultando el clima...'),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return errorView(snapshot.error);
            }

            return weatherContent(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget weatherContent(WeatherReport weather) {
    final date = DateFormat('dd/MM/yyyy').format(weather.date);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const Center(
          child: Icon(Icons.cloud_outlined, size: 60, color: Color(0xFF0284C7)),
        ),
        const SizedBox(height: 17),
        const Text(
          'Así está el clima hoy',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ink,
            fontSize: 25,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'Santo Domingo, República Dominicana',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 8),
        Text(
          date,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        const SizedBox(height: 26),

        Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
            ),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              Icon(weatherIcon(weather), color: Colors.white, size: 85),
              const SizedBox(height: 13),
              Text(
                '${weather.temperature.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 11),
              Text(
                'Actualizado a las ${weather.updateTime}',
                style: const TextStyle(color: Color(0xFFE0E7FF), fontSize: 12),
              ),
            ],
          ),
        ),

        const SizedBox(height: 27),

        const Text(
          'Detalles del clima',
          style: TextStyle(
            color: ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 15),

        Row(
          children: [
            infoCard(
              Icons.thermostat_outlined,
              'Sensación térmica',
              '${weather.feelsLike.round()}°C',
            ),
            infoCard(
              Icons.water_drop_outlined,
              'Humedad',
              '${weather.humidity}%',
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            infoCard(
              Icons.air_rounded,
              'Viento',
              '${weather.windSpeed.toStringAsFixed(1)} km/h',
            ),
            infoCard(
              Icons.umbrella_outlined,
              'Prob. lluvia hoy',
              weather.rainProbability == null
                  ? 'No disponible'
                  : '${weather.rainProbability}%',
            ),
          ],
        ),

        const SizedBox(height: 26),

        const Text(
          'Pronóstico de hoy',
          style: TextStyle(
            color: ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            infoCard(
              Icons.arrow_upward_rounded,
              'Máxima',
              '${weather.maxTemperature.round()}°C',
            ),
            infoCard(
              Icons.arrow_downward_rounded,
              'Mínima',
              '${weather.minTemperature.round()}°C',
            ),
          ],
        ),

        const SizedBox(height: 22),

        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: refreshWeather,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Actualizar clima'),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Datos meteorológicos: Open-Meteo.\n'
          'Las condiciones actuales y los pronósticos '
          'pueden variar.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
        ),
      ],
    );
  }

  Widget infoCard(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE8EBF2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primary, size: 25),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 7),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  color: ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget errorView(Object? error) {
    final message = error is WeatherServiceException
        ? error.message
        : 'No fue posible obtener los datos meteorológicos.';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFFBE123C),
              size: 65,
            ),
            const SizedBox(height: 20),
            const Text(
              'No se pudo cargar el clima',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: refreshWeather,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
