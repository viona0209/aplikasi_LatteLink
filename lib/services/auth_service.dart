import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // -----------------------------
  // REGISTER USER BARU
  // -----------------------------
  Future<void> signUp(String name, String email, String password) async {
    // 1. Buat akun di Supabase Auth
    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception("Gagal membuat akun.");
    }

    // 2. Simpan data user ke tabel profiles
    await supabase.from('profiles').upsert({
      'id': user.id,       // sama dengan auth.users.id
      'name': name,
      'role': 'officer',   // default role
    });
  }

  // -----------------------------
  // LOGIN USER
  // -----------------------------
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final AuthResponse response =
        await supabase.auth.signInWithPassword(email: email, password: password);

    final user = response.user;

    if (user == null) {
      throw Exception("Email atau password salah.");
    }

    // Ambil profil user dari tabel profiles
    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return {
      "user": user,
      "profile": profile,
    };
  }

  // -----------------------------
  // LOGOUT USER
  // -----------------------------
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // -----------------------------
  // GET USER YANG SEDANG LOGIN
  // -----------------------------
  User? get currentUser => supabase.auth.currentUser;

  // -----------------------------
  // GET PROFILE USER LOGGED-IN
  // -----------------------------
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
