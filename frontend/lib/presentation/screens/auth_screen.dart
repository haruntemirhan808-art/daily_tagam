import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/network/api_client.dart';
import 'package:daily_tagam_frontend/presentation/screens/preferences_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(); 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthRepository _authRepository = AuthRepository(ApiClient());
  
  bool _isLogin = true; 
  String _selectedRole = 'customer'; 
  bool _isLoading = false;

  // Colors from prototype
  final Color _orange = const Color(0xFFFF8A00);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _textMain = const Color(0xFF1A1A2E);
  final Color _textSec = const Color(0xFF64748B);
  final Color _border = const Color(0xFFE2E8F0);

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    bool registrationSuccess = false;
    String? userRole; 

    if (_isLogin) {
      userRole = await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      registrationSuccess = await _authRepository.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (_isLogin) {
      if (userRole != null) {
        if (!mounted) return;
        if (userRole == 'customer') {
          Navigator.of(context).pushReplacementNamed('/feed');
        } else {
          Navigator.of(context).pushReplacementNamed('/biz-dash');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed. Check your inputs.')),
        );
      }
    } else {
      if (registrationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful! Setting up session...')),
        );
        
        if (!mounted) return;

        // Silently log the user in right now to capture their brand new JWT token!
        String? loggedInRole = await _authRepository.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (!mounted) return;

        if (loggedInRole != null && _selectedRole == 'customer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesScreen()),
          );
        } else {
          setState(() => _isLogin = true); 
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Email might be taken.')),
        );
      }
    }
  } // <-- FIXED: Added this missing closing brace for _submitForm

  Widget _buildRoleCard(String title, String subtitle, String icon, String roleValue) {
    bool isSelected = _selectedRole == roleValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = roleValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFF3E0) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _orange : _border,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain)),
              Text(subtitle, style: TextStyle(fontSize: 11, color: _textSec)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Brand Header
                    Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF9A1A), Color(0xFFFF6B00)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: _orange.withAlpha(90), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: const Icon(Icons.eco, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text('Daily ', style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w800, color: _textMain)),
                        Text('Tagam', style: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w800, color: _orange)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Titles
                    Text(
                      _isLogin ? 'Welcome Back 👋' : 'Join Us 👋',
                      style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w800, color: _textMain),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLogin ? 'Sign in to continue saving food' : 'Create an account to start saving',
                      style: TextStyle(fontSize: 14, color: _textSec),
                    ),
                    const SizedBox(height: 24),

                    // Custom Tab Switcher
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _isLogin ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: _isLogin ? [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 4)] : [],
                                ),
                                alignment: Alignment.center,
                                child: Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, color: _isLogin ? _textMain : _textSec)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLogin = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_isLogin ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: !_isLogin ? [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 4)] : [],
                                ),
                                alignment: Alignment.center,
                                child: Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w600, color: !_isLogin ? _textMain : _textSec)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Inputs
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline, color: _textSec),
                          filled: true, fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _orange)),
                        ),
                        validator: (val) => val != null && val.isNotEmpty ? null : 'Required',
                      ),
                      const SizedBox(height: 14),
                    ],
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined, color: _textSec),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _orange)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val != null && val.contains('@') ? null : 'Invalid email',
                    ),
                    const SizedBox(height: 14),
                    
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: _isLogin ? 'Password' : 'Create password',
                        prefixIcon: Icon(Icons.lock_outline, color: _textSec),
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _orange)),
                      ),
                      validator: (val) => val != null && val.length >= 6 ? null : '6+ chars required',
                    ),
                    
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Forgot password?', style: TextStyle(color: _orange, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      )
                    else
                      const SizedBox(height: 14),

                    // Role Selection
                    Text(
                      _isLogin ? 'I am signing in as:' : 'I am a:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRoleCard('Customer', 'Buy discounts', '🧑', 'customer'),
                        const SizedBox(width: 12),
                        _buildRoleCard('Business', 'Sell surplus', '🏪', 'business'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitForm,
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_isLogin ? 'Sign In' : 'Create Account'),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                      ),
                    ),

                    if (_isLogin) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: _border)),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or continue with', style: TextStyle(fontSize: 13, color: _textSec))),
                          Expanded(child: Divider(color: _border)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: _border, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {}, 
                          icon: const Icon(Icons.g_mobiledata, color: Colors.red, size: 32),
                          label: Text('Continue with Google', style: TextStyle(color: _textMain, fontWeight: FontWeight.w600)),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}