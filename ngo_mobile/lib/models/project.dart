import 'package:json_annotation/json_annotation.dart';
import 'package:ngo_app/models/budget.dart';
import 'donor.dart';

import '../core/enums.dart';

part 'project.g.dart';

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.parse(value);
  throw FormatException('Expected int, got $value');
}

int? _intFromJsonNullable(dynamic value) {
  if (value == null) return null;
  return _intFromJson(value);
}

int? _managerIdFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    final dynamic id = value['id'];
    return _intFromJsonNullable(id);
  }
  return _intFromJsonNullable(value);
}

double _doubleFromJson(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.parse(value);
  throw FormatException('Expected double, got $value');
}

double _doubleFromJsonAllowNull(dynamic value) {
  if (value == null) return 0.0;
  return _doubleFromJson(value);
}

String _stringFromJsonAllowNull(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

String _currencyFromJsonAllowNull(dynamic value) {
  if (value == null) return 'USD';
  if (value is String && value.isNotEmpty) return value;
  return 'USD';
}

List<int> _intListFromJson(dynamic value) {
  if (value == null) return <int>[];
  if (value is List) return value.map(_intFromJson).toList();
  throw FormatException('Expected List<int>, got $value');
}

List<Donor> _donorListFromJson(dynamic value) {
  if (value == null) return <Donor>[];
  if (value is List) {
    return value
        .whereType<Map>()
        .map((e) => Donor.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
  return <Donor>[];
}

ProjectStatus _projectStatusFromJson(dynamic value) {
  if (value is ProjectStatus) return value;
  if (value is String) {
    final normalized = value.toLowerCase();
    for (final status in ProjectStatus.values) {
      if (status.name == normalized) return status;
    }
  }
  if (value == null) return ProjectStatus.planned;
  throw FormatException('Invalid ProjectStatus: $value');
}

String _projectStatusToJson(ProjectStatus status) {
  return status.name.toUpperCase();
}

@JsonSerializable()
class Project {
  @JsonKey(fromJson: _intFromJsonNullable)
  final int? id;
  @JsonKey(fromJson: _stringFromJsonAllowNull)
  final String name;
  @JsonKey(fromJson: _stringFromJsonAllowNull)
  final String description;
  @JsonKey(fromJson: _stringFromJsonAllowNull)
  final String location;
  final DateTime startDate;
  final DateTime? endDate;
  @JsonKey(fromJson: _doubleFromJsonAllowNull)
  final double budgetTotal;
  @JsonKey(fromJson: _currencyFromJsonAllowNull)
  final String currency; // Ajout du champ devise
  @JsonKey(fromJson: _managerIdFromJson)
  final int? managerId;
  @JsonKey(fromJson: _intListFromJson)
  final List<int> donorIds;
  @JsonKey(fromJson: _donorListFromJson)
  final List<Donor> donors;
  @JsonKey(fromJson: _projectStatusFromJson, toJson: _projectStatusToJson)
  final ProjectStatus status;
  final List<Budget>? budgets;

  Project({
    this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.budgetTotal,
    this.currency = 'USD', // Valeur par défaut
    this.managerId,
    required this.donorIds,
    this.donors = const [],
    this.status = ProjectStatus.planned,
    this.budgets,
  });

  factory Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
