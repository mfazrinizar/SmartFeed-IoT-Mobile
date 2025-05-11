import 'package:flutter/material.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/controller/user_session_controller.dart';
import 'package:smartfeed/controller/notification_controller.dart';
import 'package:smartfeed/model/notification_model.dart';
import 'package:smartfeed/util/date_helper.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.commonBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        title:
            const Text('Notifications', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<String?>(
        future: UserSessionController.getLinkedDeviceId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final deviceId = snapshot.data;
          if (deviceId == null || deviceId.isEmpty) {
            return const Center(
                child: Text('No device linked to your account.'));
          }
          return StreamBuilder<List<NotificationModel>>(
            stream: NotificationController().notificationStream(deviceId),
            builder: (context, notifSnapshot) {
              if (!notifSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final notifications = notifSnapshot.data!;
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  return Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: AppColors.appBarBackground,
                        size: 32,
                      ),
                      title: Text(
                        notif.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        '${notif.message}\n'
                        '${DateHelper.formatDateTime(notif.createdAt)}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
