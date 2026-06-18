import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/api_client.dart';
import '../../../../core/widgets/loading_widget.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({super.key});
  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> {
  List<dynamic> _certs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.dio.get('/certificates/');
      setState(() { _certs = res.data['data'] ?? []; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _download(Map<String, dynamic> cert) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${cert['cert_id']}...'), backgroundColor: AppColors.brandPurple));
    // In production: call download endpoint and open PDF
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget(message: 'Loading certificates...'));

    return Scaffold(
      appBar: AppBar(title: const Text('My Certificates')),
      body: _certs.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium_rounded, size: 80, color: AppColors.darkTextSub),
            const SizedBox(height: 16),
            Text('No certificates yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Complete a course with 70%+ to earn one.',
              style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _certs.length,
            itemBuilder: (_, i) {
              final c = _certs[i] as Map<String, dynamic>;
              return _CertCard(cert: c, onDownload: () => _download(c))
                .animate().fadeIn(delay: Duration(milliseconds: i * 100)).slideY(begin: 0.2);
            },
          ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final Map<String, dynamic> cert;
  final VoidCallback onDownload;
  const _CertCard({required this.cert, required this.onDownload});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF1A1040), Color(0xFF141829)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandGold.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppColors.brandGold.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(right: -20, top: -20, child: Container(
          width: 100, height: 100,
          decoration: BoxDecoration(color: AppColors.brandGold.withOpacity(0.05), shape: BoxShape.circle),
        )),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Certificate of Completion',
                  style: TextStyle(color: AppColors.brandGold, fontSize: 11, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(cert['course_name'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ])),
            ]),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFF2A2F52)),
            const SizedBox(height: 12),

            Text('Awarded to: ${cert['student_name']}',
              style: const TextStyle(color: AppColors.darkTextSub, fontSize: 13)),
            const SizedBox(height: 4),
            Text('Score: ${cert['final_score']?.toStringAsFixed(0)}%',
              style: const TextStyle(color: AppColors.brandGold, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('ID: ${cert['cert_id']}',
              style: const TextStyle(color: AppColors.darkTextSub, fontSize: 12)),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Download PDF'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandGold,
                  side: const BorderSide(color: AppColors.brandGold),
                  minimumSize: const Size(0, 44),
                ),
              )),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}
