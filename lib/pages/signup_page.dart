import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = true;
  bool _showConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.register(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Auth stream in main.dart navigates to MainShell automatically.
      // Only show snackbar if widget is still mounted (i.e. navigation
      // hasn't happened yet).
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Welcome to Indris.'),
            backgroundColor: AppColors.green,
          ),
        );
        // Explicitly navigate to home
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(_friendlyFirebaseError(e.code));
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      // Always reset loading so the button is never stuck
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  String _friendlyFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'No internet connection. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled. Contact support.';
      default:
        return 'Registration failed ($code). Please try again.';
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your email';
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Text('Indris', style: logoStyle(size: 22)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Join Indris', style: headingStyle(size: 30)),
                    const SizedBox(height: 12),
                    Text(
                      'Create your account to access exclusive content, '
                      'manage your projects, and stay updated with our '
                      'latest designs and collections.',
                      style: bodyStyle(size: 13.5),
                    ),
                    const SizedBox(height: 20),

                    // ── Benefits ─────────────────────────────────
                    Text('BENEFITS OF JOINING',
                        style: navStyle(size: 12, color: AppColors.green)),
                    const SizedBox(height: 12),
                    _benefit('Access to exclusive design resources'),
                    _benefit('Personalized project management'),
                    _benefit('Early access to new collections'),
                    _benefit('Special discounts and offers'),
                    _benefit('Dedicated customer support'),
                    const SizedBox(height: 24),

                    Text('CREATE ACCOUNT',
                        style: navStyle(size: 12, color: AppColors.green)),
                    const SizedBox(height: 20),

                    // ── Full Name ─────────────────────────────────
                    Text('Full Name',
                        style: navStyle(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(hintText: 'Your full name'),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // ── Email ─────────────────────────────────────
                    Text('Email Address',
                        style: navStyle(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration:
                          const InputDecoration(hintText: 'you@example.com'),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // ── Password ──────────────────────────────────
                    Text('Password',
                        style: navStyle(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _showPassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _showPassword = !_showPassword),
                        ),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),

                    // ── Confirm Password ──────────────────────────
                    Text('Confirm Password',
                        style: navStyle(size: 12.5, weight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _showConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(() =>
                              _showConfirmPassword = !_showConfirmPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (v != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _signup(),
                    ),
                    const SizedBox(height: 28),

                    // ── Sign Up Button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('SIGN UP'),
                      ),
                    ),

                    // ── Loading status text ───────────────────────
                    if (_isLoading) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Creating your account…',
                          style: bodyStyle(size: 12.5, color: AppColors.green),
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    // ── Divider ───────────────────────────────────
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or sign up with',
                              style: bodyStyle(size: 12)),
                        ),
                        const Expanded(
                            child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Social Buttons ────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Google signup is not connected.'))),
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Google'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: Text(
                                            'Facebook signup is not connected.'))),
                            icon: const Icon(Icons.facebook),
                            label: const Text('Facebook'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Login Link ────────────────────────────────
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: bodyStyle(size: 13),
                          children: [
                            const TextSpan(text: 'Already have an account? '),
                            TextSpan(
                              text: 'Log in',
                              style: navStyle(
                                  size: 13,
                                  color: AppColors.green,
                                  weight: FontWeight.w600),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 14, color: AppColors.green),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: bodyStyle(size: 13))),
        ],
      ),
    );
  }
}
