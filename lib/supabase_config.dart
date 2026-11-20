import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl =
      'https://qpmvrezgtvfizwrkbzrq.supabase.co';

  static const String supabasePublishableKey =
      'sb_publishable_T-_HW82KpckOfBisYljtaQ_Ou548nF2';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabasePublishableKey,
    );
  }
}