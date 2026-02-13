import 'package:json_annotation/json_annotation.dart';
import '../core/enums.dart';

part 'budget.g.dart';

@JsonSerializable()
class Budget {
  static int _intFromJsonAllowNull(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    throw FormatException('Expected int, got $value');
  }

  static double _doubleFromJsonAllowNull(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Expected double, got $value');
  }

  static BudgetCategory _categoryFromJson(dynamic value) {
    if (value is BudgetCategory) return value;
    if (value is String) {
      final normalized = value.toLowerCase();
      for (final category in BudgetCategory.values) {
        if (category.name == normalized) return category;
      }
    }
    throw FormatException('Invalid BudgetCategory: $value');
  }

  static String _categoryToJson(BudgetCategory value) {
    final name = value.name;
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }

  final int? id;
  @JsonKey(fromJson: _intFromJsonAllowNull)
  final int projectId;
  @JsonKey(fromJson: _categoryFromJson, toJson: _categoryToJson)
  final BudgetCategory category;
  @JsonKey(fromJson: _doubleFromJsonAllowNull)
  final double allocatedAmount;
  final String? description;

  Budget({
    this.id,
    required this.projectId,
    required this.category,
    required this.allocatedAmount,
    this.description,
  });

  factory Budget.fromJson(Map<String, dynamic> json) => _$BudgetFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetToJson(this);
}
