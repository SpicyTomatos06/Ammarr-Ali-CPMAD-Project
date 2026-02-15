import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        Fluttertoast.showToast(msg: 'Logged in');
      } else {
        if (password != _confirmPasswordController.text) {
          Fluttertoast.showToast(msg: 'Passwords do not match');
          return;
        }
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        Fluttertoast.showToast(msg: 'Account created');
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: _friendlyAuthError(e));
    } catch (_) {
      Fluttertoast.showToast(msg: 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (use at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.recycling, size: 64, color: Colors.green),
                        const SizedBox(height: 12),
                        Text(
                          _isLogin ? 'Welcome back' : 'Create an account',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin
                              ? 'Log in to continue using SmartRecycle SG.'
                              : 'Sign up to start using SmartRecycle SG.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            final v = (value ?? '').trim();
                            if (v.isEmpty) return 'Email is required.';
                            if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            ),
                          ),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'Password is required.';
                            if (v.length < 6) return 'Password must be at least 6 characters.';
                            return null;
                          },
                        ),

                        if (!_isLogin) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _hidePassword,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock_outline),
                            ),
                            validator: (value) {
                              final v = value ?? '';
                              if (v.isEmpty) return 'Please confirm your password.';
                              if (v != _passwordController.text) return 'Passwords do not match.';
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(_isLogin ? 'Login' : 'Register'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _confirmPasswordController.clear();
                                  });
                                },
                          child: Text(
                            _isLogin ? "Don't have an account? Register" : 'Already have an account? Login',
                          ),
                        ),
                      ],
                    ),
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
