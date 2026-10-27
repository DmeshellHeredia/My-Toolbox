import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/random_person.dart';
import '../services/random_user_service.dart';

class RandomUserScreen extends StatefulWidget {
  const RandomUserScreen({super.key});

  @override
  State<RandomUserScreen> createState() => _RandomUserScreenState();
}

class _RandomUserScreenState extends State<RandomUserScreen> {
  late Future<RandomPerson> _personFuture;

  static const primary = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _personFuture = RandomUserService.fetchPerson();
  }

  void _generatePerson() {
    setState(() {
      _personFuture = RandomUserService.fetchPerson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Persona aleatoria')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            const Center(
              child: Icon(
                Icons.person_search_outlined,
                color: primary,
                size: 60,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Conoce a alguien nuevo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Genera un perfil aleatorio con datos '
              'proporcionados por Random User.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 28),

            FutureBuilder<RandomPerson>(
              future: _personFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 90),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return _errorCard(snapshot.error);
                }

                final person = snapshot.data;

                if (person == null) {
                  return _errorCard(null);
                }

                return _profileCard(person);
              },
            ),

            const SizedBox(height: 22),

            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _generatePerson,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text(
                  'Generar otra persona',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Los perfiles se generan con fines de prueba '
              'y demostración. No representan identidades '
              'verificadas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(RandomPerson person) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(person.birthDate);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE8EBF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Color(0xFFE9E8FF),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.network(
                person.photoUrl,
                width: 125,
                height: 125,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 125,
                    height: 125,
                    child: Icon(Icons.person, color: primary, size: 75),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            person.fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE9E8FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'Perfil generado',
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 25),
          const Divider(color: Color(0xFFE8EBF2)),
          const SizedBox(height: 10),

          _infoRow(Icons.badge_outlined, 'Nombre', person.firstName),
          _infoRow(Icons.person_outline, 'Apellido', person.lastName),
          _infoRow(Icons.cake_outlined, 'Fecha de nacimiento', formattedDate),
          _infoRow(Icons.calendar_month_outlined, 'Edad', '${person.age} años'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF172033),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(Object? error) {
    final message = error is RandomUserException
        ? error.message
        : 'No fue posible obtener el perfil.';

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_outlined,
            color: Color(0xFFBE123C),
            size: 42,
          ),
          const SizedBox(height: 14),
          const Text(
            'No pudimos cargar el perfil',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9F1239)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Pulsa "Generar otra persona" para reintentar.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
