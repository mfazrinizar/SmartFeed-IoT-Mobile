import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:smartfeed/controller/device_token_controller.dart';
import 'package:smartfeed/util/secure_storage.dart';
import '../model/user_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    if (credential.user != null) {
      final user = credential.user!;
      final deviceToken = await FirebaseMessaging.instance.getToken();
      final deviceTokenController = DeviceTokenController();
      if (deviceToken != null) {
        await deviceTokenController.addToken(user.uid, deviceToken);
      }
    }

    return credential.user;
  }

  Future<User?> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = credential.user;
    if (user != null) {
      await usersRef.doc(user.uid).set({
        'name': name,
        'email': email,
        'linkedDeviceId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return user;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(
      String newPassword, String currentPassword) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    }
  }

  Future<void> changeName(String userId, String newName) async {
    await usersRef.doc(userId).update({'name': newName});

    final user = _auth.currentUser;
    if (user != null && user.uid == userId) {
      await user.updateDisplayName(newName);
    }
  }

  Future<void> signOut() async {
    await DeviceTokenController().removeToken(_auth.currentUser!.uid);
    SecureStorage.clearStorage();
    await _auth.signOut();
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final doc = await usersRef.doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
