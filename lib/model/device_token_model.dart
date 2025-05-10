import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceTokenModel {
  final String id;
  final String token;
  final DateTime createdAt;

  DeviceTokenModel({
    required this.id,
    required this.token,
    required this.createdAt,
  });

  factory DeviceTokenModel.fromMap(String id, Map<String, dynamic> data) {
    return DeviceTokenModel(
      id: id,
      token: data['token'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
