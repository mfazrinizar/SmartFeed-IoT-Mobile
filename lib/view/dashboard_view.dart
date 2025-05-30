import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/controller/user_session_controller.dart';
import 'package:smartfeed/controller/device_controller.dart';
import 'package:smartfeed/controller/notification_controller.dart';
import 'package:smartfeed/controller/history_controller.dart';
import 'package:smartfeed/model/device_model.dart';
import 'package:smartfeed/model/notification_model.dart';
import 'package:smartfeed/model/history_model.dart';
import 'package:smartfeed/util/date_helper.dart';
import 'package:smartfeed/view/widget/blinking_warning_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Chip(
          backgroundColor: AppColors.commonBackground,
          label: const Text(
            'Dashboard',
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
          return StreamBuilder<DeviceModel>(
            stream: DeviceController().deviceStream(deviceId),
            builder: (context, deviceSnap) {
              if (!deviceSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final device = deviceSnap.data!;
              return StreamBuilder<List<HistoryModel>>(
                stream: HistoryController().historyStream(deviceId),
                builder: (context, historySnap) {
                  DateTime? lastFed;
                  if (historySnap.hasData && historySnap.data!.isNotEmpty) {
                    lastFed = historySnap.data!.first.triggeredAt;
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                        top: height * 0.125, left: 24, right: 24, bottom: 128),
                    child: Column(
                      children: [
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          color: AppColors.primary,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      radius: 24,
                                      child: Image.asset(
                                        'assets/logo/logo_no-bg.png',
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        device.name,
                                        style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Icon(Icons.restaurant,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: device.feedLevel / 100,
                                        minHeight: 16,
                                        backgroundColor: AppColors.secondary,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          device.feedLevel <=
                                                  device.foodLevelThreshold
                                              ? AppColors.commonError
                                              : AppColors.fabBackground,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${device.feedLevel}%',
                                      style: TextStyle(
                                        color: device.feedLevel <=
                                                device.foodLevelThreshold
                                            ? AppColors.commonError
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Threshold: ${device.foodLevelThreshold}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 20),
                                      onPressed: () async {
                                        final controller =
                                            TextEditingController(
                                                text: device.foodLevelThreshold
                                                    .toString());
                                        final result = await showDialog<double>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text(
                                                'Edit Food Level Threshold'),
                                            content: TextField(
                                              controller: controller,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              decoration: const InputDecoration(
                                                labelText: 'Threshold (%)',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  final value = double.tryParse(
                                                      controller.text);
                                                  if (value != null) {
                                                    Navigator.pop(
                                                        context, value);
                                                  }
                                                },
                                                child: const Text('Save'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (result != null) {
                                          await DeviceController()
                                              .updateFoodLevelThreshold(
                                                  device.id, result);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.schedule,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 4,
                                        runSpacing: 4,
                                        children: device.feedingSchedule
                                            .map(
                                              (dt) => Chip(
                                                color: WidgetStateProperty
                                                    .resolveWith((states) {
                                                  return Colors.white;
                                                }),
                                                backgroundColor: Colors.white,
                                                label: Text(
                                                  DateHelper.formatTimeOfDay(
                                                      TimeOfDay.fromDateTime(
                                                          dt)),
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white, size: 20),
                                      onPressed: () async {
                                        final List<DateTime> newSchedule =
                                            List.from(device.feedingSchedule);
                                        final controllerList = newSchedule
                                            .map(
                                              (dt) => TextEditingController(
                                                text:
                                                    DateHelper.formatTimeOfDay(
                                                  TimeOfDay.fromDateTime(dt),
                                                ),
                                              ),
                                            )
                                            .toList();

                                        await showDialog(
                                          context: context,
                                          builder: (context) => StatefulBuilder(
                                            builder: (context, setState) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Edit Feeding Schedule'),
                                                content: SizedBox(
                                                  width: 300,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ...List.generate(
                                                          newSchedule.length,
                                                          (i) {
                                                        return Row(
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    controllerList[
                                                                        i],
                                                                readOnly: true,
                                                                onTap:
                                                                    () async {
                                                                  final picked =
                                                                      await showTimePicker(
                                                                    context:
                                                                        context,
                                                                    initialTime:
                                                                        TimeOfDay.fromDateTime(
                                                                            newSchedule[i]),
                                                                  );
                                                                  if (picked !=
                                                                      null) {
                                                                    final now =
                                                                        DateTime
                                                                            .now();
                                                                    final dt =
                                                                        DateTime(
                                                                      now.year,
                                                                      now.month,
                                                                      now.day,
                                                                      picked
                                                                          .hour,
                                                                      picked
                                                                          .minute,
                                                                    );
                                                                    setState(
                                                                        () {
                                                                      newSchedule[
                                                                          i] = dt;
                                                                      controllerList[i]
                                                                              .text =
                                                                          DateHelper.formatTimeOfDay(
                                                                              picked);
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                  Icons.delete,
                                                                  size: 20),
                                                              onPressed: () {
                                                                setState(() {
                                                                  newSchedule
                                                                      .removeAt(
                                                                          i);
                                                                  controllerList
                                                                      .removeAt(
                                                                          i);
                                                                });
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      }),
                                                      TextButton.icon(
                                                        icon: const Icon(
                                                            Icons.add),
                                                        label: const Text(
                                                            'Add Time'),
                                                        onPressed: () async {
                                                          final picked =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialTime:
                                                                TimeOfDay.now(),
                                                          );
                                                          if (picked != null) {
                                                            final now =
                                                                DateTime.now();
                                                            final dt = DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              picked.hour,
                                                              picked.minute,
                                                            );
                                                            setState(() {
                                                              newSchedule
                                                                  .add(dt);
                                                              controllerList.add(
                                                                  TextEditingController(
                                                                      text: DateHelper
                                                                          .formatTimeOfDay(
                                                                              picked)));
                                                            });
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, newSchedule);
                                                    },
                                                    child: const Text('Save'),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        );
                                        if (newSchedule.isNotEmpty &&
                                            (newSchedule.length !=
                                                    device.feedingSchedule
                                                        .length ||
                                                !DateHelper.listEquals(
                                                    newSchedule,
                                                    device.feedingSchedule))) {
                                          await DeviceController()
                                              .updateFeedingSchedule(
                                                  device.id, newSchedule);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.history,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Fed: ',
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                    Text(
                                      lastFed != null
                                          ? DateHelper.formatDateTime(lastFed)
                                          : 'Never',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Center(
                                    child: Center(
                                  child: _FeedCountdownButton(
                                    lastFed: lastFed,
                                    feedLevel: device.feedLevel,
                                    deviceId: deviceId,
                                    isRefillNeeded: device.feedLevel == 0,
                                  ),
                                )),
                                if (device.feedLevel <=
                                    device.foodLevelThreshold)
                                  const BlinkingWarningView(
                                    text: 'Needs refill!',
                                    color: AppColors.commonError,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Notifications',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                StreamBuilder<List<NotificationModel>>(
                                  stream: NotificationController()
                                      .notificationStream(deviceId),
                                  builder: (context, notifSnapshot) {
                                    if (!notifSnapshot.hasData) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    final notifications = notifSnapshot.data!;
                                    if (notifications.isEmpty) {
                                      return const Text(
                                          'No notifications yet.');
                                    }
                                    return Column(
                                      children:
                                          notifications.take(3).map((notif) {
                                        return ListTile(
                                          leading: const Icon(
                                              Icons.notifications,
                                              color: AppColors.primary),
                                          title: Text(
                                            notif.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(notif.message),
                                                Text(
                                                  "${notif.createdAt.year}-${notif.createdAt.day}-${notif.createdAt.month} ${notif.createdAt.hour}:${notif.createdAt.minute.toString().padLeft(2, '0')}",
                                                  style: TextStyle(
                                                    color: Colors.blueGrey,
                                                    fontSize: 13,
                                                  ),
                                                )
                                              ]),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

class _FeedCountdownButton extends StatefulWidget {
  final DateTime? lastFed;
  final double feedLevel;
  final String deviceId;
  final bool isRefillNeeded;

  const _FeedCountdownButton({
    required this.lastFed,
    required this.feedLevel,
    required this.deviceId,
    required this.isRefillNeeded,
  });

  @override
  State<_FeedCountdownButton> createState() => _FeedCountdownButtonState();
}

class _FeedCountdownButtonState extends State<_FeedCountdownButton> {
  late int _secondsLeft;
  Timer? _timer;
  bool _isFeeding = false;
  bool _justClicked = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _calcSecondsLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final newSecondsLeft = _calcSecondsLeft();
      if (newSecondsLeft != _secondsLeft) {
        setState(() => _secondsLeft = newSecondsLeft);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int _calcSecondsLeft() {
    if (widget.lastFed == null) return -1;
    final s = 60 - DateTime.now().difference(widget.lastFed!).inSeconds;
    return s > 0 ? s : 0;
  }

  bool get _canFeed =>
      !_isFeeding && _secondsLeft == 0 && !widget.isRefillNeeded;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.fabBackground,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: Image.asset(
          'assets/logo/logo_no-bg.png',
          width: 64,
          height: 64,
        ),
      ),
      label: _canFeed || _secondsLeft == -1
          ? const Text(
              'Feed Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          : widget.isRefillNeeded
              ? Text(
                  'No Food!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.commonError,
                  ),
                )
              : Text(
                  'Feed in ${_secondsLeft}s',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      onPressed: _canFeed && !_justClicked
          ? () async {
              try {
                if (_canFeed && !_justClicked) {
                  _justClicked = true;

                  _isFeeding = true;

                  await DeviceController().triggerManualFeed(
                    widget.deviceId,
                    widget.feedLevel,
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Manual feeding triggered successfully!'),
                        backgroundColor: AppColors.commonSuccess,
                      ),
                    );
                  }
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Failed to feed manually. Wait and please try again.'),
                      backgroundColor: AppColors.commonError,
                    ),
                  );
                }
              } finally {
                _isFeeding = false;
                _justClicked = false;
              }
            }
          : null,
    );
  }
}
