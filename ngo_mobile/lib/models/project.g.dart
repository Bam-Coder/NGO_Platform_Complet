// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
      id: _intFromJsonNullable(json['id']),
      name: _stringFromJsonAllowNull(json['name']),
      description: _stringFromJsonAllowNull(json['description']),
      location: _stringFromJsonAllowNull(json['location']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      budgetTotal: _doubleFromJsonAllowNull(json['budgetTotal']),
      currency: json['currency'] == null
          ? 'USD'
          : _currencyFromJsonAllowNull(json['currency']),
      managerId: _managerIdFromJson(json['managerId']),
      donorIds: _intListFromJson(json['donorIds']),
      donors: _donorListFromJson(json['donors']),
      status: json['status'] == null
          ? ProjectStatus.planned
          : _projectStatusFromJson(json['status']),
      budgets: (json['budgets'] as List<dynamic>?)
          ?.map((e) => Budget.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'location': instance.location,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'budgetTotal': instance.budgetTotal,
      'currency': instance.currency,
      'managerId': instance.managerId,
      'donorIds': instance.donorIds,
      'donors': instance.donors,
      'status': _projectStatusToJson(instance.status),
      'budgets': instance.budgets,
    };
