import 'dart:async';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/projects/project_list_screen.dart';
import 'screens/expenses/expense_list_screen.dart';
import 'screens/reports/impact_report_list_screen.dart';
import 'screens/reports/add_impact_report_screen.dart';
import 'screens/forms/add_expense_screen.dart';
import 'services/sync_service.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (SyncService.getPendingCount() > 0) {
        await SyncService.syncAll();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SyncService.syncAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGO Agent App',
      theme: AppTheme.burkinaTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/projects': (context) => const ProjectListScreen(),
        '/expenses': (context) => const ExpenseListScreen(),
        '/reports': (context) => const ImpactReportListScreen(),
        '/add-expense': (context) => const AddExpenseScreen(projects: []),
        '/add-report': (context) => const AddImpactReportScreen(projects: []),
      },
    );
  }
}
