import 'package:flutter_test/flutter_test.dart';
import 'package:my_toolbox/models/university.dart';

void main() {
  test('Interpreta correctamente los datos universitarios', () {
    final university = University.fromJson({
      'name': 'Instituto Tecnológico de Las Américas',
      'country': 'Dominican Republic',
      'domains': ['itla.edu.do'],
      'web_pages': ['https://itla.edu.do/'],
    });

    expect(university.name, 'Instituto Tecnológico de Las Américas');
    expect(university.country, 'Dominican Republic');
    expect(university.domain, 'itla.edu.do');
    expect(university.website, 'https://itla.edu.do/');
  });

  test('Maneja dominios y enlaces vacíos', () {
    final university = University.fromJson({
      'name': 'Universidad de prueba',
      'country': 'Test Country',
      'domains': [],
      'web_pages': [],
    });

    expect(university.domain, isNull);
    expect(university.website, isNull);
  });
}
