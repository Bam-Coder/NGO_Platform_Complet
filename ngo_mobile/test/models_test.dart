import 'package:flutter_test/flutter_test.dart';
import 'package:ngo_app/models/project.dart';
import 'package:ngo_app/models/expense.dart';
import 'package:ngo_app/core/enums.dart';

void main() {
  group('Model Serialization Tests', () {
    test('Project fromJson should parse correctly', () {
      final json = {
        'id': 1,
        'name': 'Test Project',
        'description': 'Description',
        'location': 'Ouagadougou',
        'startDate': '2024-01-01',
        'endDate': '2024-12-31',
        'budgetTotal': 1000000,
        'managerId': 1,
        'donorIds': [1, 2],
        'status': 'active',
      };

      final project = Project.fromJson(json);
      
      expect(project.id, 1);
      expect(project.name, 'Test Project');
      expect(project.location, 'Ouagadougou');
      expect(project.budgetTotal, 1000000);
      expect(project.status, ProjectStatus.active);
    });

    test('Expense fromJson should parse correctly', () {
      final json = {
        'id': 1,
        'amount': 50000,
        'description': 'Transport',
        'projectId': 1,
        'budgetCategoryId': 1,
        'date': '2024-02-05',
      };

      final expense = Expense.fromJson(json);
      
      expect(expense.id, 1);
      expect(expense.amount, 50000);
      expect(expense.description, 'Transport');
      expect(expense.projectId, 1);
    });

    test('Project toJson should serialize correctly', () {
      final project = Project(
        id: 1,
        name: 'Test Project',
        description: 'Description',
        location: 'Ouagadougou',
        startDate: DateTime(2024, 1, 1),
        budgetTotal: 1000000,
        managerId: 1,
        donorIds: [1, 2],
        status: ProjectStatus.active,
      );

      final json = project.toJson();
      
      expect(json['name'], 'Test Project');
      expect(json['location'], 'Ouagadougou');
      expect(json['budgetTotal'], 1000000);
      expect(json['status'], 'active');
    });

    test('Expense toJson should serialize correctly', () {
      final expense = Expense(
        id: 1,
        amount: 50000,
        description: 'Transport',
        projectId: 1,
        budgetCategoryId: 1,
        date: DateTime(2024, 2, 5),
      );

      final json = expense.toJson();
      
      expect(json['amount'], 50000);
      expect(json['description'], 'Transport');
      expect(json['projectId'], 1);
    });
  });
}
