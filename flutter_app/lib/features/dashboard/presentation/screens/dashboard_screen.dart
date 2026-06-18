import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _progress;
  List<dynamic> _courses  = [];
  bool _loading  = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        ApiClient.instance.dio.get('/auth/me'),
        ApiClient.instance.dio.get('/progress/dashboard'),
        ApiClient.instance.dio.get('/courses/'),
      ]);
      setState(() {
        _user     = results[0].data['data'];
        _progress = results[1].data['data'];
        _courses  = results[2].data['data'] ?? [];
        _loading  = false;
      });
    } catch (e) {
      setState(() { _error = 'Failed to load dashboard'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading your dashboard...'));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.brandPurple,
        child: CustomScrollView(
          slivers: [
            // ── Hero App Bar ──────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned:         true,
              backgroundColor: AppColors.darkBg,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1040), Color(0xFF0A0E27)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment:  MainAxisAlignment.end,
                    children: [
                      Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Good ${_greeting()}, 👋',
                              style: const TextStyle(fontSize: 13, color: AppColors.brandCyan)),
                            const SizedBox(height: 4),
                            Text(_user?['full_name'] ?? 'Learner',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                          ],
                        )),
                        _StreakBadge(days: _user?['streak_days'] ?? 0),
                      ]),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(delegate: SliverChildListDelegate([

                // ── Stats Row ─────────────────────────────
                _StatsRow(progress: _progress).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),

                // ── Continue Learning ─────────────────────
                if ((_progress?['enrollments'] as List?)?.isNotEmpty == true) ...[
                  _SectionHeader(title: 'Continue Learning', actionLabel: 'View All', onTap: () {}),
                  const SizedBox(height: 12),
                  ...((_progress!['enrollments'] as List).take(2).map((e) =>
                    _ContinueLearningCard(enrollment: e, courses: _courses)
                      .animate().fadeIn(delay: 200.ms).slideX(begin: -0.1)
                  )),
                  const SizedBox(height: 24),
                ],

                // ── All Courses ───────────────────────────
                _SectionHeader(title: 'All Courses', actionLabel: '', onTap: null),
                const SizedBox(height: 12),

                ..._courses.asMap().entries.map((entry) =>
                  _CourseCard(course: entry.value)
                    .animate().fadeIn(delay: Duration(milliseconds: 200 + entry.key * 80))
                    .slideY(begin: 0.2)
                ),

                const SizedBox(height: 80),
              ])),
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Morning';
    if (h < 17) return 'Afternoon';
    return 'Evening';
  }
}

class _StreakBadge extends StatelessWidget {
  final int days;
  const _StreakBadge({required this.days});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF6B35), Color(0xFFFFD700)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('🔥', style: TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Text('$days', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
      ]),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final Map<String, dynamic>? progress;
  const _StatsRow({this.progress});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(label: 'Lessons Done',   value: '${progress?['lessons_done'] ?? 0}',   icon: Icons.check_circle_rounded, color: AppColors.success),
      const SizedBox(width: 12),
      _StatCard(label: 'Enrolled',       value: '${progress?['courses_enrolled'] ?? 0}', icon: Icons.school_rounded,       color: AppColors.brandPurple),
      const SizedBox(width: 12),
      _StatCard(label: 'Completed',      value: '${progress?['courses_completed'] ?? 0}',icon: Icons.emoji_events_rounded, color: AppColors.brandGold),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.darkTextSub, fontSize: 10), textAlign: TextAlign.center),
      ]),
    ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, actionLabel;
  final VoidCallback? onTap;
  const _SectionHeader({required this.title, required this.actionLabel, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (onTap != null && actionLabel.isNotEmpty)
          TextButton(onPressed: onTap, child: Text(actionLabel,
            style: const TextStyle(color: AppColors.brandPurple))),
      ],
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final Map<String, dynamic> enrollment;
  final List<dynamic> courses;
  const _ContinueLearningCard({required this.enrollment, required this.courses});

  @override
  Widget build(BuildContext context) {
    final pct = (enrollment['progress_pct'] as num? ?? 0).toDouble() / 100;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Course in Progress', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        LinearPercentIndicator(
          lineHeight: 8, percent: pct.clamp(0, 1),
          backgroundColor: AppColors.darkBorder,
          progressColor: AppColors.brandPurple,
          barRadius: const Radius.circular(4),
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Text('${(pct * 100).toInt()}% complete',
          style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
      ]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseCard({required this.course});

  Gradient get _gradient {
    switch (course['category']) {
      case 'python': return AppColors.pythonGradient;
      case 'ai':     return AppColors.aiGradient;
      case 'ml':     return AppColors.mlGradient;
      default:       return AppColors.heroGradient;
    }
  }

  IconData get _icon {
    switch (course['category']) {
      case 'python': return Icons.code_rounded;
      case 'ai':     return Icons.psychology_rounded;
      case 'ml':     return Icons.insights_rounded;
      default:       return Icons.school_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Course banner
        Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Center(child: Icon(_icon, size: 56, color: Colors.white.withOpacity(0.9))),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(course['category'].toString().toUpperCase(),
                style: const TextStyle(color: AppColors.brandPurple, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 10),
            Text(course['title'] ?? '', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(course['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.play_lesson_rounded, size: 16, color: AppColors.darkTextSub),
                const SizedBox(width: 4),
                Text('${course['total_lessons'] ?? 0} lessons',
                  style: const TextStyle(color: AppColors.darkTextSub, fontSize: 13)),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(gradient: _gradient, borderRadius: BorderRadius.circular(8)),
                child: const Text('Start Learning',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
