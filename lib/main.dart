import 'package:aplikasi_lattelink/screens/splashscreen.dart';
import 'package:flutter/material.dart';

import 'services/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // WAJIB! kalau ini tidak dipanggil maka _instance tidak pernah dibuat
  await SupabaseConfig.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ganti sesuai halaman utama kamu
    );
  }
}
