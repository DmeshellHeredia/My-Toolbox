import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:my_toolbox/services/university_service.dart';

void main() {
  const apiResult = '''[
    {
      "name": "Universidad Beta",
      "country": "Testonia",
      "domains": ["beta.edu"],
      "web_pages": ["https://beta.edu"]
    },
    {
      "name": "Universidad Alfa",
      "country": "Testonia",
      "domains": ["alfa.edu"],
      "web_pages": ["https://alfa.edu"]
    }
  ]''';

  test('Reintenta el proxy si primero devuelve HTTP 503', () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      if (request.url.host != 'adamix.net') {
        fail('No debe usar la fuente alternativa si el proxy se recupera.');
      }
      if (requests == 1) return http.Response('Servicio no disponible', 503);
      return http.Response(apiResult, 200);
    });

    final results = await UniversityService.search('Testonia', client: client);
    expect(requests, 2);
    expect(results.map((e) => e.name), [
      'Universidad Alfa',
      'Universidad Beta',
    ]);

    // La misma búsqueda debe resolverse desde la caché.
    final cached = await UniversityService.search(
      '  testonia ',
      client: client,
    );
    expect(cached.length, 2);
    expect(requests, 2);
    client.close();
  });

  test(
    'Usa la fuente HTTPS alternativa si el proxy falla tres veces',
    () async {
      var proxyRequests = 0;
      var backupRequests = 0;
      final client = MockClient((request) async {
        if (request.url.host == 'adamix.net') {
          proxyRequests++;
          return http.Response('Error temporal', 503);
        }
        if (request.url.host == 'raw.githubusercontent.com') {
          backupRequests++;
          expect(request.url.scheme, 'https');
          return http.Response(
            '''[
          {"name":"Universidad Backup","country":"Backupia", "domains":["backup.edu"],"web_pages":["https://backup.edu"]},
          {"name":"Universidad Otro País","country":"Otherland","domains":[],"web_pages":[]}
        ]''',
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        }
        fail('Origen inesperado: ${request.url.host}');
      });

      final results = await UniversityService.search(
        'Backupia',
        client: client,
      );
      expect(proxyRequests, 3);
      expect(backupRequests, 1);
      expect(results.length, 1);
      expect(results.single.name, 'Universidad Backup');
      client.close();
    },
  );

  test('Valida un país vacío sin hacer peticiones', () async {
    final client = MockClient((_) async {
      fail('No debe contactar el servidor con un país vacío.');
    });
    await expectLater(
      UniversityService.search('  ', client: client),
      throwsA(isA<UniversityServiceException>()),
    );
    client.close();
  });
}
