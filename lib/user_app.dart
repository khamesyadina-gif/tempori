import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import 'admin_login_page.dart';
import 'user_main.dart' as user_design;
import 'notification_service.dart';

const lavender = Color(0xFF9A72D2);
const darkLavender = Color(0xFF68458F);
const appBackground = Color(0xFFFFFAF8);
const ink = Color(0xFF342743);
const mutedInk = Color(0xFF897B91);
const lavenderBorder = Color(0xFFE9DDF0);
const lavenderSoft = Color(0xFFF2EAF8);
const blushSoft = Color(0xFFFFE9EE);
const peachSoft = Color(0xFFFFF0DF);
const blueSoft = Color(0xFFEAF1FC);
const itemCategories = [
  'Cosmetics',
  'Documents',
  'Food & Beverages',
  'Medicines',
  'Skincare',
];

const itemCategoryImages = <String, String>{
  'Cosmetics': 'assets/images/category_cosmetics.png',
  'Documents': 'assets/images/category_documents.png',
  'Food & Beverages': 'assets/images/category_food.png',
  'Medicines': 'assets/images/category_medicines.png',
  'Skincare': 'assets/images/category_skincare.png',
};

final temporiTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: appBackground,
  colorScheme: ColorScheme.fromSeed(
    seedColor: lavender,
    primary: lavender,
    secondary: darkLavender,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: appBackground,
    foregroundColor: ink,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: ink,
      fontSize: 22,
      fontWeight: FontWeight.w800,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFEAE5F0)),
    ),
    margin: EdgeInsets.zero,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: const TextStyle(color: mutedInk, fontSize: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: lavenderBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: lavenderBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: const BorderSide(color: lavender, width: 1.7),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: darkLavender,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  ),
);

class TemporiItem {
  const TemporiItem({
    required this.id,
    required this.name,
    this.categoryId = '',
    this.category = '',
    required this.quantity,
    required this.expiryDate,
    this.imageUrl,
    this.storageLocation,
    this.createdAt,
  });

  final String id;
  final String name;
  final String categoryId;
  final String category;
  final int quantity;
  final DateTime expiryDate;
  final String? imageUrl;
  final String? storageLocation;
  final DateTime? createdAt;

