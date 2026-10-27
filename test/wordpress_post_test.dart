import 'package:flutter_test/flutter_test.dart';
import 'package:my_toolbox/models/wordpress_post.dart';
import 'package:xml/xml.dart';

void main() {
  test('Interpreta noticias WordPress y elimina etiquetas HTML', () {
    final post = WordpressPost.fromJson({
      'title': {'rendered': 'Una noticia &amp; otra <strong>novedad</strong>'},
      'excerpt': {'rendered': '<p>Resumen de <em>WordPress</em>.</p>'},
      'link': 'https://wptavern.com/noticia-ejemplo',
      'date': '2026-10-26T10:00:00',
    });
    expect(post.title, 'Una noticia & otra novedad');
    expect(post.summary, 'Resumen de WordPress.');
    expect(post.date, isNotNull);
    expect(post.isValid, isTrue);
  });

  test('Puede leer una noticia de respaldo RSS', () {
    final document = XmlDocument.parse('''
      <rss><channel><item>
        <title>Nuevo artículo</title>
        <description><![CDATA[<p>Un <b>resumen</b>.</p>]]></description>
        <link>https://wptavern.com/articulo</link>
      </item></channel></rss>
    ''');
    final post = WordpressPost.fromRss(document.findAllElements('item').first);
    expect(post.title, 'Nuevo artículo');
    expect(post.summary, 'Un resumen.');
    expect(post.isValid, isTrue);
  });

  test('Rechaza enlaces inválidos', () {
    const post = WordpressPost(
      title: 'Noticia',
      summary: 'Resumen',
      url: 'javascript:alert(1)',
    );
    expect(post.isValid, isFalse);
  });
}
