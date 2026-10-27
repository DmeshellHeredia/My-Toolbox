import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const _purple = Color(0xFF58549C);
const _ink = Color(0xFF172033);
const _muted = Color(0xFF64748B);
const _pageBackground = Color(0xFFF7F8FC);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Puedes modificar estos datos antes de publicar el APK.
  static const String _fullName = 'Michael Dmeshell Sanchez Heredia';
  static const String _studentId = '20240063';
  static const String _email = '20240063@itla.edu.do';
  static const String _phone = '829-722-3724';
  static const String _githubUsername = 'DmeshellHeredia';
  static const String _githubUrl = 'https://github.com/DmeshellHeredia';
  static const String _projectUrl =
      'https://github.com/DmeshellHeredia/flowermatch';

  Future<void> _openLink(BuildContext context, Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showError(context);
      }
    } catch (_) {
      if (context.mounted) _showError(context);
    }
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'No se encontró una aplicación compatible para abrir este enlace.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        title: const Text('Acerca de'),
        backgroundColor: _pageBackground,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                _profileCard(),
                const SizedBox(height: 18),
                _sectionCard(
                  title: 'Sobre mí',
                  icon: Icons.person_outline_rounded,
                  child: const Text(
                    'Soy estudiante de Desarrollo de Software en el Instituto '
                    'Tecnológico de las Américas (ITLA). Me interesa crear '
                    'aplicaciones útiles, resolver problemas mediante la '
                    'tecnología y seguir desarrollándome profesionalmente.',
                    style: TextStyle(fontSize: 14, height: 1.55, color: _muted),
                  ),
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'Tecnologías',
                  icon: Icons.code_rounded,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      'Flutter',
                      'Dart',
                      'Java',
                      '.NET',
                      'React',
                      'MySQL',
                      'Git',
                    ].map(_skillChip).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'Proyecto destacado',
                  icon: Icons.folder_open_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FlowerMatch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Aplicación que recomienda flores según la ocasión '
                        'mediante procesamiento de lenguaje natural. '
                        'Desarrollada con Next.js, PHP y Python.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openLink(context, Uri.parse(_projectUrl)),
                        icon: const Icon(Icons.open_in_new_rounded, size: 17),
                        label: const Text('Ver repositorio'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _sectionCard(
                  title: 'Contacto profesional',
                  icon: Icons.contact_mail_outlined,
                  child: Column(
                    children: [
                      _contactTile(
                        icon: Icons.email_outlined,
                        title: 'Correo electrónico',
                        subtitle: _email,
                        onTap: () => _openLink(
                          context,
                          Uri(scheme: 'mailto', path: _email),
                        ),
                      ),
                      const Divider(height: 18, color: Color(0xFFEDF0F5)),
                      _contactTile(
                        icon: Icons.call_outlined,
                        title: 'Teléfono',
                        subtitle: _phone,
                        onTap: () =>
                            _openLink(context, Uri.parse('tel:+18297223724')),
                      ),
                      const Divider(height: 18, color: Color(0xFFEDF0F5)),
                      _contactTile(
                        icon: Icons.code_rounded,
                        title: 'GitHub',
                        subtitle: '@$_githubUsername',
                        onTap: () => _openLink(context, Uri.parse(_githubUrl)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'My Toolbox · Aplicación académica desarrollada en Flutter',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9EAF2)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 98,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF746CAF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -46),
            child: Container(
              width: 108,
              height: 108,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/profile/foto.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF2F0FF),
                      alignment: Alignment.center,
                      child: const Text(
                        'MH',
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
          Transform.translate(
            offset: const Offset(0, -32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const Text(
                    _fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 21,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Desarrollo de Software',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _purple,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Instituto Tecnológico de las Américas · ITLA',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Matrícula: $_studentId',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: _purple),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: _ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  static Widget _skillChip(String skill) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F0FF),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        skill,
        style: const TextStyle(
          color: _purple,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F0FF),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: _purple),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, size: 17, color: _muted),
          ],
        ),
      ),
    );
  }
}
