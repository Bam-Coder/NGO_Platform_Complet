import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import 'project_detail_screen.dart';
import '../shared/ui_helpers.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  String _searchQuery = '';
  static const Color _primary = Color(0xFF0FB37D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        final isAdmin =
            (authProvider.user?.role ?? '').toUpperCase() == 'ADMIN';
        Provider.of<ProjectProvider>(context, listen: false)
            .loadProjects(authProvider.token!,
                userId: isAdmin ? null : authProvider.user?.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sidePad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    final projectProvider = Provider.of<ProjectProvider>(context);

    // Filtrer les projets
    final filteredProjects = projectProvider.projects
        .where((project) =>
            project.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            project.location.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('Mes Projets'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: AnimatedPageEntrance(
        child: Column(
          children: [
          Padding(
            padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 10),
            child: _buildSummaryCard(filteredProjects.length),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 12),
            child: _buildSearchField(),
          ),
          Expanded(
            child: projectProvider.loading
                ? const Center(child: CircularProgressIndicator())
                : filteredProjects.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, sidePad),
                        itemCount: filteredProjects.length,
                        itemBuilder: (context, index) {
                          final project = filteredProjects[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFE7ECEF)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: _primary.withAlpha(32),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.folder_outlined, color: _primary),
                              ),
                              title: Text(
                                project.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF6E7C85)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        project.location,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Color(0xFF6E7C85)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.black38),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProjectDetailScreen(project: project),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
          ],
        ),
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
              'Projets visibles',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$total projets',
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

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: const InputDecoration(
          hintText: 'Rechercher un projet...',
          hintStyle: TextStyle(color: Color(0xFF92A0A8)),
          prefixIcon: Icon(Icons.search, color: Color(0xFF6E7C85)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_outlined, color: _primary, size: 40),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isEmpty ? 'Aucun projet assigné' : 'Aucun projet trouvé',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
