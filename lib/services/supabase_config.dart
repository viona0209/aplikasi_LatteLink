//Digunakana untuk membuat jembatan antara aplikasi Flutter dan Supabase

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://evludrmbkijrkahhnxjs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV2bHVkcm1ia2lqcmthaGhueGpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA5OTc2MTMsImV4cCI6MjA3NjU3MzYxM30.5Et0k2JDZCpDDfnMnydz8EK6xTSuMzXznM02XxpCJnA';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

