import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final int feedLevel;
  final String feedAction;
  final DateTime triggeredAt;

  HistoryModel({
    required this.id,
    required this.feedLevel,
    required this.feedAction,
    required this.triggeredAt,
  });

  factory HistoryModel.fromMap(String id, Map<String, dynamic> data) {
    return HistoryModel(
      id: id,
      feedLevel: data['feedLevel'] ?? 0,
      feedAction: data['feedAction'] ?? '',
      triggeredAt: (data['triggeredAt'] as Timestamp).toDate(),
    );
  }
}
