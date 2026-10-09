import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url {
    final value = dotenv.env['SUPABASE_URL'];

    if (value == null || value.isEmpty) {
      throw Exception(
        'SUPABASE_URL is missing from .env',
      );
    }

    return value;
  }

  static String get anonKey {
    final value = dotenv.env['SUPABASE_ANON_KEY'];

    if (value == null || value.isEmpty) {
      throw Exception(
        'SUPABASE_ANON_KEY is missing from .env',
      );
    }

    return value;
  }
}