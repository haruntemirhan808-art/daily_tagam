import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/network/api_client.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final AuthRepository _authRepository = AuthRepository(ApiClient());
  
  bool _isLogin = true; // Toggles between Login and Signup modes
  String _selectedRole = 'customer'; // Default signup role ('customer' or 'business')
  bool _isLoading = false;

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    bool success = false;

    if (_isLogin) {
      success = await _authRepository.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await _authRepository.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _selectedRole,
      );
    }

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isLogin ? 'Login successful!' : 'Registration successful! Please login.')),
      );
      if (_isLogin) {
        // Navigate to your main screen or pop back
        Navigator.of(context).pushReplacementNamed('/feed');
      } else {
        setState(() => _isLogin = true); // Flip back to login view on fresh signup
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed. Check your inputs or server connection.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400), // Looks crisp on Desktop & Mobile
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin ? 'Welcome back!' : 'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                        validator: (val) => val != null && val.length >= 6 ? null : 'Password must be 6+ characters',
                      ),
                      if (!_isLogin) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: const InputDecoration(labelText: 'Register as', prefixIcon: Icon(Icons.person_pin)),
                          items: const [
                            DropdownMenuItem(value: 'customer', child: Text('Customer (Save food)')),
                            DropdownMenuItem(value: 'business', child: Text('Business (Sell food)')),
                          ],
                          onChanged: (val) => setState(() => _selectedRole = val!),
                        ),
                      ],
                      const SizedBox(height: 24),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _submitForm,
                              child: Text(_isLogin ? 'Login' : 'Sign Up'),
                            ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}