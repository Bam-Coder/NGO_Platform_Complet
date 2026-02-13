import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final managerIdController = TextEditingController();
  final donorIdsController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final budgetController = TextEditingController();
  final currencyController = TextEditingController(text: 'USD');
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  String _status = 'PLANNED';

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    budgetController.dispose();
    currencyController.dispose();
    managerIdController.dispose();
    donorIdsController.dispose();
    super.dispose();
  }

  void submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);

    final isAdmin = (authProvider.user?.role ?? '').toUpperCase() == 'ADMIN';
    final int managerId = isAdmin
        ? int.tryParse(managerIdController.text) ?? 0
        : authProvider.user!.id;

    if (isAdmin && managerId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager ID invalide.')),
      );
      return;
    }

    final donorIds = donorIdsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => int.tryParse(e))
        .whereType<int>()
        .toList();

    await projectProvider.addProject({
      'name': nameController.text,
      'description': descriptionController.text,
      'location': locationController.text,
      'budgetTotal': double.tryParse(budgetController.text) ?? 0,
      'currency': currencyController.text,
      'managerId': managerId,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate),
      'endDate': _endDate == null ? null : DateFormat('yyyy-MM-dd').format(_endDate!),
      'donorIds': donorIds,
      'status': _status,
    }, authProvider.token!);

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un projet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom du projet'),
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Localisation'),
                validator: (v) => v!.isEmpty ? 'Obligatoire' : null,
              ),
              TextFormField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: 'Budget Total'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: currencyController,
                decoration: const InputDecoration(labelText: 'Devise'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date de debut'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date de fin (optionnel)'),
                subtitle: Text(
                  _endDate == null
                      ? 'Aucune'
                      : DateFormat('yyyy-MM-dd').format(_endDate!),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_endDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _endDate = null),
                      ),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => _endDate = picked);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Statut'),
                items: const [
                  DropdownMenuItem(value: 'PLANNED', child: Text('PLANNED')),
                  DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                  DropdownMenuItem(value: 'PAUSED', child: Text('PAUSED')),
                  DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
                  DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'PLANNED'),
              ),
              const SizedBox(height: 12),
              if ((Provider.of<AuthProvider>(context, listen: false).user?.role ?? '').toUpperCase() == 'ADMIN')
                TextFormField(
                  controller: managerIdController,
                  decoration: const InputDecoration(labelText: 'Manager ID'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Obligatoire';
                    return int.tryParse(v) == null ? 'Invalide' : null;
                  },
                ),
              if ((Provider.of<AuthProvider>(context, listen: false).user?.role ?? '').toUpperCase() == 'ADMIN')
                const SizedBox(height: 12),
              TextFormField(
                controller: donorIdsController,
                decoration: const InputDecoration(labelText: 'Donor IDs (ex: 1,2,3)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                child: const Text('Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
