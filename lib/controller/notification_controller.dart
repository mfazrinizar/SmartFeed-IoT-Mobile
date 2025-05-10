import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/notification_model.dart';

class NotificationController {
  Stream<List<NotificationModel>> notificationStream(String deviceId) {
    return FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
