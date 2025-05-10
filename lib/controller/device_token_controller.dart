import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartfeed/util/secure_storage.dart';
import '../model/device_token_model.dart';

class DeviceTokenController {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> addToken(String userId, String token) async {
    final tokenRef =
        usersRef.doc(userId).collection('device_tokens').doc(token);
    await tokenRef.set({
      'token': token,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeToken(String userId) async {
    final token = await SecureStorage.getDeviceToken();
    final tokenRef =
        usersRef.doc(userId).collection('device_tokens').doc(token);
    await tokenRef.delete();
  }

  Future<List<DeviceTokenModel>> getTokens(String userId) async {
    final snapshot =
        await usersRef.doc(userId).collection('device_tokens').get();
    return snapshot.docs
        .map((doc) => DeviceTokenModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  Stream<List<DeviceTokenModel>> tokenStream(String userId) {
    return usersRef.doc(userId).collection('device_tokens').snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => DeviceTokenModel.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }
}
