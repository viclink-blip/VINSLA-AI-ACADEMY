import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  Map<String, dynamic>? _analytics;
  List<dynamic> _users   = [];
  List<dynamic> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        ApiClient.instance.dio.get('/admin/analytics'),
        ApiClient.instance.dio.get('/admin/users'),
        ApiClient.instance.dio.get('/courses/'),
      ]);
      setState(() {
        _analytics = results[0].data['data'];
        _users     = results[1].data['data']?['items'] ?? [];
        _courses   = results[2].data['data'] ?? [];
        _loading   = false;
      });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading admin panel...'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Dashboard'), Tab(text: 'Users'), Tab(text: 'Courses')],
          labelColor: AppColors.brandPurple,
          unselectedLabelColor: AppColors.darkTextSub,
          indicatorColor: AppColors.brandPurple,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _DashboardTab(analytics: _analytics),
          _UsersTab(users: _users, onRefresh: _load),
          _CoursesTab(courses: _courses),
        ],
      ),
    );
  }
}

// ── Dashboard Tab ────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final Map<String, dynamic>? analytics;
  const _DashboardTab({this.analytics});

  @override
  Widget build(BuildContext context) {
    final a = analytics ?? {};
    final stats = [
      ('Total Users',        '${a['total_users'] ?? 0}',        Icons.people_rounded,              AppColors.brandPurple),
      ('Active Users',       '${a['active_users'] ?? 0}',       Icons.person_rounded,              AppColors.success),
      ('Total Courses',      '${a['total_courses'] ?? 0}',      Icons.school_rounded,              AppColors.brandCyan),
      ('Enrollments',        '${a['total_enrollments'] ?? 0}',  Icons.how_to_reg_rounded,          AppColors.warning),
      ('Certificates',       '${a['total_certificates'] ?? 0}', Icons.workspace_premium_rounded,   AppColors.brandGold),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Overview', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4),
          itemCount: stats.length,
          itemBuilder: (_, i) => _StatTile(
            label: stats[i].$1, value: stats[i].$2,
            icon: stats[i].$3, color: stats[i].$4,
          ).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
        ),

        const SizedBox(height: 28),
        Text('Enrollment Activity', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),

        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: BarChart(BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: (5 + i * 2.0).clamp(1, 18),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [AppColors.brandPurple, AppColors.brandCyan],
                ),
              ),
            ])),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  ['M','T','W','T','F','S','S'][v.toInt()],
                  style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
              )),
              leftTitles:   AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData:    FlGridData(show: false),
            borderData:  FlBorderData(show: false),
          )),
        ).animate().fadeIn(delay: 300.ms),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 26),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w800)),
        Text(label, style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
      ]),
    );
  }
}

// ── Users Tab ────────────────────────────────────────────
class _UsersTab extends StatelessWidget {
  final List<dynamic> users;
  final VoidCallback onRefresh;
  const _UsersTab({required this.users, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.brandPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (_, i) {
          final u = users[i] as Map<String, dynamic>;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.brandPurple.withOpacity(0.2),
                child: Text((u['full_name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(u['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(u['email'] ?? '', style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
              ])),
              _roleBadge(u['role'] ?? 'student'),
              const SizedBox(width: 8),
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: u['is_active'] == true ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ]),
          ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
        },
      ),
    );
  }

  Widget _roleBadge(String role) {
    final colors = {
      'admin':      AppColors.brandGold,
      'instructor': AppColors.brandCyan,
      'student':    AppColors.darkTextSub,
    };
    final c = colors[role] ?? AppColors.darkTextSub;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(role, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ── Courses Tab ──────────────────────────────────────────
class _CoursesTab extends StatelessWidget {
  final List<dynamic> courses;
  const _CoursesTab({required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (_, i) {
        final c = courses[i] as Map<String, dynamic>;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_catIcon(c['category']), color: AppColors.brandPurple, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('${c['total_lessons'] ?? 0} lessons · ${c['difficulty'] ?? ''}',
                style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c['is_published'] == true
                  ? AppColors.success.withOpacity(0.15) : AppColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(c['is_published'] == true ? 'Published' : 'Draft',
                style: TextStyle(
                  color: c['is_published'] == true ? AppColors.success : AppColors.warning,
                  fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ]),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
      },
    );
  }

  IconData _catIcon(dynamic cat) {
    switch (cat) {
      case 'python': return Icons.code_rounded;
      case 'ai':     return Icons.psychology_rounded;
      case 'ml':     return Icons.insights_rounded;
      default:       return Icons.school_rounded;
    }
  }
}
