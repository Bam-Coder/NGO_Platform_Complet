import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseRepository {
  final ApiService apiService;

  ExpenseRepository({ApiService? apiService}) : apiService = apiService ?? ApiService();

  Future<List<Expense>> fetchExpenses(String token) async {
    final response = await apiService.get('/expenses', token: token);
    if (response is List) {
      return response.map((json) => Expense.fromJson(json as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<bool> addExpense(Expense expense, String token) async {
    return apiService.addExpense(expense, token: token);
  }
}
