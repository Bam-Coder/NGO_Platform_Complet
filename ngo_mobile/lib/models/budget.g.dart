// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Budget _$BudgetFromJson(Map<String, dynamic> json) => Budget(
      id: (json['id'] as num?)?.toInt(),
      projectId: Budget._intFromJsonAllowNull(json['projectId']),
      category: Budget._categoryFromJson(json['category']),
      allocatedAmount: Budget._doubleFromJsonAllowNull(json['allocatedAmount']),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$BudgetToJson(Budget instance) => <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'category': Budget._categoryToJson(instance.category),
      'allocatedAmount': instance.allocatedAmount,
      'description': instance.description,
    };
