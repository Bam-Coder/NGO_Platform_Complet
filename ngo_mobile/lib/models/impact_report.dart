import '../core/media_url.dart';

class ImpactReport {
  final int? id;
  final int projectId;
  final String? projectName;
  final String title;
  final String description;
  final int beneficiariesCount;
  final String activitiesDone;
  final List<String> photos;
  final double? gpsLat;
  final double? gpsLng;
  final DateTime date;
  final bool? verified;

  ImpactReport({
    this.id,
    required this.projectId,
    this.projectName,
    required this.title,
    required this.description,
    required this.beneficiariesCount,
    required this.activitiesDone,
    this.photos = const [],
    this.gpsLat,
    this.gpsLng,
    required this.date,
    this.verified = false,
  });

  factory ImpactReport.fromJson(Map<String, dynamic> json) {
    // Safe type conversion helpers
    double safeDouble(dynamic value) => value is String ? (double.tryParse(value) ?? 0.0) : (value as num? ?? 0).toDouble();
    int safeInt(dynamic value) => value is String ? (int.tryParse(value) ?? 0) : (value as num? ?? 0).toInt();

    final project = json['project'];
    final projectIdValue = json['projectId'] ?? (project is Map ? project['id'] : null);
    final projectNameValue = project is Map ? project['name'] : null;

    return ImpactReport(
      id: json['id'] != null ? safeInt(json['id']) : null,
      projectId: safeInt(projectIdValue),
      projectName: projectNameValue is String ? projectNameValue : null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      beneficiariesCount: safeInt(json['beneficiariesCount']),
      activitiesDone: json['activitiesDone'] ?? json['activities'] ?? '',
      photos: normalizeMediaUrls(json['photos'] as List?),
      gpsLat: json['gpsLat'] != null ? safeDouble(json['gpsLat']) : null,
      gpsLng: json['gpsLng'] != null ? safeDouble(json['gpsLng']) : null,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId, // Added projectId
      'title': title,
      'description': description,
      'beneficiariesCount': beneficiariesCount,
      'activitiesDone': activitiesDone,
      'photos': photos,
      'gpsLat': gpsLat,
      'gpsLng': gpsLng,
      'date': date.toIso8601String().substring(0, 10),
    };
  }
}