  factory TemporiItem.fromMap(
    Map<String, dynamic> map, {
    required String categoryName,
  }) {
    final rawDate = map['expiry_date'];
    return TemporiItem(
      id: map['item_id'].toString(),
      name: map['item_name'] as String? ?? '',
      categoryId: map['category_id'].toString(),
      category: categoryName,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      expiryDate: DateTime.parse(rawDate as String).toLocal(),
      imageUrl: map['photo_url'] as String?,
      storageLocation: map['storage_location'] as String?,
      createdAt: map['created_at'] is String
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap(String userId) => {
    'user_id': userId,
    'category_id': categoryId,
    'item_name': name,
    'photo_url': imageUrl,
    'expiry_date': _dateOnly(expiryDate),
    'quantity': quantity,
    'storage_location': storageLocation,
  };

  int get daysUntilExpiry {
    final today = DateTime.now();
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    return expiry.difference(currentDay).inDays;
  }
}

String _dateOnly(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

String _displayDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')} '
    '${_monthName(date.month)} ${date.year}';

String _monthName(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
][month - 1];

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : client.auth.currentSession;
        if (session != null) return const UserShell();
        return const UserLoginPage();
      },
    );
  }
}

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showWelcome = true;
  bool _isRegistering = false;
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    if (email.isEmpty || password.isEmpty || (_isRegistering && name.isEmpty)) {
      _showMessage('Lengkapi semua kolom terlebih dahulu.');
      return;
    }
    if (_isRegistering && password.length < 6) {
      _showMessage('Password minimal 6 karakter.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = Supabase.instance.client.auth;
      if (_isRegistering) {
        final response = await auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );
        if (response.session != null) {
          await auth.signOut();
        }
        if (!mounted) return;
        if (response.session == null) {
          setState(() => _isRegistering = false);
          _showMessage(
            'Registrasi berhasil. Silakan konfirmasi email melalui tautan '
            'yang kami kirim, lalu masuk dengan akunmu.',
          );
        } else {
          setState(() => _isRegistering = false);
          _showMessage(
            'Registrasi berhasil. Silakan masuk dengan akun yang baru dibuat.',
          );
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (error) {
      final message = error.message.toLowerCase();
      if (message.contains('email not confirmed') ||
          message.contains('email_not_confirmed')) {
        _showMessage(
          'Email belum dikonfirmasi. Periksa kotak masuk dan konfirmasi email '
          'terlebih dahulu sebelum masuk.',
        );
      } else {
        _showMessage(error.message);
      }
    } on PostgrestException catch (error) {
      _showMessage('Gagal menghubungkan ke Supabase: ${error.message}');
    } catch (error) {
      _showMessage('Gagal masuk: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  top: _showWelcome ? 120 : -105,
                  right: -100,
                  child: IgnorePointer(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFE9DFFF).withValues(alpha: 0.7),
                            const Color(0xFFF7F1FF).withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showWelcome)
                  _buildWelcome(constraints.maxHeight)
                else
                  _buildLogin(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcome(double availableHeight) {
    final illustrationHeight = (availableHeight * 0.41)
        .clamp(180.0, 265.0)
        .toDouble();
    final brandSize = availableHeight < 600 ? 92.0 : 104.0;

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: availableHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      user_design.TemporiBrand(size: brandSize),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE4F8),
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: const Text(
                          'Simpan, Pantau,\nJangan Sampai Terlambat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF75518D),
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      user_design.WelcomeIllustration(
                        height: illustrationHeight,
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: lavenderBorder.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkLavender.withValues(alpha: 0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => setState(() {
                              _showWelcome = false;
                              _isRegistering = false;
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lavender,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: lavender.withValues(alpha: 0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 14),
                                Icon(Icons.arrow_forward_rounded, size: 21),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () => setState(() {
                            _showWelcome = false;
                            _isRegistering = true;
                          }),
                          style: TextButton.styleFrom(
                            foregroundColor: mutedInk,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text.rich(
                            TextSpan(
                              text: 'Belum punya akun? ',
                              children: [
                                TextSpan(
                                  text: 'Daftar sekarang',
                                  style: TextStyle(
                                    color: darkLavender,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                tooltip: 'Kembali',
                onPressed: () => setState(() {
                  _showWelcome = true;
                  _isRegistering = false;
                }),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 19,
                  color: ink,
                ),
              ),
              const SizedBox(height: 4),
              const Center(child: user_design.TemporiBrand(size: 74)),
              const SizedBox(height: 30),
              Text(
                _isRegistering
                    ? 'Yuk, buat akunmu!'
                    : 'Selamat datang\nkembali!',
                style: const TextStyle(
                  color: ink,
                  fontSize: 25,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRegistering
                    ? 'Daftar dan mulai pantau barang kesayanganmu.'
                    : 'Masuk untuk melanjutkan mengelola barang kamu.',
                style: const TextStyle(
                  color: mutedInk,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              if (_isRegistering) ...[
                _fieldLabel('Nama Lengkap'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: _authFieldDecoration(
                    'Nama lengkap',
                    Icons.person_outline_rounded,
                  ),
                ),
                const SizedBox(height: 17),
              ],
              _fieldLabel('Email'),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: _authFieldDecoration(
                  'Email',
                  Icons.mail_outline_rounded,
                ),
              ),
              const SizedBox(height: 17),
              _fieldLabel('Password'),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _hidePassword,
                textInputAction: TextInputAction.done,
                autofillHints: [
                  _isRegistering
                      ? AutofillHints.newPassword
                      : AutofillHints.password,
                ],
                onSubmitted: (_) {
                  if (!_isLoading) _submit();
                },
                decoration:
                    _authFieldDecoration(
                      'Password',
                      Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        tooltip: _hidePassword
                            ? 'Tampilkan password'
                            : 'Sembunyikan password',
                        onPressed: () =>
                            setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: ink,
                          size: 20,
                        ),
                      ),
                    ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lavender,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: lavender.withValues(alpha: 0.6),
                    elevation: 2,
                    shadowColor: lavender.withValues(alpha: 0.24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.4,
                          ),
                        )
                      : Text(
                          _isRegistering ? 'Daftar' : 'Masuk',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 13),
              Center(
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => setState(() => _isRegistering = !_isRegistering),
                  child: Text.rich(
                    TextSpan(
                      text: _isRegistering
                          ? 'Sudah punya akun? '
                          : 'Belum punya akun? ',
                      children: [
                        TextSpan(
                          text: _isRegistering ? 'Masuk' : 'Daftar sekarang',
                          style: const TextStyle(
                            color: darkLavender,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(color: mutedInk, fontSize: 13),
                  ),
                ),
              ),
              if (kIsWeb)
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AdminLoginPage(),
                      ),
                    ),
                    child: const Text(
                      'Masuk sebagai admin',
                      style: TextStyle(color: mutedInk, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: ink,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  InputDecoration _authFieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9A92A8), fontSize: 14),
      prefixIcon: Icon(icon, color: ink, size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F0FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(color: lavender, width: 1.4),
      ),
    );
  }
}

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int _tabIndex = 0;
  _ReminderFilter _reminderFilter = _ReminderFilter.all;
  String? _categoryFilter;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _loadError;
  List<TemporiItem> _items = [];
  Map<String, String> _categoryNames = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthException('Sesi berakhir. Silakan masuk kembali.');
      }
      final client = Supabase.instance.client;
      final categoryRows = await client
          .from('categories')
          .select('category_id, category_name')
          .order('category_name');
      final categoryNames = <String, String>{
        for (final row in categoryRows)
          row['category_id'].toString(): row['category_name'] as String,
      };
      final rows = await client
          .from('items')
          .select(
            'item_id, user_id, category_id, item_name, photo_url, expiry_date, quantity, storage_location, created_at',
          )
          .eq('user_id', userId)
          .order('expiry_date');
      if (!mounted) return;
      setState(() {
        _categoryNames = categoryNames;
        _items = rows
            .map((row) {
              final categoryId = row['category_id'].toString();
              return TemporiItem.fromMap(
                row,
                categoryName: categoryNames[categoryId] ?? 'Kategori lain',
              );
            })
            .toList(growable: false);
        _isLoading = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat barang dari Supabase: ${error.message}';
        _isLoading = false;
      });
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Gagal memuat barang: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm([TemporiItem? item]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemFormPage(item: item, categoryNames: _categoryNames),
      ),
    );
    if (saved == true) await _loadItems();
  }

  Future<void> _openItem(TemporiItem item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ItemDetailPage(
          item: item,
          onEdit: () => _openForm(item),
          onDelete: () => _deleteItem(item),
        ),
      ),
    );
    if (changed == true) await _loadItems();
  }

  Future<void> _deleteItem(TemporiItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus barang?'),
        content: Text('Barang "${item.name}" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw const AuthException('Sesi berakhir.');
      await Supabase.instance.client
          .from('items')
          .delete()
          .eq('item_id', item.id)
          .eq('user_id', userId);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      _showMessage('Gagal menghapus barang: ${error.message}');
    } on AuthException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Gagal menghapus barang: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        items: _items,
        isLoading: _isLoading,
        loadError: _loadError,
        onRetry: _loadItems,
        onSelectTab: (index) => setState(() => _tabIndex = index),
        onCategorySelected: (category) {
          setState(() {
            _categoryFilter = category;
            _tabIndex = 1;
          });
        },
        onOpenCategories: _openCategories,
        onSearchChanged: (value) => _searchQuery = value,
        onSearchSubmitted: (value) {
          setState(() {
            _searchQuery = value;
            _tabIndex = 1;
          });
        },
        onOpenItem: _openItem,
        onAddItem: () => _openForm(),
        onSummaryTap: (index) => setState(() {
          if (index == 0) {
            _tabIndex = 1;
          } else {
            _tabIndex = 2;
            _reminderFilter = index == 1
                ? _ReminderFilter.upcoming
                : _ReminderFilter.expired;
          }
        }),
      ),
      ItemsPage(
        items: _items,
        isLoading: _isLoading,
        category: _categoryFilter,
        query: _searchQuery,
        onCategoryChanged: (value) => setState(() => _categoryFilter = value),
        onOpenItem: _openItem,
        onAddItem: () => _openForm(),
      ),
      RemindersPage(
        items: _items,
        isLoading: _isLoading,
        initialFilter: _reminderFilter,
        onOpenItem: _openItem,
      ),
      ProfilePage(onProfileChanged: () => setState(() {})),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: _tabIndex, children: pages),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Barang',
        onPressed: () => _openForm(),
        backgroundColor: darkLavender,
        foregroundColor: Colors.white,
        elevation: 6,
        splashColor: lavenderSoft,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: EdgeInsets.zero,
        color: const Color(0xFFFFFCFF),
        surfaceTintColor: Colors.white,
        elevation: 8,
        shadowColor: darkLavender.withValues(alpha: 0.10),
        shape: const CircularNotchedRectangle(),
        notchMargin: 7,
        child: Row(
          children: [
            _BottomNavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: 'Beranda',
              selected: _tabIndex == 0,
              onTap: () => setState(() => _tabIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.inventory_2_outlined,
              selectedIcon: Icons.inventory_2_rounded,
              label: 'Barang',
              selected: _tabIndex == 1,
              onTap: () => setState(() => _tabIndex = 1),
            ),
            const SizedBox(width: 62),
            _BottomNavItem(
              icon: Icons.notifications_none_rounded,
              selectedIcon: Icons.notifications_active_rounded,
              label: 'Pengingat',
              selected: _tabIndex == 2,
              onTap: () => setState(() => _tabIndex = 2),
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Profil',
              selected: _tabIndex == 3,
              onTap: () => setState(() => _tabIndex = 3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCategories() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => CategoriesPage(items: _items)),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _categoryFilter = selected;
      _tabIndex = 1;
    });
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.items,
    required this.isLoading,
    required this.loadError,
    required this.onRetry,
    required this.onSelectTab,
    required this.onCategorySelected,
    required this.onOpenCategories,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onOpenItem,
    required this.onAddItem,
    required this.onSummaryTap,
    super.key,
  });

  final List<TemporiItem> items;
  final bool isLoading;
  final String? loadError;
  final Future<void> Function() onRetry;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onOpenCategories;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSearchSubmitted;
  final ValueChanged<TemporiItem> onOpenItem;
  final VoidCallback onAddItem;
  final ValueChanged<int> onSummaryTap;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final firstName = (user?.userMetadata?['full_name'] as String? ?? 'Teman')
        .split(' ')
        .first;
    final expiringCount = items
        .where((item) => item.daysUntilExpiry >= 0 && item.daysUntilExpiry <= 7)
        .length;
    final totalItems = items.length;
    final categories = itemCategories
        .map(
          (category) => (
            category,
            itemCategoryImages[category]!,
            items
                .where((item) => item.category == category)
                .fold<int>(0, (total, item) => total + item.quantity),
          ),
        )
        .toList();
    final latestItems = items.toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
            .compareTo(a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
      );
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              
    Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEEDFFB),
            Color(0xFFF9EAF0),
            Color(0xFFFFF1E8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: darkLavender.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS LOGO, NOTIFIKASI, DAN PROFIL
          Row(
            children: [
              const Icon(
                Icons.calendar_month_rounded,
                color: darkLavender,
                size: 27,
              ),
              const SizedBox(width: 7),
              const Text(
                'Tempori',
                style: TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Pengingat',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 38,
                  minHeight: 38,
                ),
                onPressed: () => onSelectTab(2),
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: darkLavender,
                  size: 24,
                ),
              ),
              CircleAvatar(
                radius: 17,
                backgroundColor: const Color(0xFFE5D5F8),
                foregroundColor: darkLavender,
                child: Text(
                  firstName.isEmpty
                      ? 'T'
                      : firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 17),

        
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $firstName! 👋',
                      style: const TextStyle(
                        color: ink,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Yuk, pantau barangmu biar selalu aman dari kedaluwarsa.',
                      style: TextStyle(
                        color: mutedInk,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/images/header_skincare.png',
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.spa_rounded,
                      color: Color(0xFFB58BCF),
                      size: 75,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),

              const SizedBox(height: 17),
              _SearchBar(
                onChanged: onSearchChanged,
                onSubmitted: onSearchSubmitted,
              ),
              const SizedBox(height: 24),
              _SectionHeading(
                title: 'Ringkasan',
                action: 'Lihat semua',
                onTap: () => onSelectTab(1),
              ),
              const SizedBox(height: 12),
              Row(
    
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Total Barang',
                    value: '$totalItems',
                    icon: Icons.inventory_2_outlined,
                    tint: const Color.fromARGB(255, 218, 174, 251),
                    onTap: () => onSummaryTap(0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Segera Kedaluwarsa',
                    value: '$expiringCount',
                    icon: Icons.access_time_rounded,
                    tint: const Color.fromARGB(255, 248, 230, 203),
                    onTap: () => onSummaryTap(1),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SummaryCard(
                    title: 'Kedaluwarsa',
                    value:
                        '${items.where((item) => item.daysUntilExpiry < 0).length}',
                    icon: Icons.warning_amber_rounded,
                    tint: const Color.fromARGB(255, 255, 176, 204),
                    onTap: () => onSummaryTap(2),
                  ),
                ),
              ],

              ),
              const SizedBox(height: 28),
              _SectionHeading(
                title: 'Kategori',
                action: 'Lihat semua',
                onTap: onOpenCategories,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 11),
                  itemBuilder: (context, index) {
                    if (index == categories.length) {
                      return Container(
                        width: 96,
                        margin: const EdgeInsets.only(top: 4),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onOpenCategories,
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: darkLavender,
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkLavender.withValues(alpha: 0.18),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                   final category = categories[index];
                    return _DashboardCategoryCard(
                      label: category.$1,
                      imagePath: category.$2,
                      count: category.$3,
                      onTap: () => onCategorySelected(category.$1),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              _SectionHeading(
                title: 'Barang Terbaru',
                action: 'Lihat semua',
                onTap: () => onSelectTab(1),
              ),
              const SizedBox(height: 10),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (loadError != null)
                _ErrorPanel(message: loadError!, onRetry: onRetry)
              else if (items.isEmpty)
                _EmptyPanel(
                  title: 'Belum ada barang',
                  message: 'Tambahkan barang pertamamu untuk mulai memantau tanggal kedaluwarsa.',
                  actionLabel: 'Tambah Barang',
                  onAction: onAddItem,
                )
              else
                ...latestItems
                    .take(3)
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: ItemTile(
                          item: item,
                          onTap: () => onOpenItem(item),
                        ),
                      ),
                    ),
            ]),
          ),
        ),
      ],
    );
  }
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({
    required this.items,
    required this.isLoading,
    required this.category,
    required this.query,
    required this.onCategoryChanged,
    required this.onOpenItem,
    required this.onAddItem,
    super.key,
  });

  final List<TemporiItem> items;
  final bool isLoading;
  final String? category;
  final String query;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<TemporiItem> onOpenItem;
  final VoidCallback onAddItem;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late final TextEditingController _searchController;

  String get _query => _searchController.text.trim();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant ItemsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query &&
        widget.query != _searchController.text) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = widget.items.where((item) {
      final matchesCategory =
          widget.category == null || item.category == widget.category;
      return matchesCategory &&
          item.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    return Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'assets/images/background.png',
          fit: BoxFit.cover,
        ),
      ),
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 17, 20, 11),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Barang',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Tambah barang',
                    onPressed: widget.onAddItem,
                    icon: const Icon(
                      Icons.add_circle_rounded,
                      color: lavender,
                      size: 30,
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Cari barang...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: PopupMenuButton<String>(
                    tooltip: 'Filter kategori',
                    icon: const Icon(Icons.tune_rounded),
                    onSelected: (value) =>
                        widget.onCategoryChanged(value == 'all' ? null : value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'all',
                        child: Text('Semua kategori'),
                      ),
                      for (final category in itemCategories)
                        PopupMenuItem(value: category, child: Text(category)),
                    ],
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 11),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'Semua',
                      selected: widget.category == null,
                      onTap: () => widget.onCategoryChanged(null),
                    ),
                    for (final category in itemCategories)
                      _CategoryChip(
                        label: category,
                        selected: widget.category == category,
                        onTap: () => widget.onCategoryChanged(category),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : results.isEmpty
              ? _EmptyPanel(
                  title: _query.isEmpty
                      ? 'Belum ada barang'
                      : 'Barang tidak ditemukan',
                  message: _query.isEmpty
                      ? 'Barang yang kamu tambahkan akan muncul di sini.'
                      : 'Coba kata kunci atau kategori lain.',
                  actionLabel: _query.isEmpty ? 'Tambah Barang' : null,
                  onAction: widget.onAddItem,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 90),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final item = results[index];
                    return ItemTile(
                      item: item,
                      onTap: () => widget.onOpenItem(item),
                    );
                  },
                ),
              ),
      ],
    ),
  ],
);
  }
}

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({required this.items, super.key});

  final List<TemporiItem> items;

  @override
  Widget build(BuildContext context) {
    final selectedCategories = <String>{
      ...itemCategories,
      ...items
          .map((item) => item.category)
          .where((category) => category.trim().isNotEmpty),
    }.toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: ink),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF1E7FB), Color(0xFFFFF7EE)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: darkLavender.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.category_rounded,
                      color: darkLavender,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih kategori',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${selectedCategories.length} kategori tersedia',
                          style: const TextStyle(
                            fontSize: 12,
                            color: mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final category in selectedCategories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Builder(
                          builder: (context) {
                            final count = items
                                .where((item) => item.category == category)
                                .fold<int>(0, (total, item) => total + item.quantity);
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.pop(context, category),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFFF0E3F1),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9A72D2).withValues(
                                          alpha: 0.055,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0EAFE),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Image.asset(
                                        itemCategoryImages[category]!,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.contain,
                                      ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category,
                                              style: const TextStyle(
                                                color: ink,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$count barang',
                                              style: const TextStyle(
                                                color: mutedInk,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: mutedInk,
                                        size: 22,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReminderFilter { all, upcoming, expired }

class RemindersPage extends StatefulWidget {
  const RemindersPage({
    required this.items,
    required this.isLoading,
    this.initialFilter = _ReminderFilter.all,
    this.onOpenItem = _noopOpenItem,
    super.key,
  });

  final List<TemporiItem> items;
  final bool isLoading;
  final _ReminderFilter initialFilter;
  final ValueChanged<TemporiItem> onOpenItem;

  static void _noopOpenItem(TemporiItem _) {}

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late _ReminderFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(covariant RemindersPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialFilter != oldWidget.initialFilter) {
      _filter = widget.initialFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = widget.items
        .where((item) => item.daysUntilExpiry < 0)
        .toList();

    final upcoming = widget.items
        .where(
          (item) =>
              item.daysUntilExpiry >= 0 &&
              item.daysUntilExpiry <= 7,
        )
        .toList();

    final reminders = switch (_filter) {
      _ReminderFilter.all => [...expired, ...upcoming],
      _ReminderFilter.upcoming => upcoming,
      _ReminderFilter.expired => expired,
    }..sort(
        (a, b) => a.expiryDate.compareTo(b.expiryDate),
      );

    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
        ),

        // Main content
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengingat',
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pantau barang yang akan dan\n'
                          'sudah kedaluwarsa.',
                          style: TextStyle(
                            color: mutedInk,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'assets/images/reminder_calender.png',
                    width: 160,
                    height: 145,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),

            // Filter categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  _ReminderChip(
                    label: 'Semua',
                    selected:
                        _filter == _ReminderFilter.all,
                    onTap: () {
                      setState(() {
                        _filter = _ReminderFilter.all;
                      });
                    },
                  ),

                  _ReminderChip(
                    label: 'Segera',
                    selected:
                        _filter == _ReminderFilter.upcoming,
                    onTap: () {
                      setState(() {
                        _filter = _ReminderFilter.upcoming;
                      });
                    },
                  ),

                  _ReminderChip(
                    label: 'Terlambat',
                    selected:
                        _filter == _ReminderFilter.expired,
                    onTap: () {
                      setState(() {
                        _filter = _ReminderFilter.expired;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Reminder list
            Expanded(
              child: widget.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : reminders.isEmpty
                      ? const _EmptyPanel(
                          title: 'Tidak ada pengingat',
                          message:
                              'Barang yang perlu perhatian akan tampil di sini.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            90,
                          ),
                          itemCount: reminders.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 9),
                          itemBuilder: (context, index) {
                            final item = reminders[index];

                            return ItemTile(
                              item: item,
                              onTap: () {
                                widget.onOpenItem(item);
                              },
                              showExpiry: true,
                            );
                          },
                        ),
            ),
          ],
        ),
      ],
    );
  }
}

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({
    required this.categoryNames,
    this.item,
    super.key,
  });

  final Map<String, String> categoryNames;
  final TemporiItem? item;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;

  late String _categoryId;

  DateTime? _expiryDate;
  XFile? _pickedPhoto;
  Uint8List? _photoBytes;

  bool _isSaving = false;
  int _reminderDays = 3;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    _nameController = TextEditingController(text: item?.name);

    _quantityController = TextEditingController(
      text: item == null ? '' : '${item.quantity}',
    );

    _locationController = TextEditingController(
      text: item?.storageLocation,
    );

    _notesController = TextEditingController();

    _categoryId = item?.categoryId ??
        (widget.categoryNames.keys.isEmpty
            ? ''
            : widget.categoryNames.keys.first);

    _expiryDate = item?.expiryDate;

    _loadReminderSettings();
  }

  Future<void> _loadReminderSettings() async {
    if (widget.item == null) return;

    try {
      final row = await Supabase.instance.client
          .from('reminders')
          .select('reminder_days')
          .eq('item_id', widget.item!.id)
          .maybeSingle();

      if (!mounted || row == null) return;

      final days = row['reminder_days'] as int?;

      if (days != null && [1, 3, 7].contains(days)) {
        setState(() {
          _reminderDays = days;
        });
      }
    } catch (error) {
      debugPrint('Gagal memuat pengingat: $error');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() => _expiryDate = selected);
    }
  }

  Future<void> _choosePhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari galeri'),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.gallery,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil foto'),
                onTap: () => Navigator.pop(
                  context,
                  ImageSource.camera,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final photo = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (photo == null) return;

      final bytes = await photo.readAsBytes();

      if (!mounted) return;

      setState(() {
        _pickedPhoto = photo;
        _photoBytes = bytes;
      });
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal memilih foto: $error');
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expiryDate == null) {
      _showMessage('Pilih tanggal kedaluwarsa.');
      return;
    }

    setState(() => _isSaving = true);

    String? uploadedPhotoPath;

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null) {
        throw const AuthException('Sesi berakhir.');
      }

      var photoUrl = widget.item?.imageUrl;

      if (_pickedPhoto case final photo?) {
        final rawExtension = photo.name.contains('.')
            ? photo.name.split('.').last.toLowerCase()
            : 'jpg';

        final extension =
            RegExp(r'^[a-z0-9]{1,8}$').hasMatch(rawExtension)
                ? rawExtension
                : 'jpg';

        uploadedPhotoPath =
            '$userId/${DateTime.now().microsecondsSinceEpoch}.$extension';

        await client.storage
            .from('item-photos')
            .uploadBinary(
              uploadedPhotoPath,
              _photoBytes!,
              fileOptions: FileOptions(
                contentType: photo.mimeType ?? 'image/jpeg',
                upsert: false,
              ),
            );

        photoUrl = client.storage
            .from('item-photos')
            .getPublicUrl(uploadedPhotoPath);
      }

      final item = TemporiItem(
        id: widget.item?.id ?? '',
        name: _nameController.text.trim(),
        categoryId: _categoryId,
        category:
            widget.categoryNames[_categoryId] ?? 'Kategori lain',
        quantity: int.parse(_quantityController.text.trim()),
        expiryDate: _expiryDate!,
        imageUrl: photoUrl,
        storageLocation:
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
      );

      final itemData = <String, dynamic>{
        'user_id': userId,
        'category_id': _categoryId,
        'item_name': _nameController.text.trim(),
        'photo_url': photoUrl,
        'expiry_date': _dateOnly(_expiryDate!),
        'quantity': int.parse(_quantityController.text.trim()),
        'storage_location':
            _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
      };

      debugPrint(
        'DATA YANG DIKIRIM: ${itemData.keys.toList()}',
      );

      String savedItemId;

      if (widget.item == null) {
        final inserted = await client
            .from('items')
            .insert(itemData)
            .select('item_id')
            .single();

        savedItemId = inserted['item_id'].toString();
      } else {
        savedItemId = widget.item!.id;

        await client
            .from('items')
            .update(itemData)
            .eq('item_id', savedItemId)
            .eq('user_id', userId);
      }

      final existingReminder = await client
          .from('reminders')
          .select('reminder_id')
          .eq('item_id', savedItemId)
          .maybeSingle();

      final reminderData = {
        'item_id': savedItemId,
        'reminder_days': _reminderDays,
        'is_enabled': true,
      };

      if (existingReminder != null) {
        await client
            .from('reminders')
            .update(reminderData)
            .eq(
              'reminder_id',
              existingReminder['reminder_id'],
            );
      } else {
        await client.from('reminders').insert(reminderData);
      }

      await NotificationService.scheduleExpiryReminder(
        itemId: savedItemId,
        itemName: _nameController.text.trim(),
        expiryDate: _expiryDate!,
        reminderDays: _reminderDays,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } on PostgrestException catch (error) {
      await _removeUncommittedPhoto(uploadedPhotoPath);
      _showMessage('Gagal menyimpan barang: ${error.message}');
    } on AuthException catch (error) {
      await _removeUncommittedPhoto(uploadedPhotoPath);
      _showMessage(error.message);
    } catch (error) {
      await _removeUncommittedPhoto(uploadedPhotoPath);
      _showMessage('Gagal menyimpan barang: $error');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _removeUncommittedPhoto(String? path) async {
    if (path == null) return;

    try {
      await Supabase.instance.client.storage
          .from('item-photos')
          .remove([path]);
    } catch (error) {
      _showMessage(
        'Foto terunggah, tetapi gagal dibersihkan: $error',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formFields = [
      const _FieldLabel('Nama Barang'),

      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Masukkan nama barang',
        ),
        validator: (value) =>
            value == null || value.trim().isEmpty
                ? 'Nama barang wajib diisi.'
                : null,
      ),

      const SizedBox(height: 16),

      const _FieldLabel('Kategori'),

      DropdownButtonFormField<String>(
        value: widget.categoryNames.containsKey(_categoryId)
            ? _categoryId
            : null,
        items: widget.categoryNames.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              ),
            )
            .toList(),
        onChanged: _isSaving || widget.categoryNames.isEmpty
            ? null
            : (value) {
                if (value != null) {
                  setState(() => _categoryId = value);
                }
              },
        decoration: const InputDecoration(
          hintText: 'Pilih kategori',
        ),
        validator: (value) =>
            value == null ? 'Pilih kategori barang.' : null,
      ),

      const SizedBox(height: 16),

      const _FieldLabel('Jumlah'),

      TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Masukkan jumlah',
        ),
        validator: (value) {
          final quantity = int.tryParse(value ?? '');

          return quantity == null || quantity < 1
              ? 'Jumlah harus berupa angka minimal 1.'
              : null;
        },
      ),

      const SizedBox(height: 16),

      const _FieldLabel('Tanggal Kedaluwarsa'),

      InkWell(
        onTap: _pickExpiryDate,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: const InputDecoration(
            hintText: 'Pilih tanggal',
            suffixIcon: Icon(
              Icons.calendar_month_rounded,
            ),
          ),
          child: Text(
            _expiryDate == null
                ? 'Pilih tanggal'
                : _displayDate(_expiryDate!),
            style: TextStyle(
              color: _expiryDate == null ? mutedInk : ink,
            ),
          ),
        ),
      ),

      const SizedBox(height: 16),

      const _FieldLabel('Pengingat Kedaluwarsa'),

      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFE5D9F5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingatkan saya sebelum barang kedaluwarsa',
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [1, 3, 7].map((days) {
                return ChoiceChip(
                  label: Text('$days hari sebelumnya'),
                  selected: _reminderDays == days,
                  onSelected: _isSaving
                      ? null
                      : (_) {
                          setState(() {
                            _reminderDays = days;
                          });
                        },
                  selectedColor: darkLavender,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: _reminderDays == days
                        ? Colors.white
                        : ink,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _reminderDays == days
                        ? darkLavender
                        : lavenderBorder,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),

      const SizedBox(height: 16),

      const _FieldLabel('Foto Barang (opsional)'),

      InkWell(
        onTap: _isSaving ? null : _choosePhoto,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 170,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF0EAFE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: _photoBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _photoBytes!,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                  ),
                )
              : widget.item?.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.item!.imageUrl!,
                        width: double.infinity,
                        height: 170,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _photoPlaceholder(),
                      ),
                    )
                  : _photoPlaceholder(),
        ),
      ),

      const SizedBox(height: 17),

      const _FieldLabel('Catatan (opsional)'),

      TextFormField(
        controller: _notesController,
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Tambahkan catatan penting untuk barang ini...',
        ),
      ),

      const SizedBox(height: 17),

      const _FieldLabel('Lokasi Penyimpanan (opsional)'),

      TextFormField(
        controller: _locationController,
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Contoh: Lemari dapur, kulkas, rak atas...',
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          widget.item == null
              ? 'Tambah Barang'
              : 'Edit Barang',
        ),
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          Form(
            key: _formKey,
            child: Column(
              children: [
                // Ilustrasi header
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tambah Barang',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: ink,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Catat barangmu agar lebih mudah\n'
                              'memantau masa kedaluwarsanya.',
                              style: TextStyle(
                                color: mutedInk,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Image.asset(
                        'assets/images/tambah_barang.png',
                        width: 200,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      10,
                      20,
                      16,
                    ),
                    children: formFields,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    28,
                  ),
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: lavender,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPlaceholder() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: const BoxDecoration(
            color: Color(0xFFE5D9F5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: darkLavender,
            size: 24,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          'Tambah Foto',
          style: TextStyle(
            color: ink,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Dari kamera atau galeri',
          style: TextStyle(
            color: mutedInk,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class ItemDetailPage extends StatelessWidget {
  const ItemDetailPage({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TemporiItem item;
  final Future<void> Function() onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 210,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFECE4FA),
              borderRadius: BorderRadius.circular(22),
            ),
            child: item.imageUrl == null || item.imageUrl!.isEmpty
                ? const Icon(
                    Icons.inventory_2_rounded,
                    size: 76,
                    color: darkLavender,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.network(
                      item.imageUrl!,
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.broken_image_outlined,
                        color: darkLavender,
                        size: 52,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 22),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: ink,
            ),
          ),
          const SizedBox(height: 9),
          Align(
            alignment: Alignment.centerLeft,
            child: _CategoryChip(
              label: item.category,
              selected: true,
              onTap: () {},
            ),
          ),
          const SizedBox(height: 22),
          _DetailRow(
            icon: Icons.numbers_rounded,
            label: 'Jumlah',
            value: '${item.quantity}',
          ),
          _DetailRow(
            icon: Icons.event_outlined,
            label: 'Tanggal kedaluwarsa',
            value: _displayDate(item.expiryDate),
          ),
          _DetailRow(
            icon: Icons.notifications_active_outlined,
            label: 'Status',
            value: days < 0
                ? 'Sudah kedaluwarsa'
                : days == 0
                ? 'Kedaluwarsa hari ini'
                : '$days hari lagi',
          ),
          if (item.storageLocation != null &&
              item.storageLocation!.trim().isNotEmpty)
            _DetailRow(
              icon: Icons.place_outlined,
              label: 'Lokasi penyimpanan',
              value: item.storageLocation!,
            ),
          const SizedBox(height: 25),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await onEdit();
                    if (context.mounted) Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: darkLavender,
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: lavender),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await onDelete();
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Hapus'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE8EB),
                    foregroundColor: const Color(0xFFB63F56),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({required this.onProfileChanged, super.key});

  final VoidCallback onProfileChanged;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;

  Future<void> _editProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    final controller = TextEditingController(
      text: user?.userMetadata?['full_name'] as String? ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nama lengkap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'full_name': name}),
      );
      if (!mounted) return;
      widget.onProfileChanged();
      setState(() {});
      _showMessage('Profil berhasil diperbarui.');
    } on AuthException catch (error) {
      _showMessage('Gagal memperbarui profil: ${error.message}');
    } catch (error) {
      _showMessage('Gagal memperbarui profil: $error');
    }
  }

  Future<void> _changePassword() async {
    await Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } on AuthException catch (error) {
      _showMessage('Gagal keluar: ${error.message}');
    } catch (error) {
      _showMessage('Gagal keluar: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final name =
        user?.userMetadata?['full_name'] as String? ?? 'Pengguna Tempori';
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      children: [
        const Text(
          'Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E7FB),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: darkLavender.withValues(alpha: .08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                name.isEmpty ? 'T' : name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  color: darkLavender,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(color: mutedInk, fontSize: 12),
        ),
        const SizedBox(height: 26),
        _ProfileAction(
          icon: Icons.person_outline_rounded,
          title: 'Edit Profil',
          onTap: _editProfile,
        ),
        _ProfileAction(
          icon: Icons.lock_outline_rounded,
          title: 'Ubah Password',
          onTap: _changePassword,
        ),
        _ProfileAction(
          icon: Icons.notifications_none_rounded,
          title: 'Notifikasi',
          trailing: Switch.adaptive(
            value: _notificationsEnabled,
            onChanged: (enabled) =>
                setState(() => _notificationsEnabled = enabled),
            activeTrackColor: lavender,
          ),
          onTap: () =>
              setState(() => _notificationsEnabled = !_notificationsEnabled),
        ),
        _ProfileAction(
          icon: Icons.help_outline_rounded,
          title: 'Bantuan',
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Bantuan Tempori'),
              content: const Text(
                'Tambahkan barang beserta tanggal kedaluwarsanya. Tempori akan menampilkan barang yang segera kedaluwarsa pada halaman Pengingat.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Mengerti'),
                ),
              ],
            ),
          ),
        ),
        _ProfileAction(
          icon: Icons.info_outline_rounded,
          title: 'Tentang Aplikasi',
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Tempori',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.eco_rounded, color: darkLavender),
            children: const [Text('Stay Ahead of Time.')],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _signOut,
          style: FilledButton.styleFrom(
            backgroundColor: lavender,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text('Logout'),
        ),
      ],
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSaving = false;
  bool _hidePasswords = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email;
    if (email == null || email.isEmpty) {
      _showMessage('Email akun tidak tersedia untuk verifikasi.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final auth = Supabase.instance.client.auth;
      await auth.signInWithPassword(
        email: email,
        password: _currentController.text,
      );
      await auth.updateUser(UserAttributes(password: _newController.text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah.')),
      );
      Navigator.of(context).pop();
    } on AuthException catch (error) {
      _showMessage('Gagal mengubah password: ${error.message}');
    } catch (error) {
      _showMessage('Gagal mengubah password: $error');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Ubah Password'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            _passwordField(
              label: 'Password Saat Ini',
              hint: 'Masukkan password saat ini',
              controller: _currentController,
              validator: (value) => value == null || value.isEmpty
                  ? 'Masukkan password saat ini.'
                  : null,
            ),
            const SizedBox(height: 20),
            _passwordField(
              label: 'Password Baru',
              hint: 'Minimal 6 karakter',
              controller: _newController,
              validator: (value) => value == null || value.length < 6
                  ? 'Password minimal 6 karakter.'
                  : null,
            ),
            const SizedBox(height: 20),
            _passwordField(
              label: 'Konfirmasi Password Baru',
              hint: 'Ulangi password baru',
              controller: _confirmController,
              validator: (value) => value != _newController.text
                  ? 'Konfirmasi password tidak sama.'
                  : null,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: lavender,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Simpan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: _hidePasswords,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline_rounded),
            suffixIcon: IconButton(
              tooltip: _hidePasswords
                  ? 'Tampilkan password'
                  : 'Sembunyikan password',
              onPressed: () => setState(() => _hidePasswords = !_hidePasswords),
              icon: Icon(
                _hidePasswords
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ItemTile extends StatelessWidget {
  const ItemTile({
    required this.item,
    required this.onTap,
    this.showExpiry = false,
    super.key,
  });

  final TemporiItem item;
  final VoidCallback onTap;
  final bool showExpiry;

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry;
    final statusColor = days < 0
        ? const Color(0xFFB63F56)
        : days <= 7
        ? const Color(0xFFB36A1E)
        : darkLavender;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0E3F1)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9A72D2).withValues(alpha: 0.055),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _ItemImage(imageUrl: item.imageUrl),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ink,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.category} • ${_displayDate(item.expiryDate)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: mutedInk, fontSize: 10),
                    ),
                    const SizedBox(height: 7),
                    _StatusPill(
                      text: days < 0
                          ? showExpiry
                                ? '${days.abs()} hari terlambat'
                                : 'Terlambat'
                          : days == 0
                          ? 'Hari ini'
                          : showExpiry
                          ? '$days hari lagi'
                          : days <= 7
                          ? 'Segera'
                          : 'Aman',
                      color: statusColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: mutedInk, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: lavenderSoft,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? const Icon(Icons.inventory_2_outlined, color: darkLavender)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.inventory_2_outlined, color: darkLavender),
            ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onChanged, required this.onSubmitted});

  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari barang di sini...',
        hintStyle: const TextStyle(color: mutedInk, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: mutedInk, size: 20),
        suffixIcon: IconButton(
          tooltip: 'Cari barang',
          onPressed: () => widget.onSubmitted(_controller.text.trim()),
          icon: const Icon(Icons.search_rounded, color: darkLavender, size: 20),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lavenderBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lavenderBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: lavender, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        isDense: true,
      ),
    );
  }
}


