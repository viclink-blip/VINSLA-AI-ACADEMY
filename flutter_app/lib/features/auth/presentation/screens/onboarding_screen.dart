import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = [
    _OnboardingPage(
      icon:     Icons.psychology_rounded,
      gradient: AppColors.aiGradient,
      title:    'Learn AI & Machine Learning',
      subtitle: 'Master the technologies shaping the future — from Python basics to building real AI apps.',
    ),
    _OnboardingPage(
      icon:     Icons.code_rounded,
      gradient: AppColors.pythonGradient,
      title:    'Python from Zero to Hero',
      subtitle: 'No experience needed. Start coding in Python today with hands-on lessons and real projects.',
    ),
    _OnboardingPage(
      icon:     Icons.smart_toy_rounded,
      gradient: AppColors.mlGradient,
      title:    'Your Personal AI Tutor',
      subtitle: 'Ask anything, anytime. Vinsla AI answers your questions and creates personalized study plans.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Skip', style: TextStyle(color: AppColors.darkTextSub)),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => _pages[i].build(context),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => AnimatedContainer(
                duration: 300.ms,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width:  _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color:        _page == i ? AppColors.brandPurple : AppColors.darkBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),

            const SizedBox(height: 32),

            // CTA buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  GradientButton(
                    text: _page == _pages.length - 1 ? 'Get Started Free' : 'Next',
                    onPressed: () {
                      if (_page < _pages.length - 1) {
                        _controller.nextPage(duration: 300.ms, curve: Curves.easeInOut);
                      } else {
                        context.go('/register');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Already have an account? Sign In',
                      style: TextStyle(color: AppColors.darkTextSub)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final Gradient gradient;
  final String title;
  final String subtitle;

  const _OnboardingPage({required this.icon, required this.gradient,
    required this.title, required this.subtitle});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(gradient: gradient, shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.brandPurple.withOpacity(0.3), blurRadius: 40)]),
            child: Icon(icon, size: 70, color: Colors.white),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white))
            .animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
          const SizedBox(height: 16),
          Text(subtitle, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: AppColors.darkTextSub, height: 1.6))
            .animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
