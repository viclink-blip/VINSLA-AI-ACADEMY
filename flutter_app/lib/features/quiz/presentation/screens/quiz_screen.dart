import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/gradient_button.dart';

class QuizScreen extends StatefulWidget {
  final String quizId;
  const QuizScreen({super.key, required this.quizId});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? _quiz;
  final Map<String, int> _answers = {};
  bool _loading    = true;
  bool _submitting = false;
  bool _submitted  = false;
  Map<String, dynamic>? _result;
  int _currentQ    = 0;
  final _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final res = await ApiClient.instance.dio.get('/quiz/${widget.quizId}');
      setState(() { _quiz = res.data['data']; _loading = false; });
      _stopwatch.start();
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final questions = (_quiz?['questions'] as List?) ?? [];
    if (_answers.length < questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions'), backgroundColor: AppColors.warning));
      return;
    }

    setState(() => _submitting = true);
    _stopwatch.stop();

    try {
      final res = await ApiClient.instance.dio.post('/quiz/${widget.quizId}/submit', data: {
        'answers':    _answers,
        'time_taken': _stopwatch.elapsed.inSeconds,
      });
      setState(() {
        _result    = res.data['data'];
        _submitted = true;
        _submitting = false;
      });
    } catch (_) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading quiz...'));
    if (_submitted && _result != null) return _ResultScreen(result: _result!, quiz: _quiz!, onRetry: () {
      setState(() { _submitted = false; _answers.clear(); _currentQ = 0; _result = null; _stopwatch.reset(); _stopwatch.start(); });
    });

    final questions = (_quiz?['questions'] as List?) ?? [];
    if (questions.isEmpty) return const Scaffold(body: Center(child: Text('No questions found')));

    final q   = questions[_currentQ] as Map<String, dynamic>;
    final opts = (q['options'] as List?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz?['title'] ?? 'Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_currentQ + 1}/${questions.length}',
              style: const TextStyle(color: AppColors.brandCyan, fontWeight: FontWeight.w700))),
          ),
        ],
      ),
      body: Column(children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentQ + 1) / questions.length,
          backgroundColor: AppColors.darkBorder,
          valueColor: const AlwaysStoppedAnimation(AppColors.brandPurple),
          minHeight: 4,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              // Question number chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brandPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Question ${_currentQ + 1}',
                  style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 16),

              Text(q['question_text'] ?? '',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.5))
                .animate().fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 28),

              // Options
              ...opts.asMap().entries.map((e) {
                final selected = _answers[q['id'].toString()] == e.key;
                return GestureDetector(
                  onTap: () => setState(() => _answers[q['id'].toString()] = e.key),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:        selected ? AppColors.brandPurple.withOpacity(0.15) : AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(
                        color: selected ? AppColors.brandPurple : AppColors.darkBorder,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color:  selected ? AppColors.brandPurple : Colors.transparent,
                          border: Border.all(color: selected ? AppColors.brandPurple : AppColors.darkTextSub),
                          shape:  BoxShape.circle,
                        ),
                        child: selected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(e.value.toString(),
                        style: TextStyle(color: selected ? Colors.white : null, fontSize: 15, height: 1.4))),
                    ]),
                  ).animate().fadeIn(delay: Duration(milliseconds: e.key * 60)),
                );
              }),
            ]),
          ),
        ),

        // Navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Row(children: [
            if (_currentQ > 0) ...[
              Expanded(child: OutlinedButton(
                onPressed: () => setState(() => _currentQ--),
                child: const Text('Back'),
              )),
              const SizedBox(width: 12),
            ],
            Expanded(flex: 2, child: GradientButton(
              text:      _currentQ == questions.length - 1 ? 'Submit Quiz' : 'Next',
              isLoading: _submitting,
              onPressed: _currentQ == questions.length - 1 ? _submit
                : () => setState(() => _currentQ++),
            )),
          ]),
        ),
      ]),
    );
  }
}

class _ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final Map<String, dynamic> quiz;
  final VoidCallback onRetry;
  const _ResultScreen({required this.result, required this.quiz, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final score  = result['score'] as int? ?? 0;
    final passed = result['passed'] as bool? ?? false;
    final color  = passed ? AppColors.success : AppColors.error;
    final emoji  = passed ? '🎉' : '📚';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(emoji, style: const TextStyle(fontSize: 80))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(passed ? 'Congratulations!' : 'Keep Practicing!',
              style: Theme.of(context).textTheme.headlineLarge)
              .animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 16),

            // Score circle
            Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 6),
                color: color.withOpacity(0.1),
              ),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$score%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color)),
                Text(passed ? 'PASSED' : 'FAILED', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ])),
            ).animate().scale(delay: 300.ms, duration: 500.ms, curve: Curves.elasticOut),

            const SizedBox(height: 32),
            Text('Pass score: ${quiz['pass_score']}%', style: Theme.of(context).textTheme.bodyMedium),

            const SizedBox(height: 40),

            // Review answers
            if ((result['results'] as List?)?.isNotEmpty == true) ...[
              Text('Answer Review', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: (result['results'] as List).length,
                  itemBuilder: (_, i) {
                    final r = (result['results'] as List)[i] as Map<String, dynamic>;
                    final correct = r['is_correct'] as bool? ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color:        correct ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border:       Border.all(color: correct ? AppColors.success : AppColors.error, width: 1),
                      ),
                      child: Row(children: [
                        Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? AppColors.success : AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        if (r['explanation'] != null)
                          Expanded(child: Text(r['explanation'].toString(),
                            style: const TextStyle(fontSize: 13, height: 1.4))),
                      ]),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),
            GradientButton(text: 'Try Again', onPressed: onRetry),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: const Text('Back to Course'),
            ),
          ]),
        ),
      ),
    );
  }
}
