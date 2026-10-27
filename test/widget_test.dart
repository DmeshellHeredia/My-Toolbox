import 'package:flutter_test/flutter_test.dart';
import 'package:my_toolbox/main.dart';

void main() {
  testWidgets('El dashboard muestra las herramientas', (tester) async {
    await tester.pumpWidget(const MyToolboxApp());

    expect(find.text('My Toolbox'), findsOneWidget);
    expect(find.text('Género'), findsOneWidget);
    expect(find.text('Persona aleatoria'), findsOneWidget);
  });
}
