import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form      = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiClient.instance.dio.post('/auth/login', data: {
        'email':    _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      });
      final d = res.data['data'];
      await ApiClient.instance.saveTokens(d['access_token'], d['refresh_token']);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _error = 'Invalid email or password. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo
                Center(
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.psychology_rounded, size: 40, color: Colors.white),
                  ),
                ).animate().scale(duration: 500.ms),

                const SizedBox(height: 32),
                Text('Welcome Back', style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text('Continue your AI learning journey',
                  style: Theme.of(context).textTheme.bodyMedium)
                  .animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                // Error banner
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:        AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: AppColors.error.withOpacity(0.4)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email
                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration:   const InputDecoration(
                    labelText:  'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller:  _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:   'Password',
                    prefixIcon:  const Icon(Icons.lock_outline),
                    suffixIcon:  IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 8 ? null : 'Password too short',
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/forgot-password'),
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.brandPurple)),
                  ),
                ),

                const SizedBox(height: 24),

                GradientButton(
                  text: 'Sign In',
                  isLoading: _loading,
                  onPressed: _login,
                ).animate().fadeIn(delay: 450.ms),

                const SizedBox(height: 20),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("Don't have an account? ",
                    style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.go('/register'),
                    child: const Text('Sign Up',
                      style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w700)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
