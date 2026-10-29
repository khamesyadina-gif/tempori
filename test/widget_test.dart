import 'package:flutter_test/flutter_test.dart';
import 'package:tempori/main.dart';

void main() {
  testWidgets('Tempori menampilkan halaman pembuka', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TemporiApp());

    expect(find.text('Tempori'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
  });

  testWidgets('Tombol Mulai membuka halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TemporiApp());

    await tester.tap(find.text('Mulai'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}