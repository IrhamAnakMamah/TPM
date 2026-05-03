import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isObscure = true;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar('Semua field harus diisi', isError: true);
      return;
    }

    if (username.length < 3) {
      _showSnackBar('Username minimal 3 karakter', isError: true);
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password minimal 6 karakter', isError: true);
      return;
    }

    if (!email.contains('@')) {
      _showSnackBar('Email tidak valid', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _apiService.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      if (!mounted) return;
      _showSnackBar(result['message'] ?? 'Registrasi berhasil! Silakan login.');
      Navigator.pop(context); // Kembali ke Login
    } else {
      _showSnackBar(result['message'] ?? 'Registrasi gagal', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : Colors.teal.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity, height: double.infinity,
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.teal.shade400, Colors.teal.shade900])),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(30.0),
                child: Container(
                  padding: const EdgeInsets.all(25.0),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Daftar Akun Baru', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 5),
                      const Text('Lengkapi data diri Anda di bawah ini', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      const SizedBox(height: 30),
                      
                      _buildTextField(_fullNameController, Icons.person_outline, 'Nama Lengkap'),
                      const SizedBox(height: 15),
                      _buildTextField(_usernameController, Icons.account_circle_outlined, 'Username'),
                      const SizedBox(height: 15),
                      _buildTextField(_emailController, Icons.alternate_email, 'Email Address'),
                      const SizedBox(height: 15),
                      _buildTextField(_passwordController, Icons.lock_outline, 'Password', isPassword: true),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24, height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text('BUAT AKUN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Sudah punya akun? ", style: TextStyle(fontSize: 12)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Text("Masuk di sini", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, IconData icon, String hint, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword 
          ? IconButton(icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isObscure = !_isObscure))
          : null,
        filled: true, fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}