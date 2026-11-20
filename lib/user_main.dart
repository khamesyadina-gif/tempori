import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const TemporiUserApp());
}

const lavender = Color(0xFF9B80D0);
const darkLavender = Color(0xFF7555A6);
const backgroundColor = Color(0xFFFAF7FF);
const textColor = Color(0xFF29213D);
const mutedColor = Color(0xFF89839A);

class TemporiUserApp extends StatelessWidget {
  const TemporiUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tempori',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: lavender),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
      ),
      home: const UserSessionGate(),
    );
  }
}

class UserSessionGate extends StatelessWidget {
  const UserSessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.hasData
            ? snapshot.data!.session
            : auth.currentSession;
        return session != null ? const UserHomePage() : const WelcomePage();
      },
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned(
                  top: 120,
                  right: -85,
                  child: _WelcomeOrb(size: 220),
                ),
                const Positioned(
                  left: -100,
                  bottom: 155,
                  child: _WelcomeOrb(size: 230),
                ),
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              const SizedBox(height: 10),
                              const TemporiBrand(size: 104),
                              const SizedBox(height: 20),
                              const Text(
                                'Simpan, Pantau,\nJangan Sampai Terlambat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFF5F5574),
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const WelcomeIllustration(),
                            ],
                          ),
                          _WelcomeActions(
                            onLogin: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserLoginPage(),
                              ),
                            ),
                            onRegister: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserLoginPage(
                                  startInRegisterMode: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _WelcomeOrb extends StatelessWidget {
  const _WelcomeOrb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE9DFFF).withValues(alpha: 0.72),
              const Color(0xFFF7F1FF).withValues(alpha: 0.08),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeActions extends StatelessWidget {
  const _WelcomeActions({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
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
              onPressed: onLogin,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 14),
                  Icon(Icons.arrow_forward_rounded, size: 21),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRegister,
            style: TextButton.styleFrom(
              foregroundColor: mutedColor,
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
    );
  }
}

class TemporiBrand extends StatelessWidget {
  const TemporiBrand({super.key, this.size = 82});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 0.88,
          child: CustomPaint(painter: _TemporiLogoPainter()),
        ),
        const SizedBox(height: 2),
        Text(
          'Tempori',
          style: TextStyle(
            color: darkLavender,
            fontSize: size * 0.34,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
      ],
    );
  }
}

class _TemporiLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final logoPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB59ADC), Color(0xFF7652A5)],
      ).createShader(const Rect.fromLTWH(10, 5, 80, 90));

    final heart = Path()
      ..moveTo(63, 27)
      ..cubicTo(57, 21, 51, 15, 52, 9)
      ..cubicTo(53, 2, 62, 1, 67, 9)
      ..cubicTo(73, 2, 83, 4, 82, 12)
      ..cubicTo(81, 18, 72, 24, 63, 27)
      ..close();
    canvas.drawPath(heart, logoPaint);

    final clockRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(12, 25, 76, 67),
      const Radius.circular(25),
    );
    canvas.drawRRect(
      clockRect,
      Paint()
        ..color = const Color(0xFF9C82C1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    final center = const Offset(50, 58);
    final dialPaint = Paint()..color = const Color(0xFF9C82C1);
    for (final point in const [
      Offset(50, 37),
      Offset(71, 58),
      Offset(50, 79),
      Offset(29, 58),
    ]) {
      canvas.drawCircle(point, 2.2, dialPaint);
    }

    final handsPaint = Paint()
      ..color = const Color(0xFF8568AF)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, const Offset(39, 48), handsPaint);
    canvas.drawLine(center, const Offset(59, 67), handsPaint);
    canvas.drawCircle(center, 4, dialPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TemporiLogoPainter oldDelegate) => false;
}

class WelcomeIllustration extends StatelessWidget {
  const WelcomeIllustration({super.key, this.height = 265});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: const CustomPaint(painter: _WelcomeIllustrationPainter()),
    );
  }
}

