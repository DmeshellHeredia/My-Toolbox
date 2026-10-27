import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/wordpress_post.dart';
import '../services/wordpress_service.dart';

const _ink = Color(0xFF172033);
const _primary = Color(0xFF4F46E5);

class WordpressScreen extends StatefulWidget {
  const WordpressScreen({super.key});

  @override
  State<WordpressScreen> createState() => _WordpressScreenState();
}

class _WordpressScreenState extends State<WordpressScreen> {
  List<WordpressPost> _posts = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final posts = await WordpressService.fetchLatest();
      if (!mounted) return;
      setState(() => _posts = posts);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is WordpressServiceException
            ? error.message
            : 'No fue posible cargar las noticias.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _showMessage('El enlace no es válido.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        _showMessage('No se pudo abrir el enlace.');
      }
    } catch (error) {
      if (mounted) _showMessage('No se pudo abrir el navegador.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias WordPress'),
        actions: [
          IconButton(
            tooltip: 'Actualizar noticias',
            onPressed: _loading ? null : _loadNews,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadNews,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _siteHeader(),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Últimas 3 noticias',
                      style: TextStyle(
                        color: _ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!_loading && _error == null)
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF059669),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Titulares, resúmenes y enlaces a los artículos originales.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 18),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 85),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_loading && _error != null) _errorCard(),
              if (!_loading && _error == null)
                for (var i = 0; i < _posts.length; i++) ...[
                  _postCard(_posts[i], i + 1),
                  const SizedBox(height: 14),
                ],
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: () => _openUrl(WordpressService.siteUrl),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Visitar WP Tavern'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _siteHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6863A9)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Image.network(
              WordpressService.siteIconUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, error, stackTrace) =>
                  const Icon(Icons.article_outlined, size: 38, color: _primary),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WP Tavern',
                  style: TextStyle(
                    fontSize: 23,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Noticias del mundo WordPress',
                  style: TextStyle(fontSize: 12, color: Color(0xFFEDE9FE)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(WordpressPost post, int number) {
    final date = post.date;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EBF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  'NOTICIA $number',
                  style: const TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            post.title,
            style: const TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            post.summary.isEmpty
                ? 'Resumen no disponible. Abre la noticia para leerla.'
                : post.summary,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _openUrl(post.url),
            icon: const Icon(Icons.open_in_new, size: 17),
            label: const Text('Leer noticia original'),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 42, color: Color(0xFFBE123C)),
          const SizedBox(height: 12),
          const Text(
            'No se pudieron cargar las noticias',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 9),
          Text(
            _error ?? 'Ocurrió un error inesperado.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9F1239)),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _loadNews,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
