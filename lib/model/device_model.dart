import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final double feedLevel;
  final List<DateTime> feedingSchedule;
  final double foodLevelThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.feedLevel,
    required this.feedingSchedule,
    required this.foodLevelThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromMap(String id, Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return DeviceModel(
      id: id,
      name: data['name'] ?? '',
      feedLevel: parseDouble(data['feedLevel']),
      feedingSchedule: (data['feedingSchedule'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      foodLevelThreshold: parseDouble(data['foodLevelThreshold']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
