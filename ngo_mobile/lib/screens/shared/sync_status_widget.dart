import 'package:flutter/material.dart';

import '../../services/sync_service.dart';

/// Petit widget d'indication de synchronisation offline.
///
/// Affiche :
/// - 🟢 si tout est synchronisé
/// - 🟡 si des éléments sont en attente
/// Et propose un bouton "Synchroniser" pour lancer manuellement la sync.
class SyncStatusWidget extends StatefulWidget {
  const SyncStatusWidget({super.key});

  @override
  State<SyncStatusWidget> createState() => _SyncStatusWidgetState();
}

class _SyncStatusWidgetState extends State<SyncStatusWidget> {
  bool _isSyncing = false;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
  }

  Future<void> _refreshCount() async {
    setState(() {
      _pending = SyncService.getPendingCount();
    });
  }

  Future<void> _runSync() async {
    setState(() {
      _isSyncing = true;
    });

    final bool success = await SyncService.syncAll();
    await _refreshCount();

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Synchronisation réussie'
                : 'Aucun élément synchronisé',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPending = _pending > 0;
    final Color color = hasPending ? Colors.amber : const Color(0xFF0FB37D);
    final String label =
        hasPending ? '$_pending élément(s) à synchroniser' : 'Synchronisé';

    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: hasPending ? Colors.amber[800] : Colors.green[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _isSyncing ? null : _runSync,
              icon: _isSyncing
                  ? const SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.sync,
                      size: 18,
                    ),
              label: const Text(
                'Synchroniser',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

