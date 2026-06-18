import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import 'dashboard_screen.dart';
import '../../../courses/presentation/screens/course_list_screen.dart';
import '../../../ai_tutor/presentation/screens/ai_tutor_screen.dart';
import '../../../certificates/presentation/screens/certificates_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DashboardScreen(),
    CourseListScreen(),
    AiTutorScreen(),
    CertificatesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: const Border(top: BorderSide(color: AppColors.darkBorder)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_rounded,                label: 'Home',    index: 0, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.school_rounded,              label: 'Courses',  index: 1, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.psychology_rounded,          label: 'AI Tutor', index: 2, current: _index, onTap: _setIndex, isCenter: true),
                _NavItem(icon: Icons.workspace_premium_rounded,   label: 'Certs',    index: 3, current: _index, onTap: _setIndex),
                _NavItem(icon: Icons.person_rounded,              label: 'Profile',  index: 4, current: _index, onTap: _setIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int i) => setState(() => _index = i);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final void Function(int) onTap;
  final bool isCenter;

  const _NavItem({required this.icon, required this.label, required this.index,
    required this.current, required this.onTap, this.isCenter = false});

  bool get _active => index == current;

  @override
  Widget build(BuildContext context) {
    if (isCenter) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 56, height: 56,
          decoration: const BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Color(0x556C63FF), blurRadius: 16, offset: Offset(0, 4))]),
          child: Icon(icon, color: Colors.white, size: 28),
        ).animate(target: _active ? 1 : 0).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.05, 1.05)),
      );
    }
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _active ? AppColors.brandPurple.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: _active ? AppColors.brandPurple : AppColors.darkTextSub, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(
            color: _active ? AppColors.brandPurple : AppColors.darkTextSub,
            fontSize: 10, fontWeight: _active ? FontWeight.w600 : FontWeight.normal)),
        ]),
      ),
    );
  }
}