class _DashboardCategoryCard extends StatelessWidget {
  const _DashboardCategoryCard({
    required this.label,
    required this.imagePath,
    required this.count,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = switch (label) {
      'Cosmetics' => const [
          Color.fromARGB(255, 245, 178, 210),
          Color(0xFFFFF7F5),
        ],
      'Documents' => const [
          Color.fromARGB(255, 199, 182, 244),
          Color(0xFFFFFBFF),
        ],
      'Food & Beverages' => const [
          Color.fromARGB(255, 255, 223, 188),
          Color(0xFFFFFAF2),
        ],
      'Medicines' => const [
          Color.fromARGB(255, 187, 212, 255),
          Color(0xFFF9FBFF),
        ],
      _ => const [
          Color.fromARGB(255, 215, 185, 244),
          Color(0xFFFFF9FC),
        ],
    };

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 7,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: darkLavender.withValues(alpha: .07),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  color: ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count barang',
                style: const TextStyle(
                  fontSize: 9,
                  color: mutedInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _ReminderChip extends StatelessWidget {
  const _ReminderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: darkLavender,
        side: BorderSide(
          color: selected ? darkLavender : const Color(0xFFEAE4F4),
          width: selected ? 1.1 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        pressElevation: 0,
        labelStyle: TextStyle(
          color: selected ? Colors.white : ink,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 42,
                height: 38,
                decoration: BoxDecoration(
                  color: selected ? lavenderSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? darkLavender : mutedInk,
                  size: selected ? 21 : 20,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: selected ? darkLavender : mutedInk,
                  fontSize: 9,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            minimumSize: Size.zero,
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 11,
              color: darkLavender,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}


class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  Color get accent {
    if (tint == const Color(0xFFFFF0D9)) {
      return const Color(0xFFC47A35);
    } else if (tint == const Color(0xFFFBE1EA)) {
      return const Color(0xFFE36D87);
    }
    return const Color(0xFF8050B5);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          height: 112,
          padding: const EdgeInsets.symmetric(
            horizontal: 7,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint,
                tint.withValues(alpha: 0.82),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: accent,
                size: 23,
              ),

              Text(
                value,
                style: TextStyle(
                  fontSize: 21,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF382344),
                ),
              ),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF382344),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : ink,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        selectedColor: lavender,
        backgroundColor: Colors.white,
        side: BorderSide(color: selected ? lavender : const Color(0xFFEAE4F4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: lavenderSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 30,
                color: darkLavender,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: ink,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mutedInk,
                fontSize: 12,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: darkLavender,
                  side: const BorderSide(color: lavender),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Color(0xFF9D3D3D))),
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        color: ink,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: lavenderSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: darkLavender, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: mutedInk, fontSize: 12)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFECE7F4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: darkLavender.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0E9FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: darkLavender, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ink,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right_rounded, color: mutedInk, size: 22),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}