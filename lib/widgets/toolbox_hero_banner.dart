import 'package:flutter/material.dart';

/// Banner principal de My Toolbox.
/// Usa una imagen local para funcionar incluso sin Internet.
class ToolboxHeroBanner extends StatelessWidget {
  const ToolboxHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final small = constraints.maxWidth < 340;
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: SizedBox(
            width: double.infinity,
            height: small ? 184 : 194,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/toolbox_cover.jpg',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (context, error, stackTrace) {
                    return const ColoredBox(color: Color(0xFF4239A5));
                  },
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xF52E267B),
                        Color(0xDD4235A5),
                        Color(0x884F46E5),
                        Color(0x112E267B),
                      ],
                      stops: [0, 0.37, 0.66, 1],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'MY TOOLBOX',
                        style: TextStyle(
                          color: Color(0xFFE2DFFF),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 9),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: small ? 215 : 235,
                        ),
                        child: const Text(
                          'Tu caja de\nherramientas',
                          style: TextStyle(
                            fontSize: 23,
                            height: 1.13,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: small ? 204 : 225,
                        ),
                        child: const Text(
                          'Siete utilidades en una sola aplicación.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: Color(0xFFF2F0FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
