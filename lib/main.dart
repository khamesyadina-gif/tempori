import 'package:flutter/material.dart';

import 'supabase_config.dart';
import 'user_app.dart';
import 'notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();
  await NotificationService.initialize();

  runApp(const TemporiApp());

  }

class TemporiApp extends StatelessWidget {
  const TemporiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tempori',
      theme: temporiTheme,
      home: const AuthGate(),
    );
  }
}
