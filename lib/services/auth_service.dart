import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> signUp(String name, String email, String password) async {
    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception("Gagal membuat akun.");
    }
    await supabase.from('profiles').upsert({
      'id': user.id,
      'name': name,
      'role': 'officer',
    });
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final AuthResponse response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception("Email atau password salah.");
    }
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return {"user": user, "profile": profile};
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data;
  }
}
