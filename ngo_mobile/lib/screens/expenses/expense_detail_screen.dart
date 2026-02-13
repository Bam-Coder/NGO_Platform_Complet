import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/expense.dart';
import '../shared/grouped_image_preview.dart';
import '../shared/ui_helpers.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  static const Color _primary = Color(0xFF0FB37D);

  const ExpenseDetailScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final receiptUrls = Expense.decodeReceiptUrls(expense.receiptUrl);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Détails de la Dépense'),
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
            _buildInfoBlock([
              if (expense.projectName != null && expense.projectName!.isNotEmpty)
                _buildRow('Projet', expense.projectName!)
              else if (expense.projectId > 0)
                _buildRow('Projet', 'Projet #${expense.projectId}'),
              _buildRow('Description', expense.description),
              _buildRow(
                'Date',
                DateFormat('dd/MM/yyyy').format(expense.date),
              ),
              _buildRow(
                'Heure',
                DateFormat('HH:mm').format(expense.createdAt ?? expense.date),
              ),
              if (expense.budgetCategoryName != null &&
                  expense.budgetCategoryName!.isNotEmpty)
                _buildRow('Catégorie', _formatCategory(expense.budgetCategoryName!))
              else
                _buildRow('Catégorie', 'Catégorie #${expense.budgetCategoryId}'),
              _buildRow('Montant', '${expense.amount.toStringAsFixed(2)} FCFA'),
            ]),
            if (receiptUrls.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildSectionTitle('Reçu', Icons.receipt_long_outlined),
              const SizedBox(height: 10),
              _buildReceiptCard(receiptUrls),
            ],
            const SizedBox(height: 20),
            _buildSectionTitle('Statut', Icons.flag_outlined),
            const SizedBox(height: 10),
            _buildSoftCard(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildStatusChip(expense.status),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('GPS', Icons.my_location_outlined),
            const SizedBox(height: 10),
            _buildInfoBlock([
                _buildRow(
                  'Latitude',
                  expense.gpsLat != null
                      ? expense.gpsLat!.toStringAsFixed(6)
                      : 'Non capturee',
                ),
                _buildRow(
                  'Longitude',
                  expense.gpsLng != null
                      ? expense.gpsLng!.toStringAsFixed(6)
                      : 'Non capturee',
                ),
              ]),
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
                'Montant déclaré',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${expense.amount.toStringAsFixed(2)} FCFA',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('dd MMM yyyy, HH:mm', 'fr_FR')
                  .format(expense.createdAt ?? expense.date),
              style: const TextStyle(color: Colors.white70),
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

  Widget _buildInfoBlock(List<Widget> children) {
    return _buildSoftCard(
      child: Column(
        children: children,
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: child,
      ),
    );
  }

  Widget _buildReceiptCard(List<String> pathsOrUrls) {
    return _buildSoftCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: GroupedImagePreview(
          images: pathsOrUrls,
          emptyText: 'Aucun reçu',
          tileSize: 96,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildStatusChip(String? status) {
    final normalized = (status ?? 'PENDING').toUpperCase();
    late final Color color;
    late final String label;
    switch (normalized) {
      case 'APPROVED':
        color = Colors.green;
        label = 'Approuvée';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = 'Rejetée';
        break;
      default:
        color = Colors.blue;
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatCategory(String value) {
    if (value.isEmpty) return value;
    final lower = value.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }
}
