import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tempori/user_app.dart';
import 'package:tempori/user_main.dart' as user_design;

void main() {
  testWidgets('Tempori menampilkan halaman pembuka dengan identitas aplikasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: temporiTheme, home: const UserLoginPage()),
    );

    expect(find.text('Tempori'), findsOneWidget);
    expect(
      find.text('Simpan, Pantau,\nJangan Sampai Terlambat'),
      findsOneWidget,
    );
    expect(find.text('Masuk'), findsOneWidget);
    expect(find.byType(user_design.WelcomeIllustration), findsOneWidget);
  });

  testWidgets('Pengguna dapat membuka formulir registrasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: temporiTheme, home: const UserLoginPage()),
    );

    final registerLink = find.text('Belum punya akun? Daftar sekarang');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.text('Yuk, buat akunmu!'), findsOneWidget);
    expect(find.text('Nama Lengkap'), findsOneWidget);
    expect(find.text('Daftar'), findsOneWidget);
  });

  testWidgets('Pengguna dapat membuka halaman masuk dari halaman pembuka', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: temporiTheme, home: const UserLoginPage()),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Selamat datang\nkembali!'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Masuk sebagai admin'), findsNothing);
  });

  testWidgets('Kategori menampilkan jumlah stok tiap kategori', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: temporiTheme,
        home: CategoriesPage(
          items: [
            TemporiItem(
              id: 'item-1',
              name: 'Susu',
              category: 'Makanan',
              quantity: 8,
              expiryDate: DateTime(2026, 12, 20),
            ),
          ],
        ),
      ),
    );

    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('8 barang'), findsOneWidget);
    expect(find.text('Skincare'), findsOneWidget);
  });

  testWidgets(
    'Pengingat menampilkan barang kedaluwarsa dan yang segera habis',
    (WidgetTester tester) async {
      final today = DateTime.now();
      TemporiItem item(String id, String name, int days) => TemporiItem(
        id: id,
        name: name,
        category: 'Makanan',
        quantity: 1,
        expiryDate: DateTime(today.year, today.month, today.day + days),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: temporiTheme,
          home: Scaffold(
            body: RemindersPage(
              items: [
                item('expired', 'Barang Terlambat', -2),
                item('soon', 'Barang Segera', 3),
                item('later', 'Barang Aman', 60),
              ],
              isLoading: false,
              onOpenItem: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Barang Terlambat'), findsOneWidget);
      expect(find.text('Barang Segera'), findsOneWidget);
      expect(find.text('Barang Aman'), findsNothing);
    },
  );

  testWidgets('Form tambah barang mencakup foto dan catatan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: temporiTheme, home: const ItemFormPage()),
    );

    expect(find.text('Tambah Barang'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Catatan (opsional)'),
      250,
      scrollable: find.descendant(
        of: find.byType(ListView),
        matching: find.byType(Scrollable),
      ).first,
    );
    expect(find.text('Tambah Foto'), findsOneWidget);
    expect(find.text('Catatan (opsional)'), findsOneWidget);
    expect(find.text('Simpan'), findsOneWidget);
  });
}
