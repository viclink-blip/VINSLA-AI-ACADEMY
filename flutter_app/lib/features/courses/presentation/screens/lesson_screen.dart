import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/gradient_button.dart';

class LessonScreen extends StatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});
  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  Map<String, dynamic>? _lesson;
  bool _loading    = true;
  bool _completing = false;
  bool _completed  = false;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _load();
    _stopwatch.start();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.dio.get('/lessons/${widget.lessonId}');
      final data = res.data['data'];
      setState(() {
        _lesson    = data;
        _completed = data['progress']?['completed'] == true;
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _markComplete() async {
    if (_completed) return;
    setState(() => _completing = true);
    _stopwatch.stop();
    try {
      await ApiClient.instance.dio.post(
        '/progress/lesson/${widget.lessonId}/complete',
        data: {'time_spent': _stopwatch.elapsed.inSeconds},
      );
      setState(() { _completed = true; _completing = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Lesson completed! 🎉'),
            ]),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (_) { setState(() => _completing = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading lesson...'));
    if (_lesson == null) return const Scaffold(body: Center(child: Text('Lesson not found')));

    final codeExamples = (_lesson!['code_examples'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_lesson!['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_completed)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.check_circle_rounded, color: AppColors.success),
            ),
        ],
      ),
      body: Column(children: [
        // ── Progress indicator ──────────────────────────
        if (_completed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.success.withOpacity(0.12),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
              SizedBox(width: 6),
              Text('Lesson Completed', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Lesson type badge ─────────────────────
              Row(children: [
                _typeBadge(_lesson!['lesson_type'] ?? 'theory'),
                const SizedBox(width: 8),
                const Icon(Icons.schedule_rounded, size: 14, color: AppColors.darkTextSub),
                const SizedBox(width: 4),
                Text('${_lesson!['duration_minutes'] ?? 0} min',
                  style: const TextStyle(color: AppColors.darkTextSub, fontSize: 13)),
              ]).animate().fadeIn(),

              const SizedBox(height: 20),

              // ── Main content (markdown) ───────────────
              MarkdownBody(
                data: _lesson!['content'] ?? '',
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.4),
                  h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, height: 1.4),
                  h3: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.brandCyan),
                  p:  const TextStyle(fontSize: 15, color: AppColors.darkText, height: 1.7),
                  li: const TextStyle(fontSize: 15, color: AppColors.darkText, height: 1.7),
                  strong: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                  em: const TextStyle(color: AppColors.brandCyan, fontStyle: FontStyle.italic),
                  code: const TextStyle(
                    color: AppColors.brandCyan,
                    backgroundColor: Color(0xFF0D1117),
                    fontFamily: 'monospace', fontSize: 13,
                  ),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: AppColors.brandPurple.withOpacity(0.1),
                    border: const Border(left: BorderSide(color: AppColors.brandPurple, width: 4)),
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  blockquote: const TextStyle(color: AppColors.darkTextSub, fontSize: 14, height: 1.6),
                ),
              ).animate().fadeIn(delay: 100.ms),

              // ── Code Examples ─────────────────────────
              if (codeExamples.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text('Code Examples', style: Theme.of(context).textTheme.headlineMedium)
                    .animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 16),
                ...codeExamples.asMap().entries.map((e) {
                  final ex = e.value as Map<String, dynamic>;
                  return _CodeBlock(
                    title: ex['title'] ?? 'Example ${e.key + 1}',
                    code:  ex['code'] ?? '',
                    language: ex['language'] ?? 'python',
                  ).animate().fadeIn(delay: Duration(milliseconds: 200 + e.key * 80));
                }),
              ],

              const SizedBox(height: 100),
            ]),
          ),
        ),

        // ── Bottom CTA ────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            border: const Border(top: BorderSide(color: AppColors.darkBorder)),
          ),
          child: _completed
            ? OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                label: const Text('Completed — Go Back', style: TextStyle(color: AppColors.success)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppColors.success),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            : GradientButton(
                text: 'Mark as Complete',
                isLoading: _completing,
                onPressed: _markComplete,
                icon: const Icon(Icons.check_rounded, color: Colors.white),
              ),
        ),
      ]),
    );
  }

  Widget _typeBadge(String type) {
    final map = {
      'theory':   (AppColors.brandPurple, Icons.menu_book_rounded,   'Theory'),
      'practice': (AppColors.brandCyan,   Icons.code_rounded,        'Practice'),
      'quiz':     (AppColors.brandGold,   Icons.quiz_rounded,        'Quiz'),
      'project':  (AppColors.success,     Icons.build_rounded,       'Project'),
    };
    final info = map[type] ?? (AppColors.darkTextSub, Icons.circle, type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (info.$1 as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(info.$2 as IconData, size: 14, color: info.$1 as Color),
        const SizedBox(width: 5),
        Text(info.$3 as String,
          style: TextStyle(color: info.$1 as Color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _CodeBlock extends StatefulWidget {
  final String title, code, language;
  const _CodeBlock({required this.title, required this.code, required this.language});
  @override
  State<_CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<_CodeBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    // In production: use Clipboard.setData
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Row(children: [
            // Traffic light dots
            Row(children: [
              _dot(const Color(0xFFFF5F56)),
              const SizedBox(width: 6),
              _dot(const Color(0xFFFFBD2E)),
              const SizedBox(width: 6),
              _dot(const Color(0xFF27C93F)),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.title,
              style: const TextStyle(color: AppColors.darkTextSub, fontSize: 13))),
            GestureDetector(
              onTap: _copy,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(_copied ? Icons.check_rounded : Icons.copy_rounded,
                  color: _copied ? AppColors.success : AppColors.darkTextSub, size: 16),
                const SizedBox(width: 4),
                Text(_copied ? 'Copied!' : 'Copy',
                  style: TextStyle(
                    color: _copied ? AppColors.success : AppColors.darkTextSub, fontSize: 12)),
              ]),
            ),
          ]),
        ),
        // Code
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: HighlightView(
            widget.code,
            language: widget.language,
            theme: atomOneDarkTheme,
            padding: EdgeInsets.zero,
            textStyle: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.6),
          ),
        ),
      ]),
    );
  }

  Widget _dot(Color c) => Container(width: 12, height: 12,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle));
}
