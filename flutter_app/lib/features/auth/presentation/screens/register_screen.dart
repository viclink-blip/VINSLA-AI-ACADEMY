import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/utils/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form      = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _userCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  Future<void> _register() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final res = await ApiClient.instance.dio.post('/auth/register', data: {
        'full_name': _nameCtrl.text.trim(),
        'username':  _userCtrl.text.trim(),
        'email':     _emailCtrl.text.trim(),
        'password':  _passCtrl.text,
      });
      final d = res.data['data'];
      await ApiClient.instance.saveTokens(d['access_token'], d['refresh_token']);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _error = 'Registration failed. Email or username may already be taken.';
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
                const SizedBox(height: 32),
                Text('Create Account', style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 8),
                Text('Join 10,000+ learners mastering AI',
                  style: Theme.of(context).textTheme.bodyMedium),

                const SizedBox(height: 32),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.4)),
                    ),
                    child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => (v?.isNotEmpty ?? false) ? null : 'Name is required',
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email)),
                  validator: (v) => (v?.length ?? 0) >= 3 ? null : 'Min 3 characters',
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined)),
                  validator: (v) => v != null && v.contains('@') ? null : 'Valid email required',
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText:  'Password (min 8 chars)',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) >= 8 ? null : 'Min 8 characters',
                ).animate().fadeIn(delay: 250.ms),

                const SizedBox(height: 28),

                GradientButton(
                  text:      'Create Account',
                  isLoading: _loading,
                  onPressed: _register,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Already have an account? ', style: Theme.of(context).textTheme.bodyMedium),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text('Sign In',
                      style: TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
