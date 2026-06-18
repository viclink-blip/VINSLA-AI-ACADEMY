import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/gradient_button.dart';

class CourseDetailScreen extends StatefulWidget {
  final String slug;
  const CourseDetailScreen({super.key, required this.slug});
  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  Map<String, dynamic>? _course;
  bool _loading = true;
  bool _enrolling = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.dio.get('/courses/${widget.slug}');
      setState(() { _course = res.data['data']; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _enroll() async {
    setState(() => _enrolling = true);
    try {
      await ApiClient.instance.dio.post('/courses/${_course!['id']}/enroll');
      await _load();
    } catch (_) {}
    setState(() => _enrolling = false);
  }

  Gradient get _gradient {
    switch (_course?['category']) {
      case 'python': return AppColors.pythonGradient;
      case 'ai':     return AppColors.aiGradient;
      case 'ml':     return AppColors.mlGradient;
      default:       return AppColors.heroGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading course...'));
    if (_course == null) return const Scaffold(body: Center(child: Text('Course not found')));

    final modules    = (_course!['modules'] as List?) ?? [];
    final enrollment = _course!['enrollment'] as Map<String, dynamic>?;
    final pct        = (enrollment?['progress_pct'] as num? ?? 0).toDouble();
    final isEnrolled = enrollment != null;

    return Scaffold(
      body: CustomScrollView(slivers: [
        // ── Hero Banner ──────────────────────────────────
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(gradient: _gradient),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Icon(_catIcon, size: 72, color: Colors.white.withOpacity(0.9)),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(_course!['title'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                ),
              ]),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // ── Meta chips ───────────────────────────────
            Wrap(spacing: 8, children: [
              _chip(_course!['category']?.toString().toUpperCase() ?? '', AppColors.brandPurple),
              _chip(_course!['difficulty']?.toString().toUpperCase() ?? '', AppColors.brandCyan),
              _chip('${_course!['total_lessons'] ?? 0} LESSONS', AppColors.success),
            ]).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),
            Text(_course!['description'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6))
              .animate().fadeIn(delay: 150.ms),

            // ── Progress (if enrolled) ────────────────────
            if (isEnrolled) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Your Progress', style: Theme.of(context).textTheme.titleMedium),
                    Text('${pct.toInt()}%', style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w700)),
                  ]),
                  const SizedBox(height: 10),
                  LinearPercentIndicator(
                    lineHeight: 10, percent: (pct / 100).clamp(0, 1),
                    backgroundColor: AppColors.darkBorder,
                    progressColor: AppColors.brandPurple,
                    barRadius: const Radius.circular(5),
                    padding: EdgeInsets.zero,
                  ),
                ]),
              ).animate().fadeIn(delay: 200.ms),
            ],

            const SizedBox(height: 28),

            // ── Curriculum ────────────────────────────────
            Text('Curriculum', style: Theme.of(context).textTheme.headlineMedium)
                .animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 14),

            ...modules.asMap().entries.map((me) {
              final mod     = me.value as Map<String, dynamic>;
              final lessons = (mod['lessons'] as List?) ?? [];
              return _ModuleExpansion(
                module: mod, lessons: lessons,
                moduleIndex: me.key,
                isEnrolled: isEnrolled,
              ).animate().fadeIn(delay: Duration(milliseconds: 250 + me.key * 60));
            }),

            const SizedBox(height: 80),
          ])),
        ),
      ]),

      // ── CTA Button ────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          border: const Border(top: BorderSide(color: AppColors.darkBorder)),
        ),
        child: isEnrolled
          ? GradientButton(
              text: pct > 0 ? 'Continue Learning' : 'Start Course',
              onPressed: () {
                final firstLesson = modules.isNotEmpty
                  ? ((modules[0] as Map)['lessons'] as List?)?.firstOrNull
                  : null;
                if (firstLesson != null) {
                  context.push('/lessons/${firstLesson['id']}');
                }
              },
            )
          : GradientButton(
              text: 'Enroll for Free',
              isLoading: _enrolling,
              onPressed: _enroll,
            ),
      ),
    );
  }

  IconData get _catIcon {
    switch (_course?['category']) {
      case 'python': return Icons.code_rounded;
      case 'ai':     return Icons.psychology_rounded;
      case 'ml':     return Icons.insights_rounded;
      default:       return Icons.school_rounded;
    }
  }

  Widget _chip(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

class _ModuleExpansion extends StatefulWidget {
  final Map<String, dynamic> module;
  final List<dynamic> lessons;
  final int moduleIndex;
  final bool isEnrolled;
  const _ModuleExpansion({required this.module, required this.lessons,
    required this.moduleIndex, required this.isEnrolled});
  @override
  State<_ModuleExpansion> createState() => _ModuleExpansionState();
}

class _ModuleExpansionState extends State<_ModuleExpansion> {
  bool _open = false;

  @override
  void initState() { super.initState(); _open = widget.moduleIndex == 0; }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('${widget.moduleIndex + 1}',
                  style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.module['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                Text('${widget.lessons.length} lessons',
                  style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
              ])),
              Icon(_open ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: AppColors.darkTextSub),
            ]),
          ),
        ),
        if (_open) ...[
          const Divider(height: 1, color: AppColors.darkBorder),
          ...widget.lessons.map((l) {
            final lesson = l as Map<String, dynamic>;
            return _LessonTile(lesson: lesson, isEnrolled: widget.isEnrolled);
          }),
        ],
      ]),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final bool isEnrolled;
  const _LessonTile({required this.lesson, required this.isEnrolled});

  IconData get _typeIcon {
    switch (lesson['lesson_type']) {
      case 'quiz':     return Icons.quiz_rounded;
      case 'practice': return Icons.code_rounded;
      case 'project':  return Icons.build_rounded;
      default:         return Icons.play_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = !isEnrolled && !(lesson['is_free'] as bool? ?? false);
    return ListTile(
      onTap: locked ? null : () => context.push('/lessons/${lesson['id']}'),
      leading: Icon(_typeIcon, color: locked ? AppColors.darkTextSub : AppColors.brandCyan, size: 22),
      title: Text(lesson['title'] ?? '',
        style: TextStyle(fontSize: 14, color: locked ? AppColors.darkTextSub : null)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${lesson['duration_minutes'] ?? 0}m',
          style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
        const SizedBox(width: 8),
        Icon(locked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
          color: AppColors.darkTextSub, size: 18),
      ]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
