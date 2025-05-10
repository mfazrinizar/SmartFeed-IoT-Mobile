import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryModel {
  final String id;
  final double feedLevel;
  final String feedAction;
  final DateTime triggeredAt;

  HistoryModel({
    required this.id,
    required this.feedLevel,
    required this.feedAction,
    required this.triggeredAt,
  });

  factory HistoryModel.fromMap(String id, Map<String, dynamic> data) {
    double parseDouble(dynamic value) {
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return 0.0;
    }

    return HistoryModel(
      id: id,
      feedLevel: parseDouble(data['feedLevel'] ?? 0.0),
      feedAction: data['feedAction'] ?? '',
      triggeredAt: (data['triggeredAt'] as Timestamp).toDate(),
    );
  }
}
