import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/university.dart';
import '../services/university_service.dart';

class UniversitiesScreen extends StatefulWidget {
  const UniversitiesScreen({super.key});

  @override
  State<UniversitiesScreen> createState() => _UniversitiesScreenState();
}

class _UniversitiesScreenState extends State<UniversitiesScreen> {
  static const primary = Color(0xFF4F46E5);
  static const ink = Color(0xFF172033);

  final controller = TextEditingController(text: 'Dominican Republic');

  List<University> universities = [];

  bool loading = false;
  bool searched = false;
  String? error;
  String searchedCountry = '';

  Future<void> search() async {
    if (loading) return;

    FocusScope.of(context).unfocus();

    final country = controller.text.trim();

    if (country.isEmpty) {
      setState(() {
        error = 'Introduce un país en inglés.';
        universities = [];
        searched = false;
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
      universities = [];
      searched = false;
    });

    try {
      final results = await UniversityService.search(country);

      if (!mounted) return;

      setState(() {
        universities = results;
        searchedCountry = country;
        searched = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e is UniversityServiceException
            ? e.message
            : 'No fue posible consultar las universidades.';
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> openWebsite(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      showMessage('El enlace no es válido.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      if (!opened) {
        showMessage('No fue posible abrir la página.');
      }
    } catch (_) {
      showMessage('No fue posible abrir la página.');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universidades')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Icon(
                Icons.school_outlined,
                size: 62,
                color: Color(0xFF0D9488),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Explora universidades',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                color: ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Busca instituciones de educación superior '
              'por país y descubre sus páginas web.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 28),

            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => search(),
              decoration: InputDecoration(
                labelText: 'País en inglés',
                hintText: 'Ejemplo: Dominican Republic',
                prefixIcon: const Icon(Icons.public),
                suffixIcon: IconButton(
                  tooltip: 'Limpiar',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    setState(() {
                      universities = [];
                      searched = false;
                      error = null;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: loading ? null : search,
                icon: loading
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(loading ? 'Buscando...' : 'Buscar universidades'),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                quickCountry('Dominican Republic'),
                quickCountry('United States'),
                quickCountry('Spain'),
              ],
            ),

            const SizedBox(height: 26),

            if (error != null) errorCard(),

            if (searched && universities.isEmpty) emptyCard(),

            if (searched && universities.isNotEmpty) ...[
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Resultados',
                      style: TextStyle(
                        fontSize: 21,
                        color: ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E8FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${universities.length} encontradas',
                      style: const TextStyle(
                        color: primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                searchedCountry,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              for (final university in universities) universityCard(university),
            ],

            if (!searched && !loading && error == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 45,
                      color: Color(0xFF94A3B8),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Selecciona un país para comenzar.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget quickCountry(String country) {
    return ActionChip(
      label: Text(country),
      avatar: const Icon(Icons.public, size: 16),
      onPressed: loading
          ? null
          : () {
              controller.text = country;
              search();
            },
    );
  }

  Widget universityCard(University university) {
    final website = university.website;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F5F3),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.account_balance_outlined,
              color: Color(0xFF0D9488),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  university.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    const Icon(
                      Icons.language,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        university.domain ?? 'Dominio no disponible',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                if (website != null)
                  InkWell(
                    onTap: () => openWebsite(website),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Visitar sitio web',
                            style: TextStyle(
                              fontSize: 13,
                              color: primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.open_in_new, size: 15, color: primary),
                        ],
                      ),
                    ),
                  )
                else
                  const Text(
                    'Sitio web no disponible',
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget errorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 42, color: Color(0xFFBE123C)),
          const SizedBox(height: 12),
          const Text(
            'No se pudo completar la búsqueda',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(error!, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget emptyCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off, size: 46, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'No encontramos universidades para ese país.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            'Comprueba el nombre del país en inglés.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
