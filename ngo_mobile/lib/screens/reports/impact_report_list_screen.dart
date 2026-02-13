import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import 'impact_report_detail_screen.dart';
import '../../models/impact_report.dart';
import '../shared/ui_helpers.dart';

class ImpactReportListScreen extends StatefulWidget {
  const ImpactReportListScreen({super.key});

  @override
  State<ImpactReportListScreen> createState() => _ImpactReportListScreenState();
}

class _ImpactReportListScreenState extends State<ImpactReportListScreen> {
  static const Color _primary = Color(0xFF0FB37D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final reportProvider = context.read<ReportProvider>();
      final projectProvider = context.read<ProjectProvider>();
      _loadInitialData(authProvider, reportProvider, projectProvider);
    });
  }

  Future<void> _loadInitialData(
    AuthProvider authProvider,
    ReportProvider reportProvider,
    ProjectProvider projectProvider,
  ) async {
    final token = authProvider.token;
    if (token == null || reportProvider.loading || reportProvider.reports.isNotEmpty) {
      return;
    }
    final isAdmin = (authProvider.user?.role ?? '').toUpperCase() == 'ADMIN';
    if (projectProvider.projects.isEmpty && !projectProvider.loading) {
      await projectProvider.loadProjects(
        token,
        userId: isAdmin ? null : authProvider.user?.id,
      );
    }
    final allowedProjectIds = isAdmin
        ? null
        : projectProvider.projects.map((p) => p.id).whereType<int>().toSet();
    await reportProvider.loadReports(
      token,
      allowedProjectIds: allowedProjectIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sidePad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Rapports d\'Impact'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: AnimatedPageEntrance(
        child: Consumer<ReportProvider>(
          builder: (context, reportProvider, _) {
          if (reportProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (reportProvider.reports.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 12),
                child: _buildSummaryCard(reportProvider.reports.length),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, sidePad),
                  itemCount: reportProvider.reports.length,
                  itemBuilder: (context, index) {
                    final report = reportProvider.reports[index];
                    return _ReportListItem(report: report);
                  },
                ),
              ),
            ],
          );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-report');
        },
        backgroundColor: _primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(int total) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0FB37D), Color(0xFF0FB37D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rapports collectés',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$total rapports',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7ECEF)),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assessment_outlined, color: _primary, size: 40),
            SizedBox(height: 12),
            Text(
              'Aucun rapport enregistré',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportListItem extends StatelessWidget {
  final ImpactReport report;
  static const Color _primary = Color(0xFF0FB37D);

  const _ReportListItem({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _primary.withAlpha(32),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.assessment_outlined, color: _primary),
        ),
        title: Text(
          report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (report.projectName != null && report.projectName!.isNotEmpty)
                Text(
                  report.projectName!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (report.projectId > 0)
                Text(
                  'Projet #${report.projectId}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
                ),
              Text(
                '${report.beneficiariesCount} bénéficiaires',
                style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(report.date),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImpactReportDetailScreen(report: report),
            ),
          );
        },
      ),
    );
  }
}
