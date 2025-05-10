import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createTestRecords() async {
  final firestore = FirebaseFirestore.instance;

  // 1. User
  final userRef = firestore.collection('users').doc('random-user-id-12345');
  await userRef.set({
    'name': '',
    'email': 'example@gmail.com',
    'linkedDeviceId': 'smartfeed_01',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 1.1. Device Token
  await userRef.collection('device_tokens').doc('token1').set({
    'token': 'sample_token_123',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // 2. Device
  final deviceRef = firestore.collection('devices').doc('smartfeed_01');
  await deviceRef.set({
    'name': 'Test Device',
    'feedLevel': 75,
    'feedingSchedule': [Timestamp.now(), Timestamp.now()],
    'foodLevelThreshold': 20,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // 2.1. Device Users
  await deviceRef.collection('users').doc('random-user-id-12345').set({
    'notificationsEnabled': true,
  });

  // 2.2. Histories
  await deviceRef.collection('histories').doc('history1').set({
    'feedLevel': 75,
    'feedAction': 'manual',
    'triggeredAt': FieldValue.serverTimestamp(),
  });

  // 2.3. Notifications
  await deviceRef.collection('notifications').doc('notif1').set({
    'title': 'Low Feed Level',
    'message': 'Feed level is below threshold: 20%.',
    'createdAt': FieldValue.serverTimestamp(),
  });
}
