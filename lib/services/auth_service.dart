import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  //untuk register user baru
  Future<void> signUp(String name, String email, String password) async {
    final existingUser = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (existingUser != null) {
      throw Exception('Email sudah terdaftar.');
    }
    await supabase.from('users').insert({
      'name': name,
      'email': email,
      'password': password,
      'role': 'officer',
    });
  }

  //untuk login user
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .maybeSingle();

    if (response == null) {
      throw Exception('Email atau password salah.');
    }

    return response;
  }

  //untuk logout user
  Future<void> signOut() async {
    print('User signed out');
  }
}
