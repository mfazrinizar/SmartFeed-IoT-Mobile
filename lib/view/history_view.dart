import 'package:flutter/material.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/controller/user_session_controller.dart';
import 'package:smartfeed/controller/history_controller.dart';
import 'package:smartfeed/model/history_model.dart';
import 'package:smartfeed/util/date_helper.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Chip(
          backgroundColor: AppColors.commonBackground,
          label: const Text(
            'History',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
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
          return StreamBuilder<List<HistoryModel>>(
            stream: HistoryController().historyStream(deviceId),
            builder: (context, historySnap) {
              if (!historySnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final histories = historySnap.data!;
              if (histories.isEmpty) {
                return const Center(child: Text('No feeding history yet.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.only(
                    top: 76, left: 24, right: 24, bottom: 128),
                itemCount: histories.length,
                separatorBuilder: (_, __) => const Divider(height: 8),
                itemBuilder: (context, index) {
                  final history = histories[index];
                  return Card(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        history.feedAction == 'manual'
                            ? Icons.touch_app
                            : Icons.schedule,
                        color: history.feedAction == 'manual'
                            ? AppColors.fabBackground
                            : AppColors.scaffoldBackground,
                        size: 32,
                      ),
                      title: Text(
                        history.feedAction == 'manual'
                            ? 'Manual Feeding'
                            : 'Scheduled Feeding',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                      subtitle: Text(
                        'Feed Level: ${history.feedLevel}%\n'
                        'Time: ${DateHelper.formatDateTime(history.triggeredAt)}',
                        style: TextStyle(color: Colors.white, fontSize: 14),
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
