import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../models/impact_report.dart';
import '../../models/project.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';
import '../../services/upload_service.dart';
import '../../services/location_service.dart';
import '../../providers/report_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../shared/grouped_image_preview.dart';
import '../shared/ui_helpers.dart';

class AddImpactReportScreen extends StatefulWidget {
  final List<Project> projects;

  const AddImpactReportScreen({super.key, this.projects = const []});

  @override
  State<AddImpactReportScreen> createState() => _AddImpactReportScreenState();
}

class _AddImpactReportScreenState extends State<AddImpactReportScreen> {
  static const Color _primary = Color(0xFF0FB37D);
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _beneficiariesController = TextEditingController();
  final _activitiesController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  late List<Project> _projects;

  final ImagePicker _picker = ImagePicker();
  final List<XFile> _photos = [];
  double? _gpsLat;
  double? _gpsLng;

  Project? _selectedProject;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _projects = widget.projects.isNotEmpty
        ? widget.projects
        : Provider.of<ProjectProvider>(context, listen: false).projects;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _beneficiariesController.dispose();
    _activitiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1280,
    );
    if (image != null) {
      setState(() {
        _photos.add(image);
      });
    }
  }

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final reportProvider = context.read<ReportProvider>();

    final coords = await LocationService.getCurrentCoords();
    if (coords != null) {
      _gpsLat = coords.lat;
      _gpsLng = coords.lng;
    }
    if (!mounted) return;

    final List<String> photoUrls = [];
    if (_photos.isNotEmpty) {
      try {
        for (final photo in _photos) {
          final url = await UploadService.uploadImageFile(File(photo.path));
          photoUrls.add(url);
        }
      } catch (_) {
        final offlineReport = ImpactReport(
          projectId: _selectedProject!.id!,
          projectName: _selectedProject!.name,
          title: _titleController.text,
          description: _descriptionController.text,
          beneficiariesCount: int.parse(_beneficiariesController.text),
          activitiesDone: _activitiesController.text,
          photos: _photos.map((p) => p.path).toList(),
          gpsLat: _gpsLat,
          gpsLng: _gpsLng,
          date: _selectedDate,
        );
        await SyncService.queueImpactReport(offlineReport);
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Upload indisponible. Rapport enregistré hors-ligne.",
            ),
          ),
        );
        return;
      }
    }

    final report = ImpactReport(
      projectId: _selectedProject!.id!,
      projectName: _selectedProject!.name,
      title: _titleController.text,
      description: _descriptionController.text,
      beneficiariesCount: int.parse(_beneficiariesController.text),
      activitiesDone: _activitiesController.text,
      photos: photoUrls,
      gpsLat: _gpsLat,
      gpsLng: _gpsLng,
      date: _selectedDate,
    );

    try {
      final success = await _apiService.addImpactReport(report);
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
          await reportProvider.loadReports(
            token,
            allowedProjectIds: allowedProjectIds,
          );
        }

        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(content: Text("Rapport créé avec succès !")),
        );
      } else if (mounted) {
        await SyncService.queueImpactReport(report);
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "Connexion indisponible. Rapport enregistré hors-ligne.",
            ),
          ),
        );
      }
    } catch (e) {
      await SyncService.queueImpactReport(report);
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Problème de connexion. Rapport enregistré hors-ligne.",
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
        title: const Text('Créer un Rapport'),
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
                key: ValueKey<int?>(_selectedProject?.id),
                initialValue: _selectedProject,
                isExpanded: true,
                hint: const Text(
                  'Sélectionner un projet',
                  overflow: TextOverflow.ellipsis,
                ),
                items: _projects
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          p.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                selectedItemBuilder: (context) => _projects
                    .map(
                      (p) => Text(
                        p.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                    .toList(),
                onChanged: (p) => setState(() => _selectedProject = p),
                validator: (v) => v == null ? 'Veuillez sélectionner un projet' : null,
                decoration: _inputDecoration('Projet', Icons.folder_outlined),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Titre du Rapport', Icons.title),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _inputDecoration('Description', Icons.description_outlined),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _beneficiariesController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration('Nombre de Bénéficiaires', Icons.people_outline),
                validator: (v) {
                  if (v!.isEmpty) return 'Requis';
                  if (int.tryParse(v) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _activitiesController,
                maxLines: 3,
                decoration: _inputDecoration('Activités Réalisées', Icons.checklist_outlined),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
                ],
              ),
              ),
              const SizedBox(height: 16),
              _buildSectionTitle('Photos', Icons.photo_library_outlined),
              const SizedBox(height: 10),
              _PhotosCard(
                photos: _photos,
                onAdd: _addPhoto,
                onRemove: (index) => setState(() => _photos.removeAt(index)),
              ),
              const SizedBox(height: 8),
              if (_gpsLat != null && _gpsLng != null)
                _GpsInfo(lat: _gpsLat!, lng: _gpsLng!),
              const SizedBox(height: 24),
              _buildSectionTitle('Date', Icons.calendar_today_outlined),
              const SizedBox(height: 10),
              _buildSoftCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date du Rapport'),
                  subtitle: Text(_selectedDate.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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
                    : const Text(
                        'Créer le Rapport',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
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
              'Nouveau rapport',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Documentez vos résultats de terrain',
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

class _PhotosCard extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const _PhotosCard({
    required this.photos,
    required this.onAdd,
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
                  'Photos terrain',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_a_photo, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GroupedImagePreview(
              images: photos.map((p) => p.path).toList(growable: false),
              emptyText: 'Aucune photo ajoutée',
              onRemove: onRemove,
            ),
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
