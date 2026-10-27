import 'package:html/parser.dart' as html_parser;
import 'package:xml/xml.dart';

class WordpressPost {
  final String title;
  final String summary;
  final String url;
  final DateTime? date;

  const WordpressPost({
    required this.title,
    required this.summary,
    required this.url,
    this.date,
  });

  factory WordpressPost.fromJson(Map<String, dynamic> json) {
    final titleData = json['title'];
    final excerptData = json['excerpt'];

    final titleHtml = titleData is Map ? titleData['rendered'] : titleData;
    final excerptHtml = excerptData is Map
        ? excerptData['rendered']
        : excerptData;

    return WordpressPost(
      title: _cleanHtml(titleHtml?.toString() ?? ''),
      summary: _cleanHtml(excerptHtml?.toString() ?? ''),
      url: json['link']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
    );
  }

  factory WordpressPost.fromRss(XmlElement element) {
    String field(String tag) => element.getElement(tag)?.innerText.trim() ?? '';

    return WordpressPost(
      title: _cleanHtml(field('title')),
      summary: _cleanHtml(field('description')),
      url: field('link'),
      // La fecha RSS usa RFC 822; no se presenta una fecha inventada.
      date: null,
    );
  }

  bool get isValid {
    final parsed = Uri.tryParse(url);
    return title.isNotEmpty &&
        parsed != null &&
        (parsed.scheme == 'https' || parsed.scheme == 'http') &&
        parsed.host.isNotEmpty;
  }

  static String _cleanHtml(String html) {
    final plainText = html_parser.parseFragment(html).text;
    return (plainText ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
