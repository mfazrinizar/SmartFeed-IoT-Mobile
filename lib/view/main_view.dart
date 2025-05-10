import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/view/notification_view.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  late final NotchBottomBarController _controller;
  late final PageController _pageController;
  final List<Widget> _pages = [
    DashboardView(),
    HistoryView(),
    SettingsView(),
  ];

  int maxIndex = 2;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _controller = NotchBottomBarController(index: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      extendBody: false,
      bottomNavigationBar: AnimatedNotchBottomBar(
        durationInMilliSeconds: 300,
        kIconSize: 24.0,
        kBottomRadius: 28.0,
        notchBottomBarController: _controller,
        color: AppColors.primary,
        showLabel: false,
        notchColor: AppColors.primary,
        removeMargins: false,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.dashboard_outlined,
                color: AppColors.commonBackground),
            activeItem: Icon(Icons.dashboard, color: Colors.white),
            itemLabel: 'Dashboard',
          ),
          BottomBarItem(
            inActiveItem:
                Icon(Icons.history, color: AppColors.commonBackground),
            activeItem: Icon(Icons.history, color: Colors.white),
            itemLabel: 'History',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.settings_outlined,
                color: AppColors.commonBackground),
            activeItem: Icon(Icons.settings, color: Colors.white),
            itemLabel: 'Settings',
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
      floatingActionButton: ClipOval(
        child: Material(
          color: AppColors.primary,
          child: InkWell(
            splashColor: Colors.grey,
            child: const SizedBox(
              width: 50,
              height: 50,
              child: Icon(Icons.notifications, color: Colors.white, size: 30),
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationView()),
              );
            },
          ),
        ),
      ),
    );
  }
}
