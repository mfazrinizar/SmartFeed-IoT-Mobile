import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/history_model.dart';

class HistoryController {
  Stream<List<HistoryModel>> historyStream(String deviceId) {
    return FirebaseFirestore.instance
        .collection('devices')
        .doc(deviceId)
        .collection('histories')
        .orderBy('triggeredAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HistoryModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
