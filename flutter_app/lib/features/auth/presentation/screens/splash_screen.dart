import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final storage = const FlutterSecureStorage();
    final token   = await storage.read(key: AppConstants.kAccessToken);
    if (token != null) {
      context.go('/dashboard');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient:     AppColors.heroGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: AppColors.brandPurple.withOpacity(0.4), blurRadius: 40)],
              ),
              child: const Icon(Icons.psychology_rounded, size: 56, color: Colors.white),
            )
            .animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 24),

            Text('Vinsla AI Academy',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.3),

            const SizedBox(height: 8),

            Text('Learn AI the Smart Way',
              style: const TextStyle(fontSize: 14, color: AppColors.brandCyan),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

            const SizedBox(height: 60),

            const CircularProgressIndicator(
              color: AppColors.brandPurple,
              strokeWidth: 2.5,
            ).animate().fadeIn(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
