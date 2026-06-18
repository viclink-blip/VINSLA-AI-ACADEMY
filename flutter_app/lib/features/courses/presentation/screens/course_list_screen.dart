import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _categories = ['All', 'Python', 'AI', 'ML'];
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _categories.length, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.dio.get('/courses/');
      setState(() { _courses = res.data['data'] ?? []; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<dynamic> _filtered(String cat) {
    if (cat == 'All') return _courses;
    return _courses.where((c) => c['category'] == cat.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        bottom: TabBar(
          controller: _tabs,
          tabs: _categories.map((c) => Tab(text: c)).toList(),
          labelColor: AppColors.brandPurple,
          unselectedLabelColor: AppColors.darkTextSub,
          indicatorColor: AppColors.brandPurple,
        ),
      ),
      body: _loading
        ? const LoadingWidget(message: 'Loading courses...')
        : TabBarView(
            controller: _tabs,
            children: _categories.map((cat) {
              final list = _filtered(cat);
              if (list.isEmpty) return const Center(child: Text('No courses yet'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _CourseTile(course: list[i])
                  .animate().fadeIn(delay: Duration(milliseconds: i * 80)).slideY(begin: 0.15),
              );
            }).toList(),
          ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseTile({required this.course});

  Color get _catColor {
    switch (course['category']) {
      case 'python': return AppColors.pythonColor;
      case 'ai':     return AppColors.aiColor;
      case 'ml':     return AppColors.mlColor;
      default:       return AppColors.brandPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: _catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
          child: Icon(_catIcon, color: _catColor, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course['title'] ?? '', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(course['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Row(children: [
            _pill(course['difficulty'] ?? 'beginner', AppColors.brandCyan),
            const SizedBox(width: 8),
            _pill('${course['total_lessons'] ?? 0} lessons', AppColors.darkTextSub),
          ]),
        ])),
        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.darkTextSub),
      ]),
    );
  }

  IconData get _catIcon {
    switch (course['category']) {
      case 'python': return Icons.code_rounded;
      case 'ai':     return Icons.psychology_rounded;
      case 'ml':     return Icons.insights_rounded;
      default:       return Icons.school_rounded;
    }
  }

  Widget _pill(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
  );
}
