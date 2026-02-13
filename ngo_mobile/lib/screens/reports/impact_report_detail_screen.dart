import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/impact_report.dart';
import '../shared/grouped_image_preview.dart';
import '../shared/ui_helpers.dart';

class ImpactReportDetailScreen extends StatelessWidget {
  final ImpactReport report;
  static const Color _primary = Color(0xFF0FB37D);

  const ImpactReportDetailScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Détails du Rapport'),
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
            _buildSectionTitle('Description', Icons.description_outlined),
            const SizedBox(height: 10),
            _buildSoftCard(
              child: Text(
                report.description,
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF1F2933),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Impact', Icons.groups_outlined),
            const SizedBox(height: 10),
            _buildImpactCard(),
            const SizedBox(height: 20),
            _buildSectionTitle(
              'Activités Réalisées',
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 10),
            _buildSoftCard(
              child: Text(
                report.activitiesDone,
                style: const TextStyle(
                  height: 1.5,
                  color: Color(0xFF1F2933),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (report.photos.isNotEmpty) ...[
              _buildSectionTitle('Photos terrain', Icons.photo_library_outlined),
              const SizedBox(height: 10),
              _buildSoftCard(
                child: GroupedImagePreview(
                  images: report.photos,
                  emptyText: 'Aucune photo',
                  tileSize: 96,
                ),
              ),
              const SizedBox(height: 8),
            ],
            _buildSectionTitle('GPS', Icons.my_location_outlined),
            const SizedBox(height: 10),
            _buildSoftCard(
              child: Column(children: [
              _buildRow(
                'Latitude',
                report.gpsLat != null
                    ? report.gpsLat!.toStringAsFixed(6)
                    : 'Non capturee',
              ),
              _buildRow(
                'Longitude',
                report.gpsLng != null
                    ? report.gpsLng!.toStringAsFixed(6)
                    : 'Non capturee',
              ),
            ]),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Rapport d\'impact',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              report.title,
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
                const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMMM yyyy', 'fr_FR').format(report.date),
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.folder_outlined, color: Colors.white70, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    report.projectName != null && report.projectName!.isNotEmpty
                        ? report.projectName!
                        : 'Projet #${report.projectId}',
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
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
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

  Widget _buildImpactCard() {
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
              'Bénéficiaires touchés',
              style: TextStyle(
                color: Color(0xFF6E7C85),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${report.beneficiariesCount} personnes',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
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
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2933),
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

}
