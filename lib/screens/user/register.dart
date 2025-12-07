import 'package:aplikasi_lattelink/screens/user/Login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  String _selectedRole = 'admin';
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  String? emailError;
  String? passwordError;
  String? confirmError;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
    passController.addListener(_validatePassword);
    confirmController.addListener(_validateConfirmPassword);
  }

  void _validateEmail() {
    final email = emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        emailError = "Email wajib diisi";
      } else if (!email.endsWith('@gmail.com')) {
        emailError = "Hanya menerima email @gmail.com";
      } else {
        emailError = null;
      }
    });
  }

  void _validatePassword() {
    final pass = passController.text;
    setState(() {
      if (pass.isEmpty) {
        passwordError = "Password wajib diisi";
      } else if (pass.length < 6) {
        passwordError = "Password minimal 6 karakter";
      } else {
        passwordError = null;
      }
      _validateConfirmPassword();
    });
  }

  void _validateConfirmPassword() {
    final confirm = confirmController.text;
    final pass = passController.text;
    setState(() {
      if (confirm.isEmpty) {
        confirmError = "Konfirmasi password wajib diisi";
      } else if (confirm != pass) {
        confirmError = "Password tidak cocok";
      } else {
        confirmError = null;
      }
    });
  }

  bool get _isFormValid =>
      emailError == null &&
      passwordError == null &&
      confirmError == null &&
      emailController.text.isNotEmpty &&
      passController.text.isNotEmpty &&
      confirmController.text.isNotEmpty;

  Future<void> registerUser() async {
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();

    if (!_isFormValid) return;

    setState(() => _isLoading = true);

    final email = emailController.text.trim();
    final pass = passController.text.trim();

    try {
      final supabase = Supabase.instance.client;

      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: pass,
      );

      if (res.user == null) {
        _showMessage(
          "Akun berhasil dibuat! Silakan cek email untuk verifikasi.",
        );
        return;
      }

      final String userId = res.user!.id;
      final String name = email.split('@')[0];

      await supabase.from("profiles").insert({
        "user_id": userId,
        "name": name,
        "role": _selectedRole,
      });

      _showMessage("Registrasi berhasil! Silakan login.");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } on AuthException catch (e) {
      _showMessage("Gagal mendaftar: ${e.message}");
    } catch (e) {
      _showMessage("Terjadi kesalahan: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: msg.contains("berhasil")
            ? Colors.green.shade600
            : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final height = media.size.height;

    final double fontScale = width / 390;
    final double base = width < 400 ? 0.85 : 1.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24 * base),
          child: Column(
            children: [
              SizedBox(height: height * 0.10),

              Image.asset(
                'assets/image/logoAplikasi2.png',
                width: width * 0.6,
                height: height * 0.22,
                fit: BoxFit.contain,
              ),

              SizedBox(height: height * 0.05),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Sign Up",
                  style: TextStyle(
                    color: const Color(0xFF8B3A22),
                    fontSize: 18 * fontScale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: "email@gmail.com",
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF8B3A22),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * base,
                    vertical: 18 * base,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: emailError != null
                          ? Colors.red
                          : Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6E200D),
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (emailError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        emailError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: height * 0.02),
              TextField(
                controller: passController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "password",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF8B3A22),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * base,
                    vertical: 18 * base,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: passwordError != null
                          ? Colors.red
                          : Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6E200D),
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        passwordError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: height * 0.02),
              TextField(
                controller: confirmController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: "confirm password",
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF8B3A22),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16 * base,
                    vertical: 18 * base,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: confirmError != null
                          ? Colors.red
                          : Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6E200D),
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (confirmError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        confirmError!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: height * 0.02),
              Row(
                children: [
                  Checkbox(
                    activeColor: const Color(0xFF8B3A22),
                    value: !_obscurePassword,
                    onChanged: (value) =>
                        setState(() => _obscurePassword = !(value ?? false)),
                  ),
                  Text(
                    "show password",
                    style: TextStyle(
                      fontSize: 15 * fontScale,
                      color: const Color(0xFFB05B3B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Radio<String>(
                        value: 'admin',
                        groupValue: _selectedRole,
                        activeColor: const Color(0xFF8B3A22),
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                      Text("Admin", style: TextStyle(fontSize: 16 * fontScale)),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'officer',
                        groupValue: _selectedRole,
                        activeColor: const Color(0xFF8B3A22),
                        onChanged: (v) => setState(() => _selectedRole = v!),
                      ),
                      Text(
                        "Officer",
                        style: TextStyle(fontSize: 16 * fontScale),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: height * 0.05),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_isFormValid ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6E200D),
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: EdgeInsets.symmetric(vertical: 20 * base),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 22 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: height * 0.07),

              Text.rich(
                TextSpan(
                  text: "Already have an account? ",
                  style: TextStyle(
                    color: Color(0xFFB05B3B),
                    fontSize: 14 * fontScale,
                  ),
                  children: [
                    TextSpan(
                      text: "Log In",
                      style: const TextStyle(
                        color: Color(0xFF8B3A22),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        fontSize: 15,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    confirmController.dispose();
    super.dispose();
  }
}
