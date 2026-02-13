import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/project_provider.dart';
import 'expense_detail_screen.dart';
import '../../models/expense.dart';
import '../shared/ui_helpers.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  static const Color _primary = Color(0xFF0FB37D);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final expenseProvider = context.read<ExpenseProvider>();
      final projectProvider = context.read<ProjectProvider>();
      _loadInitialData(authProvider, expenseProvider, projectProvider);
    });
  }

  Future<void> _loadInitialData(
    AuthProvider authProvider,
    ExpenseProvider expenseProvider,
    ProjectProvider projectProvider,
  ) async {
    final token = authProvider.token;
    if (token == null || expenseProvider.loading || expenseProvider.expenses.isNotEmpty) {
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
    await expenseProvider.loadExpenses(
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
        title: const Text('Mes Dépenses'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: AnimatedPageEntrance(
        child: Consumer<ExpenseProvider>(
          builder: (context, expenseProvider, _) {
          if (expenseProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (expenseProvider.expenses.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 12),
                child: _buildSummaryCard(expenseProvider.expenses.length),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, sidePad),
                  itemCount: expenseProvider.expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenseProvider.expenses[index];
                    return _ExpenseListItem(expense: expense);
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
          // Naviguer vers AddExpenseScreen
          Navigator.pushNamed(context, '/add-expense');
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x22009639),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total des dépenses',
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '$total enregistrements',
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
            Icon(Icons.receipt_long_outlined, color: _primary, size: 40),
            SizedBox(height: 12),
            Text(
              'Aucune dépense enregistrée',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListItem extends StatelessWidget {
  final Expense expense;
  static const Color _primary = Color(0xFF0FB37D);

  const _ExpenseListItem({required this.expense});

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
          child: const Icon(Icons.receipt_long_outlined, color: _primary),
        ),
        title: Text(
          expense.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (expense.projectName != null && expense.projectName!.isNotEmpty)
                Text(
                  expense.projectName!,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else if (expense.projectId > 0)
                Text(
                  'Projet #${expense.projectId}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF6E7C85)),
                ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd/MM/yyyy').format(expense.date),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${expense.amount.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _primary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.chevron_right, color: Colors.black38),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExpenseDetailScreen(expense: expense),
            ),
          );
        },
      ),
    );
  }
}
