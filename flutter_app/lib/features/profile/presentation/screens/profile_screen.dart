import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.dio.get('/auth/me');
      setState(() { _user = res.data['data']; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ApiClient.instance.clearTokens();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.heroGradient),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: _user?['avatar_url'] != null
                    ? NetworkImage(_user!['avatar_url']) : null,
                  child: _user?['avatar_url'] == null
                    ? Text((_user?['full_name'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white))
                    : null,
                ),
                const SizedBox(height: 10),
                Text(_user?['full_name'] ?? '',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('@${_user?['username'] ?? ''}',
                  style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ]),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Stats
            Row(children: [
              _statPill('🔥 Streak', '${_user?['streak_days'] ?? 0} days'),
              const SizedBox(width: 12),
              _statPill('📅 Joined', _formatDate(_user?['created_at'])),
            ]),
            const SizedBox(height: 24),

            // Settings sections
            _Section(title: 'Account', items: [
              _SettingItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () {}),
              _SettingItem(icon: Icons.lock_outline, label: 'Change Password', onTap: () {}),
              _SettingItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
            ]).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            _Section(title: 'Learning', items: [
              _SettingItem(icon: Icons.school_outlined, label: 'My Courses', onTap: () {}),
              _SettingItem(icon: Icons.workspace_premium_outlined, label: 'Certificates', onTap: () => context.go('/certificates')),
              _SettingItem(icon: Icons.emoji_events_outlined, label: 'Achievements', onTap: () {}),
            ]).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            _Section(title: 'Preferences', items: [
              _SettingItem(
                icon: Icons.dark_mode_outlined, label: 'Dark Mode',
                trailing: Switch(
                  value: _darkMode,
                  activeColor: AppColors.brandPurple,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
              ),
            ]).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 16),

            _Section(title: 'About', items: [
              _SettingItem(icon: Icons.info_outline, label: 'App Version 1.0.0', onTap: null),
              _SettingItem(icon: Icons.privacy_tip_outlined, label: 'Privacy Policy', onTap: () {}),
            ]).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 80),
          ])),
        ),
      ]),
    );
  }

  Widget _statPill(String label, String value) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.darkBorder)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),
    ]),
  ));

  String _formatDate(String? iso) {
    if (iso == null) return '-';
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) { return '-'; }
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title, style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      Container(
        decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder)),
        child: Column(children: items.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < items.length - 1) const Divider(height: 1, color: AppColors.darkBorder),
        ])).toList()),
      ),
    ]);
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _SettingItem({required this.icon, required this.label, this.onTap, this.trailing});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.brandPurple, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.darkTextSub, size: 20) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
