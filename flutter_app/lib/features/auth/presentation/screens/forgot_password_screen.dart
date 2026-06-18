import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/utils/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form     = GlobalKey<FormState>();
  final _emailCtrl= TextEditingController();
  bool _loading   = false;
  bool _sent      = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiClient.instance.dio.post('/auth/forgot-password',
          data: {'email': _emailCtrl.text.trim()});
      setState(() { _sent = true; _loading = false; });
    } catch (_) {
      // Always show success to prevent enumeration
      setState(() { _sent = true; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _sent ? _SuccessView(email: _emailCtrl.text) : _FormView(
            form: _form, emailCtrl: _emailCtrl,
            loading: _loading, onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> form;
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  const _FormView({required this.form, required this.emailCtrl, required this.loading, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: form,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 32),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.brandPurple.withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.lock_reset_rounded, size: 34, color: AppColors.brandPurple),
        ).animate().scale(duration: 400.ms),
        const SizedBox(height: 24),
        Text('Reset Password', style: Theme.of(context).textTheme.displayMedium)
            .animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 8),
        Text('Enter your email and we\'ll send a reset link.',
            style: Theme.of(context).textTheme.bodyMedium)
            .animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 36),
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 24),
        GradientButton(
          text: 'Send Reset Link',
          isLoading: loading,
          onPressed: onSubmit,
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  const _SuccessView({required this.email});
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.mark_email_read_rounded, size: 52, color: AppColors.success),
      ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
      const SizedBox(height: 28),
      Text('Check Your Email', style: Theme.of(context).textTheme.headlineLarge)
          .animate().fadeIn(delay: 200.ms),
      const SizedBox(height: 12),
      Text('We\'ve sent a reset link to:\n$email',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6))
          .animate().fadeIn(delay: 300.ms),
      const SizedBox(height: 40),
      GradientButton(
        text: 'Back to Sign In',
        onPressed: () => context.go('/login'),
      ).animate().fadeIn(delay: 400.ms),
    ]);
  }
}
