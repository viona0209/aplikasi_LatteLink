import 'package:aplikasi_lattelink/screens/dashboard/dashboard.dart';
import 'package:aplikasi_lattelink/screens/user/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
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
    final password = passwordController.text;
    setState(() {
      if (password.isEmpty) {
        passwordError = "Password wajib diisi";
      } else if (password.length < 6) {
        passwordError = "Password minimal 6 karakter";
      } else {
        passwordError = null;
      }
    });
  }

  bool get _isFormValid =>
      emailError == null &&
      passwordError == null &&
      emailController.text.isNotEmpty &&
      passwordController.text.isNotEmpty;

  Future<void> loginUser() async {
    _validateEmail();
    _validatePassword();
    if (!_isFormValid) return;
    setState(() => _isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    try {
      final res = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        _showMessage("Login gagal. Periksa email dan password.");
        return;
      }
      if (user.emailConfirmedAt == null) {
        _showMessage("Email belum dikonfirmasi. Cek inbox/spam.");
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } on AuthException catch (e) {
      _showMessage(e.message);
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
        backgroundColor: Colors.red.shade600,
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

              SizedBox(height: height * 0.06),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Log in with Email",
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
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
                controller: passwordController,
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
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
              SizedBox(height: height * 0.04),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : loginUser,
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
                          "Sign In",
                          style: TextStyle(
                            fontSize: 22 * fontScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: height * 0.08),
              Text.rich(
                TextSpan(
                  text: "by Logging in, you agree to the ",
                  style: TextStyle(fontSize: 13 * fontScale),
                  children: const [
                    TextSpan(
                      text: "Privacy Policy & Terms of Service",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: height * 0.03),
              Text.rich(
                TextSpan(
                  text: "Don’t have an account? ",
                  style: TextStyle(fontSize: 15 * fontScale),
                  children: [
                    TextSpan(
                      text: "Sign up now",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B3A22),
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
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
    passwordController.dispose();
    super.dispose();
  }
}
