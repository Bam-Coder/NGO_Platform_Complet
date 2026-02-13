import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/expense.dart';
import '../../models/project.dart';
import '../../models/budget.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';
import '../../services/upload_service.dart';
import '../../services/location_service.dart';
import '../../providers/expense_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/grouped_image_preview.dart';
import '../shared/ui_helpers.dart';

class AddExpenseScreen extends StatefulWidget {
  final List<Project> projects;
  const AddExpenseScreen({super.key, required this.projects});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  static const Color _primary = Color(0xFF0FB37D);
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _isLoadingBudgets = false;
  late List<Project> _projects;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _receiptImages = [];
  double? _gpsLat;
  double? _gpsLng;

  Project? _selectedProject;
  Budget? _selectedBudget;
  List<Budget> _projectBudgets = [];
  DateTime _selectedDate = DateTime.now();

  double? _parseAmount(String input) {
    final normalized = input.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  @override
  void initState() {
    super.initState();
    // Use provided projects or load from provider
    _projects = widget.projects.isNotEmpty
        ? widget.projects
        : Provider.of<ProjectProvider>(context, listen: false).projects;
    
    if (_projects.length == 1) {
      _selectedProject = _projects.first;
      _loadBudgetsForProject(_selectedProject!.id!);
    }
  }

  void _loadBudgetsForProject(int projectId) async {
    setState(() {
      _isLoadingBudgets = true;
      _projectBudgets = [];
      _selectedBudget = null;
    });
    try {
      final budgets = await _apiService.getBudgetsForProject(projectId);
      if (!mounted) return;
      setState(() {
        _projectBudgets = budgets;
        _selectedBudget = _projectBudgets.isNotEmpty ? _projectBudgets.first : null;
      });
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() => _isLoadingBudgets = false);
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickReceiptImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (image != null) {
      setState(() {
        _receiptImages.add(image);
      });
    }
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedBudget == null) {
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner un budget.")),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final expenseProvider = context.read<ExpenseProvider>();

    final amount = _parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Montant invalide.")),
      );
      return;
    }
    setState(() => _isLoading = true);

    // Tenter de récupérer la position GPS (non bloquant fonctionnellement)
    final coords = await LocationService.getCurrentCoords();
    if (coords != null) {
      _gpsLat = coords.lat;
      _gpsLng = coords.lng;
    }
    if (!mounted) return;

