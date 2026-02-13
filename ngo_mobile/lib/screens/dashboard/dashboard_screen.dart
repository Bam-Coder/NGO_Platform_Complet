import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/report_provider.dart';
import '../../models/user.dart';
import '../projects/project_detail_screen.dart';
import '../forms/add_expense_screen.dart';
import '../reports/add_impact_report_screen.dart';
import '../expenses/expense_detail_screen.dart';
import '../reports/impact_report_detail_screen.dart';
import '../shared/sync_status_widget.dart';
import '../shared/ui_helpers.dart';

const Color _brandGreen = Color(0xFF0FB37D);
const Color _navy = Color(0xFF0FB37D);
const Color _indigo = Color(0xFF0FB37D);
const Color _blue = Color(0xFFFDDD0E);
const Color _amber = Color(0xFFE66E11);
const Color _teal = Color(0xFF05A7CC);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0;
  bool _redirectedToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      _loadInitialData(
        authProvider,
        projectProvider,
        expenseProvider,
        reportProvider,
      );
    });
  }

  Future<void> _loadInitialData(
    AuthProvider authProvider,
    ProjectProvider projectProvider,
    ExpenseProvider expenseProvider,
    ReportProvider reportProvider,
  ) async {
    final token = authProvider.token;
    if (token == null) return;
    final isAdmin = (authProvider.user?.role ?? '').toUpperCase() == 'ADMIN';
    await projectProvider.loadProjects(
      token,
      userId: isAdmin ? null : authProvider.user?.id,
    );
    final allowedProjectIds = isAdmin
        ? null
        : projectProvider.projects.map((p) => p.id).whereType<int>().toSet();
    await expenseProvider.loadExpenses(token, allowedProjectIds: allowedProjectIds);
    await reportProvider.loadReports(token, allowedProjectIds: allowedProjectIds);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, User?>((p) => p.user);
    final token = context.select<AuthProvider, String?>((p) => p.token);

    if (user == null || token == null) {
      if (!_redirectedToLogin) {
        _redirectedToLogin = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
      return const Scaffold(body: SizedBox.expand());
    }

    late final Widget body;
    FloatingActionButton? fab;
    switch (_selectedTab) {
      case 0:
        body = _OverviewTab(user: user);
        break;
      case 1:
        body = const _ProjectsTab();
        break;
      case 2:
        body = const _ExpensesTab();
        fab = FloatingActionButton(
          heroTag: 'fab-expense',
          backgroundColor: _brandGreen,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddExpenseScreen(
                projects: Provider.of<ProjectProvider>(context, listen: false)
                    .projects,
              ),
            ),
          ),
          child: const Icon(Icons.add),
        );
        break;
      case 3:
        body = const _ReportsTab();
        fab = FloatingActionButton(
          heroTag: 'fab-report',
          backgroundColor: _brandGreen,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => AddImpactReportScreen(
                projects: Provider.of<ProjectProvider>(context, listen: false)
                    .projects,
              ),
            ),
          ),
          child: const Icon(Icons.add),
        );
        break;
      default:
        body = _OverviewTab(user: user);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        title: const Text('NGO Agent'),
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: AnimatedPageEntrance(child: body),
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        backgroundColor: Colors.white,
        selectedItemColor: _indigo,
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (index) {
          setState(() => _selectedTab = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Projets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Dépenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Rapports',
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final User? user;

  const _OverviewTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final pagePad = screenPadding(context);
    return SingleChildScrollView(
      padding: pagePad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WelcomeCard(user: user),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Actions Rapides', icon: Icons.flash_on_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  label: 'Ajouter Dépense',
                  icon: Icons.add_shopping_cart,
                  color: _amber,
                  onTap: () {
                    final projects =
                        Provider.of<ProjectProvider>(context, listen: false)
                            .projects;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => AddExpenseScreen(projects: projects),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuickAction(
                  label: 'Créer Rapport',
                  icon: Icons.post_add,
                  color: _teal,
                  onTap: () {
                    final projects =
                        Provider.of<ProjectProvider>(context, listen: false)
                            .projects;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) =>
                            AddImpactReportScreen(projects: projects),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SyncStatusWidget(),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Vue d\'ensemble', icon: Icons.insights_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Selector<ProjectProvider, int>(
                  selector: (context, p) => p.projects.length,
                  builder: (context, count, child) => _StatCard(
                    label: 'Projets',
                    value: count.toString(),
                    icon: Icons.folder,
                    color: _blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Selector<ExpenseProvider, int>(
                  selector: (context, p) => p.expenses.length,
                  builder: (context, count, child) => _StatCard(
                    label: 'Dépenses',
                    value: count.toString(),
                    icon: Icons.receipt,
                    color: _amber,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Selector<ReportProvider, int>(
                  selector: (context, p) => p.reports.length,
                  builder: (context, count, child) => _StatCard(
                    label: 'Rapports',
                    value: count.toString(),
                    icon: Icons.assessment,
                    color: _teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Projets Récents', icon: Icons.history_outlined),
          const SizedBox(height: 12),
          Consumer<ProjectProvider>(
            builder: (context, projectProvider, _) {
              if (projectProvider.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (projectProvider.projects.isEmpty) {
                return const _EmptyState(
                  message: 'Aucun projet assigné',
                  icon: Icons.folder_off,
                );
              }
              final recentCount =
                  projectProvider.projects.length > 3 ? 3 : projectProvider.projects.length;
              return Column(
                children: List.generate(recentCount, (index) {
                  final project = projectProvider.projects[index];
                  return _ModernListTile(
                    leadingIcon: Icons.folder_outlined,
                    title: project.name,
                    subtitle: project.location,
                    accentColor: _blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ProjectDetailScreen(project: project),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab();

  @override
  Widget build(BuildContext context) {
    final sidePad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, _) {
        if (projectProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (projectProvider.projects.isEmpty) {
          return const _EmptyState(
            message: 'Aucun projet assigné',
            icon: Icons.folder_off,
          );
        }
        return ListView(
          padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, sidePad),
          children: projectProvider.projects.map((project) {
            final statusLabel = project.status.toString().split('.').last;
            return _ModernListTile(
              leadingIcon: Icons.folder_outlined,
              title: project.name,
              subtitle: project.location,
              accentColor: _blue,
              trailing: _StatusBadge(statusLabel: statusLabel),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ProjectDetailScreen(project: project),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ExpensesTab extends StatelessWidget {
  const _ExpensesTab();

  @override
  Widget build(BuildContext context) {
    final sidePad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, _) {
        if (expenseProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (expenseProvider.expenses.isEmpty) {
          return const _EmptyState(
            message: 'Aucune dépense enregistrée',
            icon: Icons.receipt,
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, sidePad),
          itemCount: expenseProvider.expenses.length,
          itemBuilder: (context, index) {
            final expense = expenseProvider.expenses[index];
            return _ModernListTile(
              leadingIcon: Icons.receipt_long_outlined,
              title: expense.description,
              subtitle: '${expense.amount.toStringAsFixed(0)} FCFA',
              accentColor: _amber,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ExpenseDetailScreen(expense: expense),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    final sidePad = MediaQuery.sizeOf(context).width < 360 ? 12.0 : 16.0;
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, _) {
        if (reportProvider.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reportProvider.reports.isEmpty) {
          return const _EmptyState(
            message: 'Aucun rapport créé',
            icon: Icons.assessment,
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, sidePad),
          itemCount: reportProvider.reports.length,
          itemBuilder: (context, index) {
            final report = reportProvider.reports[index];
            return _ModernListTile(
              leadingIcon: Icons.assessment_outlined,
              title: report.title,
              subtitle: '${report.beneficiariesCount} bénéficiaires',
              accentColor: _teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ImpactReportDetailScreen(report: report),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final User? user;

  const _WelcomeCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName = user?.email.split('@')[0].toUpperCase() ?? 'AGENT';
    final role = user?.role ?? 'Agent';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _indigo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F172A),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withAlpha(48),
                child: const Icon(Icons.person_outline, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Rôle: $role',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Bienvenue, $displayName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tableau de pilotage terrain',
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE7ECEF)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, size: 40, color: _indigo),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _indigo),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ModernListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ModernListTile({
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
    this.trailing,
  });

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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: accentColor.withAlpha(32),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(leadingIcon, color: accentColor),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF6E7C85)),
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String statusLabel;

  const _StatusBadge({required this.statusLabel});

  @override
  Widget build(BuildContext context) {
    final tone = _getStatusColor(statusLabel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: tone.withAlpha(26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withAlpha(77)),
      ),
      child: Text(
        statusLabel,
        style: TextStyle(color: tone, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'active':
    case 'actif':
      return Colors.green;
    case 'planned':
    case 'planifié':
      return Colors.blue;
    case 'paused':
    case 'en pause':
      return Colors.orange;
    case 'completed':
    case 'complété':
      return Colors.grey;
    case 'cancelled':
    case 'annulé':
      return Colors.red;
    default:
      return Colors.grey;
  }
}
