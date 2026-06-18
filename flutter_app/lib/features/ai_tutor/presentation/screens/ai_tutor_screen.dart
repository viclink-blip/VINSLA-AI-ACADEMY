import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});
  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final _msgCtrl   = TextEditingController();
  final _scroll    = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _sending    = false;
  String? _sessionId;

  // Quick-action prompts
  final _quickActions = [
    ('Explain Python decorators', Icons.code_rounded),
    ('What is a neural network?', Icons.psychology_rounded),
    ('How does gradient descent work?', Icons.show_chart_rounded),
    ('Create a study plan for ML', Icons.calendar_today_rounded),
    ('Generate a Python quiz', Icons.quiz_rounded),
    ('Explain GPT in simple terms', Icons.chat_bubble_rounded),
  ];

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _msgCtrl.clear();

    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _sending = true;
    });
    _scrollToBottom();

    try {
      final res = await ApiClient.instance.dio.post('/ai-tutor/chat', data: {
        'message':    text,
        if (_sessionId != null) 'session_id': _sessionId,
      });
      final d = res.data['data'];
      setState(() {
        _sessionId = d['session_id'];
        _messages.add(d['message']);
        _sending = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'content': '❌ Sorry, I encountered an error. Please try again.'});
        _sending = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Vinsla AI Tutor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Python • AI • ML Expert', style: TextStyle(fontSize: 11, color: AppColors.darkTextSub)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {
            setState(() { _messages = []; _sessionId = null; });
          }),
        ],
      ),
      body: Column(children: [
        // ── Chat Messages ────────────────────────────────
        Expanded(
          child: _messages.isEmpty
            ? _WelcomeView(quickActions: _quickActions, onTap: _sendMessage)
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_sending ? 1 : 0),
                itemBuilder: (_, i) {
                  if (i == _messages.length) return const _TypingIndicator();
                  return _MessageBubble(msg: _messages[i])
                    .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
                },
              ),
        ),

        // ── Input Bar ────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(top: BorderSide(color: AppColors.darkBorder)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                maxLines:   null,
                decoration: InputDecoration(
                  hintText:       'Ask about Python, AI, or ML...',
                  border:         OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.darkBorder)),
                  enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.darkBorder)),
                  focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.brandPurple, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _sendMessage(_msgCtrl.text),
              child: Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                  gradient: AppColors.heroGradient, shape: BoxShape.circle),
                child: _sending
                  ? const SizedBox.shrink()
                  : const Icon(Icons.send_rounded, color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  const _MessageBubble({required this.msg});

  bool get isUser => msg['role'] == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 8, bottom: 8,
        left:  isUser ? 60 : 0,
        right: isUser ? 0  : 60,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32, height: 32, margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: const BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:        isUser ? AppColors.brandPurple : AppColors.darkCard,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4  : 16),
                ),
              ),
              child: isUser
                ? Text(msg['content'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5))
                : MarkdownBody(
                    data: msg['content'] ?? '',
                    styleSheet: MarkdownStyleSheet(
                      p:      const TextStyle(color: AppColors.darkText, fontSize: 14, height: 1.6),
                      code:   const TextStyle(color: AppColors.brandCyan, backgroundColor: Color(0xFF0A0E27), fontSize: 13),
                      codeblockDecoration: BoxDecoration(color: const Color(0xFF0A0E27), borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(children: [
        Container(
          width: 32, height: 32, margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
          child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 18),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            ...List.generate(3, (i) => Container(
              width: 8, height: 8, margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
              decoration: const BoxDecoration(color: AppColors.brandPurple, shape: BoxShape.circle),
            ).animate(onPlay: (c) => c.repeat()).moveY(
              begin: 0, end: -6, delay: Duration(milliseconds: i * 150),
              duration: 400.ms, curve: Curves.easeInOut,
            )),
          ]),
        ),
      ]),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  final List<(String, IconData)> quickActions;
  final void Function(String) onTap;
  const _WelcomeView({required this.quickActions, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 32),
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(gradient: AppColors.heroGradient, shape: BoxShape.circle),
          child: const Icon(Icons.psychology_rounded, size: 44, color: Colors.white),
        ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Text("Hi! I'm Vinsla 👋",
          style: Theme.of(context).textTheme.headlineLarge).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 8),
        Text('Your AI tutor for Python, AI & Machine Learning.\nAsk me anything!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 32),
        Text('Quick Start', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ...quickActions.asMap().entries.map((e) => GestureDetector(
            onTap: () => onTap(e.value.$1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.darkCard,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(color: AppColors.darkBorder),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(e.value.$2, size: 16, color: AppColors.brandPurple),
                const SizedBox(width: 6),
                Text(e.value.$1, style: const TextStyle(fontSize: 13)),
              ]),
            ).animate().fadeIn(delay: Duration(milliseconds: 400 + e.key * 60)),
          )),
        ]),
      ]),
    );
  }
}
