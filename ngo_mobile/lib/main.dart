import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/project_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/report_provider.dart';
import 'services/storage_service.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Hive pour le stockage
  await StorageService.init();
  // Initialiser les boxes offline (dépenses / rapports)
  await SyncService.init();
  // Initialiser les formats de date pour le français
  await initializeDateFormatting('fr_FR', null);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