    String? receiptUrl;
    if (_receiptImages.isNotEmpty) {
      try {
        final uploadedUrls = <String>[];
        for (final image in _receiptImages) {
          final url = await UploadService.uploadImageFile(File(image.path));
          uploadedUrls.add(url);
        }
        receiptUrl = Expense.encodeReceiptUrls(uploadedUrls);
      } catch (_) {
        // Upload impossible : on passe en mode offline avec le chemin local
        final localPaths = _receiptImages.map((e) => e.path).toList(growable: false);
        final offlineExpense = Expense(
          amount: amount,
          description: _descController.text,
          projectId: _selectedProject!.id!,
          projectName: _selectedProject!.name,
          budgetCategoryId: _selectedBudget!.id!,
          date: _selectedDate,
          receiptUrl: Expense.encodeReceiptUrls(localPaths),
          gpsLat: _gpsLat,
          gpsLng: _gpsLng,
        );
        await SyncService.queueExpense(offlineExpense);
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Upload indisponible. Dépense enregistrée hors-ligne.",
            ),
          ),
        );
        return;
      }
    }

    final expense = Expense(
      amount: amount,
      description: _descController.text,
      projectId: _selectedProject!.id!,
      projectName: _selectedProject!.name,
      budgetCategoryId: _selectedBudget!.id!,
      date: _selectedDate,
      receiptUrl: receiptUrl,
      gpsLat: _gpsLat,
      gpsLng: _gpsLng,
    );

    try {
      final success = await _apiService.addExpense(expense);
      if (!mounted) return;

      if (success) {
        final token = await AuthService.getSavedToken();
        if (!mounted) return;
        if (token != null) {
          final projectProvider =
              Provider.of<ProjectProvider>(context, listen: false);
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final isAdmin =
              (authProvider.user?.role ?? '').toUpperCase() == 'ADMIN';
          final allowedProjectIds = isAdmin
              ? null
              : projectProvider.projects
                  .map((p) => p.id)
                  .whereType<int>()
                  .toSet();
          await expenseProvider.loadExpenses(
            token,
            allowedProjectIds: allowedProjectIds,
          );
        }

        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text("Dépense ajoutée avec succès !")),
        );
      } else if (mounted) {
        // Échec côté API : on bascule en mode offline
        await SyncService.queueExpense(expense);
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Connexion indisponible. Dépense enregistrée hors-ligne.",
            ),
          ),
        );
      }
    } catch (e) {
      // En cas d'erreur (souvent réseau), on stocke offline
      await SyncService.queueExpense(expense);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Problème de connexion. Dépense enregistrée hors-ligne.",
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text("Ajouter une dépense"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: AnimatedPageEntrance(
        child: SingleChildScrollView(
          padding: screenPadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildSectionTitle('Informations', Icons.info_outline),
              const SizedBox(height: 10),
              _buildSoftCard(
                child: Column(
                  children: [
              DropdownButtonFormField<Project>(
                key: ValueKey<String>('project-${_selectedProject?.id}'),
                initialValue: _selectedProject,
                hint: const Text('Sélectionner un projet'),
                items: _projects.map((project) {
                  return DropdownMenuItem(value: project, child: Text(project.name));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProject = value;
                    _selectedBudget = null; // Reset budget selection
                    if (_selectedProject != null) {
                      _loadBudgetsForProject(_selectedProject!.id!);
                    }
                  });
                },
                validator: (value) => value == null ? 'Veuillez sélectionner un projet.' : null,
                decoration: _inputDecoration('Projet', Icons.folder_outlined),
              ),
              const SizedBox(height: 16),
              if (_isLoadingBudgets)
                const Center(child: CircularProgressIndicator())
              else if (_selectedProject != null)
                DropdownButtonFormField<Budget>(
                  key: ValueKey<String>('budget-${_selectedBudget?.id}'),
                  initialValue: _selectedBudget,
                  hint: const Text('Sélectionner un budget'),
                  items: _projectBudgets.map((budget) {
                    return DropdownMenuItem(value: budget, child: Text(budget.category.toString().split('.').last));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedBudget = value),
                  validator: (value) => value == null ? 'Veuillez sélectionner un budget.' : null,
                  decoration: _inputDecoration('Budget', Icons.account_balance_wallet_outlined),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: _inputDecoration("Montant (CFA)", Icons.payments_outlined),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final amount = _parseAmount(v);
                  if (amount == null || amount <= 0) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: _inputDecoration("Description", Icons.description_outlined),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
              ],
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Justificatif', Icons.receipt_long_outlined),
              const SizedBox(height: 10),
              // Photo du reçu
              _ReceiptCard(
                images: _receiptImages,
                onPick: _pickReceiptImage,
                onRemove: (index) => setState(() => _receiptImages.removeAt(index)),
              ),
              const SizedBox(height: 8),
              // Info GPS (simple indication si capturé)
              if (_gpsLat != null && _gpsLng != null)
                _GpsInfo(lat: _gpsLat!, lng: _gpsLng!),
              const SizedBox(height: 16),
              _buildSectionTitle('Date', Icons.calendar_today_outlined),
              const SizedBox(height: 10),
              _buildSoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date de la dépense'),
                  subtitle: Text(_selectedDate.toIso8601String().substring(0, 10)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Valider la dépense", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              )
              ],
            ),
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
      ),
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nouvelle dépense',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Renseignez les informations terrain',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
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
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSoftCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: child,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF6E7C85)),
      filled: true,
      fillColor: const Color(0xFFF9FBFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7ECEF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE7ECEF)),
      ),
    );
  }
}

class _ReceiptCard extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  const _ReceiptCard({
    required this.images,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Photo du reçu',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                if (images.isNotEmpty)
                  Text(
                    '${images.length} photo(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                TextButton.icon(
                  onPressed: onPick,
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Prendre'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GroupedImagePreview(
              images: images.map((e) => e.path).toList(growable: false),
              emptyText: 'Aucune photo sélectionnée',
              onRemove: onRemove,
              highlightLast: true,
            ),
            if (images.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'La dernière photo sera utilisée comme reçu.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GpsInfo extends StatelessWidget {
  final double lat;
  final double lng;

  const _GpsInfo({required this.lat, required this.lng});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Text(
        'Position capturée: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
