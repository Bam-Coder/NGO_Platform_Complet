import '../core/enums.dart';

class Donor {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? organization;
  final DonorType type;
  final double? fundedAmount;
  final String? country;
  final String? currency;

  Donor({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.organization,
    this.type = DonorType.individual,
    this.fundedAmount,
    this.country,
    this.currency,
  });

  factory Donor.fromJson(Map<String, dynamic> json) {
    int? safeInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    double? safeDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    DonorType safeType(dynamic value) {
      if (value is DonorType) return value;
      if (value is String) {
        return DonorType.values.firstWhere(
          (e) => e.toString().split('.').last == value.toLowerCase(),
          orElse: () => DonorType.individual,
        );
      }
      return DonorType.individual;
    }

    return Donor(
      id: safeInt(json['id']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      organization: json['organization'],
      type: safeType(json['type']),
      fundedAmount: safeDouble(json['fundedAmount']),
      country: json['country'],
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'organization': organization,
      'type': type.toString().split('.').last,
      'fundedAmount': fundedAmount,
      'country': country,
      'currency': currency,
    };
  }
}
