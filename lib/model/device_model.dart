import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String id;
  final String name;
  final int feedLevel;
  final DateTime lastFeedTime;
  final bool needsRefill;
  final List<DateTime> feedingSchedule;
  final int foodLevelThreshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.id,
    required this.name,
    required this.feedLevel,
    required this.lastFeedTime,
    required this.needsRefill,
    required this.feedingSchedule,
    required this.foodLevelThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeviceModel.fromMap(String id, Map<String, dynamic> data) {
    return DeviceModel(
      id: id,
      name: data['name'] ?? '',
      feedLevel: data['feedLevel'] ?? 0,
      lastFeedTime: (data['lastFeedTime'] as Timestamp).toDate(),
      needsRefill: data['needsRefill'] ?? false,
      feedingSchedule: (data['feedingSchedule'] as List<dynamic>?)
              ?.map((e) => (e as Timestamp).toDate())
              .toList() ??
          [],
      foodLevelThreshold: data['foodLevelThreshold'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
