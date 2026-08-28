import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:rick_and_morty_challenge/src/app/app.dart';

void main() {
  testWidgets('navigates between shell destinations', (tester) async {
    await tester.pumpWidget(const RickAndMortyApp());

    expect(find.text('Rota Home'), findsOneWidget);

    await tester.tap(find.text('Planetas'));
    await tester.pumpAndSettle();

    expect(find.text('Rota Planetas'), findsOneWidget);
  });

  testWidgets('toggles between dark and light themes', (tester) async {
    await tester.pumpWidget(const RickAndMortyApp());

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    await tester.tap(find.byKey(const ValueKey('theme-toggle')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });
}
