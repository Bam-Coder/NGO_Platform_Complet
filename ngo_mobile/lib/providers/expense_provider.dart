import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository repository = ExpenseRepository();
  List<Expense> expenses = [];
  bool loading = false;

  Future<void> loadExpenses(String token, {Set<int>? allowedProjectIds}) async {
    loading = true;
    notifyListeners();
    try {
      final all = await repository.fetchExpenses(token);
      if (allowedProjectIds != null && allowedProjectIds.isNotEmpty) {
        expenses =
            all.where((e) => allowedProjectIds.contains(e.projectId)).toList();
      } else {
        expenses = all;
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des dépenses: $e");
      expenses = [];
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> addExpense(Expense expense, String token) async {
    try {
      final result = await repository.addExpense(expense, token);
      if (result) {
        expenses.add(expense);
        notifyListeners();
      }
      return result;
    } catch (e) {
      debugPrint("Erreur lors de l'ajout de la dépense: $e");
      return false;
    }
  }
}
