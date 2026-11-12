import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app_biodemeter/main.dart';
import 'package:flutter_app_biodemeter/core/services/service_locator.dart';

void main() {
  setUpAll(() {
    setupLocator();
  });

  testWidgets('Smoke test: Verifica que la app inicie en el Login', (WidgetTester tester) async {
    await tester.pumpWidget(const BioDemeterApp());

    await tester.pumpAndSettle();

    expect(find.text('PlantSync'), findsWidgets);
    
    expect(find.text('Ingresar'), findsWidgets);
  });
}