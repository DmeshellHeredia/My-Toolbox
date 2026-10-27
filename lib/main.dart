import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'screens/random_user_screen.dart';
import 'screens/universities_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/pokemon_screen.dart';
import 'screens/wordpress_screen.dart';
import 'screens/about_screen.dart';
import 'widgets/toolbox_hero_banner.dart';

void main() {
  runApp(const MyToolboxApp());
}

const primary = Color(0xFF4F46E5);
const background = Color(0xFFF7F8FC);
const ink = Color(0xFF172033);

class MyToolboxApp extends StatelessWidget {
  const MyToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Toolbox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: ink,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class ToolInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const ToolInfo(this.title, this.description, this.icon, this.color);
}

const tools = <ToolInfo>[
  ToolInfo(
    'Género',
    'Predicción por nombre',
    Icons.people_outline,
    Color(0xFF6366F1),
  ),
  ToolInfo(
    'Persona aleatoria',
    'Generador de perfiles',
    Icons.person_search_outlined,
    Color(0xFF0891B2),
  ),
  ToolInfo(
    'Universidades',
    'Buscar por país',
    Icons.school_outlined,
    Color(0xFF0D9488),
  ),
  ToolInfo(
    'Clima RD',
    'Pronóstico de hoy',
    Icons.cloud_outlined,
    Color(0xFF0284C7),
  ),
  ToolInfo(
    'Pokémon',
    'Datos, fotos y sonido',
    Icons.catching_pokemon,
    Color(0xFFEA580C),
  ),

  ToolInfo(
    'Noticias',
    'Últimas publicaciones',
    Icons.article_outlined,
    Color(0xFF9333EA),
  ),
  ToolInfo(
    'Acerca de',
    'Perfil y contacto',
    Icons.contact_mail_outlined,
    Color(0xFF475569),
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void openTool(BuildContext context, ToolInfo tool) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          if (tool.title == 'Género') {
            return const GenderScreen();
          }

          if (tool.title == 'Persona aleatoria') {
            return const RandomUserScreen();
          }

          if (tool.title == 'Universidades') {
            return const UniversitiesScreen();
          }

          if (tool.title == 'Clima RD') {
            return const WeatherScreen();
          }

          if (tool.title == 'Pokémon') {
            return const PokemonScreen();
          }

          if (tool.title == 'Noticias') {
            return const WordpressScreen();
          }

          if (tool.title == 'Acerca de') {
            return const AboutScreen();
          }

          return PendingScreen(tool: tool);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Toolbox',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE9E8FF),
              child: Icon(Icons.person_outline, color: primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'TU ESPACIO DE HERRAMIENTAS',
              style: TextStyle(
                color: primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Todo lo que necesitas,\nen un solo lugar.',
              style: TextStyle(
                color: ink,
                fontSize: 29,
                height: 1.18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            const ToolboxHeroBanner(),
            const SizedBox(height: 28),
            const Text(
              'Explorar herramientas',
              style: TextStyle(
                color: ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona lo que quieres hacer hoy.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 18),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length - 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 132,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => openTool(context, tool),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFE8EBF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: tool.color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(tool.icon, color: tool.color, size: 22),
                          ),
                          const Spacer(),
                          Text(
                            tool.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ink,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tool.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            // Ultima herramienta en formato horizontal para aprovechar el ancho.
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => openTool(context, tools.last),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE8EBF2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: tools.last.color.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          tools.last.icon,
                          color: tools.last.color,
                          size: 23,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tools.last.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tools.last.description,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'MY TOOLBOX • FLUTTER',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingScreen extends StatelessWidget {
  final ToolInfo tool;

  const PendingScreen({super.key, required this.tool});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tool.title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tool.icon, size: 72, color: tool.color),
              const SizedBox(height: 20),
              Text(
                tool.title,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Esta herramienta se implementará en la siguiente fase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GenderScreen extends StatefulWidget {
  const GenderScreen({super.key});

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final controller = TextEditingController();

  bool loading = false;
  String? resultName;
  String? gender;
  double? probability;
  String? error;

  Future<void> predict() async {
    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() => error = 'Introduce un nombre.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      error = null;
      resultName = null;
    });

    try {
      final uri = Uri.https('api.genderize.io', '/', {'name': name});

      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        resultName = data['name'] as String? ?? name;
        gender = data['gender'] as String?;
        probability = (data['probability'] as num?)?.toDouble();
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = 'No fue posible consultar la API. Intenta nuevamente.';
      });
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = gender == 'male'
        ? const Color(0xFF2563EB)
        : gender == 'female'
        ? const Color(0xFFDB2777)
        : const Color(0xFF64748B);

    final label = gender == 'male'
        ? 'Masculino'
        : gender == 'female'
        ? 'Femenino'
        : 'No determinado';

    return Scaffold(
      appBar: AppBar(title: const Text('Predicción de género')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 14),
          const Icon(Icons.people_outline, size: 65, color: primary),
          const SizedBox(height: 20),
          const Text(
            '¿Qué predice tu nombre?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          const Text(
            'Introduce un nombre para consultar Genderize.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 28),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => predict(),
            decoration: const InputDecoration(
              labelText: 'Nombre',
              hintText: 'Ejemplo: Irma',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: loading ? null : predict,
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Consultar género'),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 20),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
          if (resultName != null) ...[
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withValues(alpha: 0.30)),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_circle, size: 75, color: color),
                  const SizedBox(height: 12),
                  Text(
                    resultName!,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    gender == null || probability == null
                        ? 'Sin datos suficientes para este nombre'
                        : 'Probabilidad: ${(probability! * 100).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 25),
          const Text(
            'La predicción se basa en estadísticas de nombres. '
            'No determina la identidad de género de una persona.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
