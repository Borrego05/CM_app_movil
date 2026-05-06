import 'package:flutter_test/flutter_test.dart';
import 'package:cm_app/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Pasamos isLoggedIn: false para que muestre la pantalla de login.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verificamos que aparezca el texto 'Iniciar Sesión'.
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    
    // Verificamos que aparezca el botón 'Iniciar'.
    expect(find.text('Iniciar'), findsOneWidget);
  });
}
