import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/main_shell.dart';
import '../../features/courses/presentation/screens/course_detail_screen.dart';
import '../../features/courses/presentation/screens/lesson_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/admin/presentation/screens/admin_screen.dart';

final _storage = const FlutterSecureStorage();

Future<String?> _authRedirect(BuildContext context, GoRouterState state) async {
  final token = await _storage.read(key: AppConstants.kAccessToken);
  final isAuth = token != null;
  final isPublic = ['/login', '/register', '/onboarding', '/forgot-password', '/splash']
      .any((p) => state.matchedLocation.startsWith(p));
  if (!isAuth && !isPublic) return '/login';
  if (isAuth && isPublic)  return '/dashboard';
  return null;
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: _authRedirect,
  routes: [
    GoRoute(path: '/splash',           builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding',       builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login',            builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register',         builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/forgot-password',  builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/dashboard',        builder: (_, __) => const MainShell()),
    GoRoute(
      path: '/courses/:slug',
      builder: (_, state) => CourseDetailScreen(slug: state.pathParameters['slug']!),
    ),
    GoRoute(
      path: '/lessons/:id',
      builder: (_, state) => LessonScreen(lessonId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/quiz/:id',
      builder: (_, state) => QuizScreen(quizId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/admin',            builder: (_, __) => const AdminScreen()),
  ],
);
