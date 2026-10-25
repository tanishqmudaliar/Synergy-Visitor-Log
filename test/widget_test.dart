import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synergyvisitorlog/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('MyApp mounts and displays HomePage', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('HomePage renders welcome header and subtitle', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(
      find.textContaining('Thanks for visiting! Enroll yourself if this is your first visit'),
      findsOneWidget,
    );
  });

  testWidgets('HomePage displays all four core navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    // In button
    expect(find.text('In'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);

    // Out button
    expect(find.text('Out'), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);

    // Enroll button
    expect(find.text('Enroll'), findsOneWidget);
    expect(find.byIcon(Icons.fiber_new_rounded), findsOneWidget);

    // Members button
    expect(find.text('Members'), findsOneWidget);
    expect(find.byIcon(Icons.people_alt_rounded), findsOneWidget);
  });

  testWidgets('HomePage resetApp initializes steps in SharedPreferences', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'name': 'Existing Name',
      'number': '9876543210',
      'imagePath': '/path/to/img.jpg',
    });

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('name'), isNull);
    expect(prefs.getString('number'), isNull);
    expect(prefs.getString('imagePath'), isNull);
    expect(prefs.getStringList('steps'), equals(['1', '2', '3']));
  });
}
