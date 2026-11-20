import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const lavender = Color(0xFF9B80D0);
const darkLavender = Color(0xFF7555A6);
const backgroundColor = Color(0xFFF7F5FC);
const textColor = Color(0xFF29213D);
const mutedColor = Color(0xFF89839A);
const primaryPurple = Color(0xFF7652C8);

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final supabase = Supabase.instance.client;

  int selectedMenu = 0;
  int totalCategories = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> categories = [];

  final menus = [
    (Icons.grid_view_rounded, 'Dashboard'),
    (Icons.category_rounded, 'Kelola Kategori'),
    (Icons.settings_rounded, 'Pengaturan'),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    if (mounted) setState(() => isLoading = true);

    try {
      final response = await supabase
          .from('categories')
          .select('category_id, category_name')
          .order('category_name');

      if (!mounted) return;

      setState(() {
        categories = List<Map<String, dynamic>>.from(response);
        totalCategories = categories.length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Gagal memuat kategori: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? const Color(0xFFD65380) : darkLavender,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _showCategoryDialog({
    Map<String, dynamic>? category,
  }) async {
    final controller = TextEditingController(
      text: category?['category_name']?.toString() ?? '',
    );
    final isEdit = category != null;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isEdit ? 'Edit Kategori' : 'Tambah Kategori',
          style: const TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: 380,
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Contoh: Makanan',
              prefixIcon: const Icon(
                Icons.category_outlined,
                color: primaryPurple,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: primaryPurple,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: mutedColor),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (name == null) return;

    if (name.isEmpty) {
      _showMessage('Nama kategori tidak boleh kosong.', isError: true);
      return;
    }

    final duplicate = categories.any((item) {
      final sameName = item['category_name']
          .toString()
          .trim()
          .toLowerCase() == name.toLowerCase();
      final sameRecord =
          isEdit && item['category_id'] == category['category_id'];
      return sameName && !sameRecord;
    });

    if (duplicate) {
      _showMessage('Nama kategori sudah tersedia.', isError: true);
      return;
    }

    try {
      if (isEdit) {
        await supabase
            .from('categories')
            .update({'category_name': name})
            .eq('category_id', category['category_id']);
      } else {
        await supabase.from('categories').insert({
          'category_name': name,
        });
      }

      if (!mounted) return;
      _showMessage(
        isEdit
            ? 'Kategori berhasil diperbarui.'
            : 'Kategori berhasil ditambahkan.',
      );
      await _loadCategories();
    } catch (e) {
      _showMessage('Gagal menyimpan kategori: $e', isError: true);
    }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final name = category['category_name']?.toString() ?? 'kategori ini';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Hapus Kategori?',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus kategori "$name"? '
          'Jika kategori masih digunakan oleh barang pengguna, '
          'database mungkin menolak penghapusan.',
          style: const TextStyle(
            color: mutedColor,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: mutedColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD65380),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await supabase
          .from('categories')
          .delete()
          .eq('category_id', category['category_id']);

      if (!mounted) return;
      _showMessage('Kategori berhasil dihapus.');
      await _loadCategories();
    } catch (e) {
      _showMessage(
        'Kategori gagal dihapus. Mungkin masih digunakan oleh barang '
        'pengguna. Detail: $e',
        isError: true,
      );
    }
  }

  Future<void> _logout() async {
    try {
      await supabase.auth.signOut();

      if (!mounted) return;

      _showMessage('Berhasil keluar dari akun.');
      // Sesuaikan navigasi kembali ke AdminLoginPage dengan
      // alur routing yang digunakan pada admin_login_page.dart.
    } catch (e) {
      _showMessage('Gagal keluar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return Row(
            children: [
              if (!isMobile) _sidebar(),
              Expanded(
                child: Column(
                  children: [
                    _header(isMobile),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(isMobile ? 18 : 30),
                        child: _pageContent(isMobile),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _pageContent(bool isMobile) {
    switch (selectedMenu) {
      case 1:
        return _categoryPage(isMobile);
      case 2:
        return _settingsPage(isMobile);
      default:
        return _dashboardPage(isMobile);
    }
  }

  Widget _dashboardPage(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          isMobile,
          title: 'Halo, Admin! 👋',
          subtitle: 'Pantau pengelolaan kategori aplikasi Tempori.',
        ),
        const SizedBox(height: 26),
        _categoryStatistic(isMobile),
        const SizedBox(height: 26),
        _panel(
          title: 'Selamat Datang di Tempori Admin',
          subtitle: 'Pengelolaan kategori aplikasi Tempori',
          icon: Icons.auto_awesome_rounded,
          child: const Text(
            'Melalui halaman admin, kamu dapat mengelola kategori '
            'yang tersedia di aplikasi Tempori. Kategori ini nantinya '
            'dapat digunakan pengguna saat menambahkan barang.',
            style: TextStyle(
              color: mutedColor,
              fontSize: 12,
              height: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _footer(),
      ],
    );
  }

  Widget _categoryPage(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          isMobile,
          title: 'Kelola Kategori',
          subtitle: 'Atur kategori yang tersedia di aplikasi Tempori.',
        ),
        const SizedBox(height: 26),
        _panel(
          title: 'Daftar Kategori',
          subtitle: 'Kategori barang untuk pengguna Tempori',
          icon: Icons.category_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${categories.length} kategori terdaftar',
                    style: const TextStyle(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _loadCategories,
                        icon: const Icon(Icons.refresh_rounded, size: 17),
                        label: const Text('Refresh'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryPurple,
                          side: const BorderSide(
                            color: Color(0xFFDCD0F2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Tambah'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(
                      color: primaryPurple,
                    ),
                  ),
                )
              else if (categories.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: lavender,
                        size: 38,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada kategori',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Klik Tambah untuk membuat kategori pertama.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _categoryTable(),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _footer(),
      ],
    );
  }

  Widget _categoryTable() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFEDE7F5)),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F1FC),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 38,
                  child: Text(
                    'No.',
                    style: TextStyle(
                      color: darkLavender,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Nama Kategori',
                    style: TextStyle(
                      color: darkLavender,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Text(
                  'Aksi',
                  style: TextStyle(
                    color: darkLavender,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          ...List.generate(categories.length, (index) {
            final category = categories[index];

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFEDE7F5).withValues(alpha: 0.8),
                  ),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      category['category_name']?.toString() ?? '-',
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Edit kategori',
                    visualDensity: VisualDensity.compact,
                    onPressed: () =>
                        _showCategoryDialog(category: category),
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: primaryPurple,
                      size: 19,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hapus kategori',
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _deleteCategory(category),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFD65380),
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _settingsPage(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(
          isMobile,
          title: 'Pengaturan',
          subtitle: 'Pengaturan akun administrator Tempori.',
        ),
        const SizedBox(height: 26),
        _panel(
          title: 'Akun Administrator',
          subtitle: 'Informasi sesi administrator',
          icon: Icons.admin_panel_settings_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kamu sedang masuk sebagai administrator.',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFE8EF),
                  foregroundColor: const Color(0xFFD65380),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _footer(),
      ],
    );
  }

  Widget _sidebar() {
    return Container(
      width: 250,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF332052),
            Color(0xFF49316F),
            Color(0xFF65469B),
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Image.asset(
                  'assets/images/tempori_admin.png',
                  height: 75,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 75,
                      child: Center(
                        child: Text(
                          'Tempori Admin',
                          style: TextStyle(
                            color: primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 35),
              const Padding(
                padding: EdgeInsets.only(left: 12, bottom: 14),
                child: Text(
                  'MENU UTAMA',
                  style: TextStyle(
                    color: Color(0xFFBBAAD9),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ...List.generate(menus.length, (index) {
                final menu = menus[index];
                final active = selectedMenu == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () {
                      setState(() => selectedMenu = index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            menu.$1,
                            size: 20,
                            color: active
                                ? primaryPurple
                                : const Color(0xFFD7C9EC),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Text(
                              menu.$2,
                              style: TextStyle(
                                color: active
                                    ? primaryPurple
                                    : Colors.white,
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (active)
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: primaryPurple,
                              size: 19,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFE4CFFF),
                      size: 24,
                    ),
                    SizedBox(height: 13),
                    Text(
                      'Kelola lebih mudah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Atur kategori barang untuk membantu pengguna Tempori.',
                      style: TextStyle(
                        color: Color(0xFFD8CCE9),
                        fontSize: 11,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 18 : 30,
        vertical: 17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF382456).withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/tempori_admin.png',
                width: 38,
                height: 38,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.category_rounded,
                  color: primaryPurple,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              menus[selectedMenu].$2,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB69AEF),
                  Color(0xFF7652C8),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 12),
            const Text(
              'Administrator',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pageTitle(
    bool isMobile, {
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7652C8),
            Color(0xFF9876DF),
            Color(0xFFB7A0ED),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primaryPurple.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -22,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: isMobile ? 100 : 135,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'ADMIN PANEL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFF0E9FF),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _categoryStatistic(bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEDE7F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF49316F).withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Kategori',
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E9FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.category_rounded,
                  color: primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isLoading ? '...' : '$totalCategories',
            style: const TextStyle(
              color: primaryPurple,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Kategori yang tersedia',
            style: TextStyle(
              color: mutedColor,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFEDE7F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF49316F).withValues(alpha: 0.035),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E9FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: primaryPurple),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: mutedColor,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }

  Widget _footer() {
    return const Center(
      child: Text(
        'Tempori Admin • Kelola dengan lebih mudah',
        style: TextStyle(
          color: mutedColor,
          fontSize: 11,
        ),
      ),
    );
  }
}
