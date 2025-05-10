class DeviceUserModel {
  final String id;
  final bool notificationsEnabled;

  DeviceUserModel({
    required this.id,
    required this.notificationsEnabled,
  });

  factory DeviceUserModel.fromMap(String id, Map<String, dynamic> data) {
    return DeviceUserModel(
      id: id,
      notificationsEnabled: data['notificationsEnabled'] ?? false,
    );
  }
}