class _WelcomeIllustrationPainter extends CustomPainter {
  const _WelcomeIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / 360, size.height / 265);
    canvas.save();
    canvas.translate(
      (size.width - 360 * scale) / 2,
      (size.height - 265 * scale) / 2,
    );
    canvas.scale(scale);

    canvas.drawOval(
      const Rect.fromLTWH(34, 226, 292, 22),
      Paint()..color = const Color(0xFFE8D5F1),
    );
    _drawSparkle(canvas, const Offset(45, 122), 10);
    _drawSparkle(canvas, const Offset(314, 160), 11);
    _drawSparkle(canvas, const Offset(76, 151), 5);

    canvas.save();
    canvas.translate(264, 103);
    canvas.rotate(0.13);
    canvas.translate(-264, -103);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(219, 59, 91, 94),
        const Radius.circular(13),
      ),
      Paint()..color = const Color(0xFFD8C2E8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(216, 53, 91, 97),
        const Radius.circular(13),
      ),
      Paint()..color = const Color(0xFFFFF8EE),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(216, 53, 91, 29),
        const Radius.circular(13),
      ),
      Paint()..color = const Color(0xFFC78BD0),
    );
    canvas.drawRect(
      const Rect.fromLTWH(216, 69, 91, 13),
      Paint()..color = const Color(0xFFC78BD0),
    );
    for (final x in const [238.0, 283.0]) {
      canvas.drawLine(
        Offset(x, 58),
        Offset(x, 48),
        Paint()
          ..color = const Color(0xFF8A559E)
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round,
      );
    }
    for (final point in const [
      Offset(234, 98),
      Offset(258, 98),
      Offset(283, 98),
      Offset(234, 122),
      Offset(283, 122),
    ]) {
      canvas.drawCircle(point, 4, Paint()..color = const Color(0xFFDABCE2));
    }
    canvas.drawCircle(
      const Offset(258, 122),
      9,
      Paint()..color = const Color(0xFFE7C7E9),
    );
    _drawBell(canvas, const Offset(261, 105));
    canvas.restore();

    final carton = Path()
      ..moveTo(101, 82)
      ..quadraticBezierTo(101, 77, 107, 76)
      ..lineTo(151, 70)
      ..quadraticBezierTo(156, 70, 157, 76)
      ..lineTo(161, 156)
      ..lineTo(99, 156)
      ..close();
    canvas.drawPath(carton, Paint()..color = const Color(0xFFFFF9F1));
    canvas.drawPath(
      Path()
        ..moveTo(101, 82)
        ..lineTo(157, 76)
        ..lineTo(158, 91)
        ..lineTo(101, 97)
        ..close(),
      Paint()..color = const Color(0xFFD7B5E4),
    );
    canvas.drawLine(
      const Offset(110, 102),
      const Offset(149, 98),
      Paint()
        ..color = const Color(0xFFEAD9EE)
        ..strokeWidth = 2,
    );
    for (final point in const [
      Offset(130, 121),
      Offset(123, 128),
      Offset(137, 128),
      Offset(126, 136),
      Offset(134, 136),
    ]) {
      canvas.drawCircle(point, 5, Paint()..color = const Color(0xFFC58BCF));
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(61, 121, 47, 43),
        const Radius.circular(14),
      ),
      Paint()..color = const Color(0xFFFFF7F1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(68, 109, 32, 18),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFE9B887),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(65, 123, 39, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF9B68AA),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(75, 135, 19, 3),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFFE8D1EB),
    );

    final tube = Path()
      ..moveTo(166, 103)
      ..quadraticBezierTo(166, 98, 171, 97)
      ..lineTo(198, 101)
      ..quadraticBezierTo(203, 102, 202, 108)
      ..lineTo(196, 159)
      ..lineTo(164, 159)
      ..close();
    canvas.drawPath(tube, Paint()..color = const Color(0xFFE9D5EF));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(166, 99, 37, 10),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFB77DC4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(173, 151, 17, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF9565A5),
    );
    canvas.drawCircle(
      const Offset(183, 127),
      8,
      Paint()..color = const Color(0xFFFFF8F1),
    );

    final fruit = Path()
      ..moveTo(211, 157)
      ..cubicTo(195, 147, 199, 128, 211, 129)
      ..cubicTo(215, 121, 227, 124, 230, 132)
      ..cubicTo(244, 137, 239, 154, 224, 159)
      ..close();
    canvas.drawPath(fruit, Paint()..color = const Color(0xFFE8B887));
    canvas.drawOval(
      const Rect.fromLTWH(213, 122, 12, 7),
      Paint()..color = const Color(0xFF91A777),
    );

    canvas.save();
    canvas.translate(229, 145);
    canvas.rotate(-0.2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-30, -20, 59, 44),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFFFFF9F1),
    );
    for (final point in const [
      Offset(-16, -8),
      Offset(1, -8),
      Offset(18, -8),
      Offset(-16, 9),
      Offset(1, 9),
      Offset(18, 9),
    ]) {
      canvas.drawCircle(point, 5.5, Paint()..color = const Color(0xFFD8A8D9));
    }
    canvas.restore();

    canvas.drawOval(
      const Rect.fromLTWH(51, 218, 258, 20),
      Paint()..color = const Color(0xFFD9B9E6),
    );
    final basket = Path()
      ..moveTo(70, 158)
      ..lineTo(283, 158)
      ..lineTo(263, 219)
      ..quadraticBezierTo(178, 242, 91, 219)
      ..close();
    canvas.drawPath(
      basket,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFB782C4), Color(0xFF9460A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(70, 158, 213, 84)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(65, 149, 222, 20),
        const Radius.circular(9),
      ),
      Paint()..color = const Color(0xFF86569B),
    );
    _drawHeart(canvas, const Offset(148, 198), 13, const Color(0xFFFFF8F1));

    canvas.drawCircle(
      const Offset(286, 204),
      36,
      Paint()..color = const Color(0xFFAD75B9),
    );
    canvas.drawCircle(
      const Offset(286, 204),
      30,
      Paint()..color = const Color(0xFFFFF8EF),
    );
    canvas.drawCircle(
      const Offset(286, 204),
      25,
      Paint()
        ..color = const Color(0xFFE6CBEA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final checkPaint = Paint()
      ..color = const Color(0xFF9A64AA)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(274, 204)
        ..lineTo(282, 212)
        ..lineTo(298, 195),
      checkPaint,
    );
    canvas.restore();
  }

  void _drawBell(Canvas canvas, Offset center) {
    final bell = Path()
      ..moveTo(center.dx - 11, center.dy + 8)
      ..quadraticBezierTo(
        center.dx - 7,
        center.dy + 1,
        center.dx - 7,
        center.dy - 5,
      )
      ..quadraticBezierTo(
        center.dx - 6,
        center.dy - 15,
        center.dx,
        center.dy - 15,
      )
      ..quadraticBezierTo(
        center.dx + 8,
        center.dy - 14,
        center.dx + 8,
        center.dy - 5,
      )
      ..quadraticBezierTo(
        center.dx + 8,
        center.dy + 1,
        center.dx + 12,
        center.dy + 8,
      )
      ..quadraticBezierTo(
        center.dx + 12,
        center.dy + 11,
        center.dx + 8,
        center.dy + 11,
      )
      ..lineTo(center.dx - 8, center.dy + 11)
      ..quadraticBezierTo(
        center.dx - 12,
        center.dy + 11,
        center.dx - 11,
        center.dy + 8,
      )
      ..close();
    canvas.drawPath(bell, Paint()..color = const Color(0xFF9C64AA));
    canvas.drawCircle(
      Offset(center.dx, center.dy + 12),
      3,
      Paint()..color = const Color(0xFF9C64AA),
    );
    final ringPaint = Paint()
      ..color = const Color(0xFFC184C7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx - 13, center.dy - 2),
      Offset(center.dx - 17, center.dy - 4),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 14, center.dy - 2),
      Offset(center.dx + 18, center.dy - 5),
      ringPaint,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius) {
    final sparkle = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(
        center.dx + radius * 0.25,
        center.dy - radius * 0.25,
        center.dx + radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + radius * 0.25,
        center.dy + radius * 0.25,
        center.dx,
        center.dy + radius,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.25,
        center.dy + radius * 0.25,
        center.dx - radius,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - radius * 0.25,
        center.dy - radius * 0.25,
        center.dx,
        center.dy - radius,
      )
      ..close();
    canvas.drawPath(sparkle, Paint()..color = const Color(0xFFD5AFE1));
  }

  void _drawHeart(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + radius)
      ..cubicTo(
        center.dx - radius * 2,
        center.dy - radius * 0.2,
        center.dx - radius,
        center.dy - radius * 1.7,
        center.dx,
        center.dy - radius * 0.7,
      )
      ..cubicTo(
        center.dx + radius,
        center.dy - radius * 1.7,
        center.dx + radius * 2,
        center.dy - radius * 0.2,
        center.dx,
        center.dy + radius,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WelcomeIllustrationPainter oldDelegate) =>
      false;
}

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key, this.startInRegisterMode = false});

  final bool startInRegisterMode;

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  late bool isLogin;
  bool hidePassword = true;
  bool isLoading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLogin = !widget.startInRegisterMode;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration decoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9A92A8), fontSize: 14),
      prefixIcon: Icon(icon, color: textColor, size: 20),
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

  Future<void> handleAuth() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty || (!isLogin && name.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua kolom terlebih dahulu.')),
      );
      return;
    }

    if (!isLogin && password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        final response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name},
        );
        if (response.session != null) {
          await Supabase.instance.client.auth.signOut();
        }

        if (!mounted) return;
        setState(() => isLogin = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.session == null
                  ? 'Registrasi berhasil. Konfirmasi email melalui tautan '
                        'yang kami kirim sebelum masuk.'
                  : 'Registrasi berhasil. Silakan masuk dengan akun yang '
                        'baru dibuat.',
            ),
          ),
        );
        return;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserHomePage()),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      final message = error.message.toLowerCase();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message.contains('email not confirmed') ||
                    message.contains('email_not_confirmed')
                ? 'Email belum dikonfirmasi. Periksa kotak masuk dan '
                      'konfirmasi email terlebih dahulu sebelum masuk.'
                : error.message,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Periksa koneksi internet.'),
        ),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                const Positioned(
                  top: -105,
                  right: -110,
                  child: _WelcomeOrb(size: 260),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            tooltip: 'Kembali',
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 19,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Center(child: TemporiBrand(size: 74)),
                          const SizedBox(height: 30),
                          Text(
                            isLogin
                                ? 'Selamat datang\nkembali!'
                                : 'Yuk, buat akunmu!',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 25,
                              height: 1.18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLogin
                                ? 'Masuk untuk melanjutkan mengelola barang kamu.'
                                : 'Daftar dan mulai pantau barang kesayanganmu.',
                            style: const TextStyle(
                              color: mutedColor,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 26),
                          if (!isLogin) ...[
                            _fieldLabel('Nama Lengkap'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              decoration: decoration(
                                'Nama lengkap',
                                Icons.person_outline_rounded,
                              ),
                            ),
                            const SizedBox(height: 17),
                          ],
                          _fieldLabel('Email'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: decoration(
                              'Email',
                              Icons.mail_outline_rounded,
                            ),
                          ),
                          const SizedBox(height: 17),
                          _fieldLabel('Password'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: passwordController,
                            obscureText: hidePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: [
                              isLogin
                                  ? AutofillHints.password
                                  : AutofillHints.newPassword,
                            ],
                            onSubmitted: (_) {
                              if (!isLoading) handleAuth();
                            },
                            decoration:
                                decoration(
                                  'Password',
                                  Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    tooltip: hidePassword
                                        ? 'Tampilkan password'
                                        : 'Sembunyikan password',
                                    onPressed: () {
                                      setState(
                                        () => hidePassword = !hidePassword,
                                      );
                                    },
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: textColor,
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
                              onPressed: isLoading ? null : handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: lavender,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: lavender.withValues(
                                  alpha: 0.6,
                                ),
                                elevation: 2,
                                shadowColor: lavender.withValues(alpha: 0.24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.4,
                                      ),
                                    )
                                  : Text(
                                      isLogin ? 'Masuk' : 'Daftar',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() => isLogin = !isLogin);
                              },
                              child: Text.rich(
                                TextSpan(
                                  text: isLogin
                                      ? 'Belum punya akun? '
                                      : 'Sudah punya akun? ',
                                  children: [
                                    TextSpan(
                                      text: isLogin
                                          ? 'Daftar sekarang'
                                          : 'Masuk',
                                      style: const TextStyle(
                                        color: darkLavender,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                style: const TextStyle(
                                  color: mutedColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const UserLoginPage()),
        (route) => false,
      );
    } on AuthException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal keluar: ${error.message}')));
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal keluar: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Tempori',
          style: TextStyle(color: darkLavender, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout_rounded, color: darkLavender),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${user?.userMetadata?['full_name'] ?? 'Teman Tempori'}! 👋',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Yuk, pantau barang dan tanggal kedaluwarsanya.',
              style: TextStyle(color: mutedColor, fontSize: 13),
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7652C8), Color(0xFFA78AE5)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Barangmu, lebih teratur.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Simpan tanggal penting agar tidak terlewat.',
                    style: TextStyle(color: Color(0xFFF0E9FF), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Ringkasan Barang',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'Total Barang',
                    '0',
                    Icons.inventory_2_rounded,
                    const Color(0xFFECE4FA),
                    darkLavender,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: _summaryCard(
                    'Segera Habis',
                    '0',
                    Icons.notifications_active_rounded,
                    const Color(0xFFFFE7EE),
                    const Color(0xFFD65380),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFECE5F6)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 45, color: lavender),
                  SizedBox(height: 12),
                  Text(
                    'Belum ada barang',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Barang yang kamu simpan akan muncul di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color background,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE5F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: foreground, size: 21),
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: TextStyle(
              color: foreground,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: mutedColor, fontSize: 11)),
        ],
      ),
    );
  }
}
