import 'package:flutter/material.dart';

const lavender = Color(0xFF9B80D0);
const darkLavender = Color(0xFF7555A6);
const backgroundColor = Color(0xFFF9F6FF);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.inventory_2_rounded,
                size: 65,
                color: lavender,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                isLogin ? 'Selamat Datang!' : 'Buat Akun Tempori',
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: darkLavender,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                isLogin
                    ? 'Masuk dan pantau barangmu dengan mudah.'
                    : 'Daftar untuk mulai mengelola barangmu.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),

            if (!isLogin) ...[
              const Text('Nama Lengkap'),
              const SizedBox(height: 8),
              TextField(
                decoration: inputDecoration('Masukkan nama lengkap'),
              ),
              const SizedBox(height: 18),
            ],

            const Text('Email'),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: inputDecoration('Masukkan email'),
            ),
            const SizedBox(height: 18),

            const Text('Password'),
            const SizedBox(height: 8),
            TextField(
              obscureText: hidePassword,
              decoration: inputDecoration('Masukkan password').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isLogin
                            ? 'Login akan dihubungkan ke Supabase.'
                            : 'Pendaftaran akan dihubungkan ke Supabase.',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isLogin ? 'Masuk' : 'Daftar',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? 'Belum punya akun? Daftar'
                      : 'Sudah punya akun? Masuk',
                  style: const TextStyle(color: darkLavender),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}