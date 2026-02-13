import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/project.dart';
import '../../core/enums.dart';
import '../shared/ui_helpers.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Project project;
  static const Color _primary = Color(0xFF0FB37D);

  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Détails du Projet'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: AnimatedPageEntrance(
        child: SingleChildScrollView(
          padding: screenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildHeaderCard(),
            const SizedBox(height: 20),
            _buildSectionTitle('Informations', Icons.info_outline),
            const SizedBox(height: 10),
            _buildSoftCard(
              child: Column(
                children: [
                  _buildInfoRow('Description', project.description),
                  _buildInfoRow('Localisation', project.location),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Calendrier', Icons.calendar_month_outlined),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildMiniMetricCard(
                    'Démarrage',
                    DateFormat('dd/MM/yyyy').format(project.startDate),
                    Icons.play_circle_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniMetricCard(
                    'Fin',
                    project.endDate != null
                        ? DateFormat('dd/MM/yyyy').format(project.endDate!)
                        : 'N/A',
                    Icons.stop_circle_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Budget', Icons.account_balance_wallet_outlined),
            const SizedBox(height: 10),
            _buildBudgetCard(),
            const SizedBox(height: 20),
            if (project.donors.isNotEmpty || project.donorIds.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Donateurs', Icons.volunteer_activism_outlined),
                  const SizedBox(height: 10),
                  _buildSoftCard(
                    child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: project.donors.isNotEmpty
                        ? project.donors
                            .map(
                              (d) => Chip(
                                label: Text(d.name),
                                backgroundColor:
                                    const Color(0xFF0FB37D).withAlpha(26),
                                labelStyle:
                                    const TextStyle(color: Color(0xFF0FB37D)),
                              ),
                            )
                            .toList()
                        : List.generate(
                            project.donorIds.length,
                            (index) => Chip(
                              label: Text('Donateur ${project.donorIds[index]}'),
                              backgroundColor:
                                  _primary.withAlpha(26),
                              labelStyle:
                                  const TextStyle(color: _primary),
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF0FB37D), Color(0xFF0FB37D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22009639),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusChip(project.status),
            const SizedBox(height: 12),
            Text(
              project.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    project.location,
                    style: const TextStyle(color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildSoftCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: child,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6E7C85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1F2933),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEF2F4)),
      ],
    );
  }

  Widget _buildMiniMetricCard(String label, String value, IconData icon) {
    return _buildSoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _primary, size: 18),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6E7C85),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2933),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Budget total alloué',
              style: TextStyle(
                color: Color(0xFF6E7C85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${project.budgetTotal.toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(ProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(65)),
      ),
      child: Text(
        _getStatusText(status),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return 'Planifié';
      case ProjectStatus.active:
        return 'Actif';
      case ProjectStatus.paused:
        return 'En Pause';
      case ProjectStatus.completed:
        return 'Complété';
      case ProjectStatus.cancelled:
        return 'Annulé';
    }
  }
}
