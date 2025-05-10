import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const storage = FlutterSecureStorage();

  static Future<String?> getDeviceToken() async {
    return await storage.read(key: 'device_token');
  }

  static Future<void> setDeviceToken(String deviceToken) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'device_token', value: deviceToken);
  }

  static Future<void> clearStorage() async {
    await storage.delete(key: 'device_token');
  }
}
