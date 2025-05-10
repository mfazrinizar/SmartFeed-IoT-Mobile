import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/device_model.dart';

class DeviceController {
  final CollectionReference devicesRef =
      FirebaseFirestore.instance.collection('devices');

  Stream<DeviceModel> deviceStream(String deviceId) {
    return devicesRef.doc(deviceId).snapshots().map(
          (doc) =>
              DeviceModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        );
  }

  Future<void> updateDeviceName(String deviceId, String newName) async {
    await devicesRef
        .doc(deviceId)
        .update({'name': newName, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> setNotificationEnabled(
      String deviceId, String userId, bool enabled) async {
    await devicesRef.doc(deviceId).collection('users').doc(userId).set({
      'notificationsEnabled': enabled,
    }, SetOptions(merge: true));
  }

  Future<void> triggerManualFeed(String deviceId, double feedLevel) async {
    await devicesRef.doc(deviceId).collection('histories').add({
      'feedLevel': feedLevel,
      'feedAction': 'manual',
      'triggeredAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFoodLevelThreshold(
      String deviceId, double newThreshold) async {
    await devicesRef.doc(deviceId).update({
      'foodLevelThreshold': newThreshold,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFeedingSchedule(
      String deviceId, List<DateTime> newSchedule) async {
    await devicesRef.doc(deviceId).update({
      'feedingSchedule':
          newSchedule.map((dt) => Timestamp.fromDate(dt)).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
