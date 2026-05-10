import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/app_snackbar.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<AuthViewModel>();
    final success =
        await vm.login(_emailCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (success) {
      AppSnackbar.success(context, 'Welcome back!');
      final role = vm.user!.role;
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pushReplacementNamed(
          context, role == 'admin' ? '/admin' : '/home');
    } else {
      // Friendly error mapping
      final raw = vm.errorMessage ?? 'Login failed';
      final friendly = _mapError(raw);
      AppSnackbar.error(context, friendly);
    }
  }

  // Maps Supabase error codes to user-friendly messages
  String _mapError(String raw) {
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please try again.';
    } else if (raw.contains('Email not confirmed')) {
      return 'Please confirm your email before logging in.';
    } else if (raw.contains('network') || raw.contains('socket')) {
      return 'No internet connection. Check your network.';
    } else if (raw.contains('too many requests') ||
        raw.contains('rate_limit')) {
      return 'Too many attempts. Please wait a moment.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _forgotPassword() async {
    final emailCtrl = TextEditingController(text: _emailCtrl.text.trim());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Password',
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email and we\'ll send you a reset link.',
              style:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 42)),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final email = emailCtrl.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        AppSnackbar.error(context, 'Enter a valid email first.');
        return;
      }
      try {
        await context.read<AuthViewModel>().sendPasswordReset(email);
        if (mounted) {
          AppSnackbar.success(
              context, 'Reset link sent! Check your inbox.');
        }
      } catch (_) {
        if (mounted) {
          AppSnackbar.error(context, 'Could not send reset link. Try again.');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Back to splash
                IconButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/'),
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: AppTheme.primary, size: 20),
                  padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                // Header
                const Text(
                  'Login here',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Welcome back, you've\nbeen missed!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 36),

                // Email field
                AuthTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@') || !v.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password field
                AuthTextField(
                  label: 'Password',
                  controller: _passwordCtrl,
                  prefixIcon: Icons.lock_outline,
                  obscure: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Remember me + Forgot password row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          activeColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                        ),
                        const Text('Remember me',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                    TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: vm.isLoading ? null : _submit,
                                    style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 0,
                  ),

                  child: vm.isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Sign in'),
                ),

                const SizedBox(height: 24),

                // Register link
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/register'),
                    child: RichText(
                      text: const TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Create new account',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}