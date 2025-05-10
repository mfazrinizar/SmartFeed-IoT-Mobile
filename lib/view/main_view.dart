import 'package:flutter/material.dart';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:smartfeed/const/color.dart';
import 'dashboard_view.dart';
import 'history_view.dart';
import 'settings_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final NotchBottomBarController _controller = NotchBottomBarController();
  final PageController _pageController = PageController();
  final List<Widget> _pages = [
    DashboardView(),
    HistoryView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        kIconSize: 30,
        kBottomRadius: 30,
        notchBottomBarController: _controller,
        color: AppColors.primary,
        showLabel: true,
        notchColor: AppColors.scaffoldBackground,
        removeMargins: false,
        bottomBarItems: const [
          BottomBarItem(
            inActiveItem: Icon(Icons.dashboard_outlined, color: Colors.black),
            activeItem: Icon(Icons.dashboard, color: Color(0xFFFFD700)),
            itemLabel: 'Dashboard',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.history, color: Colors.black),
            activeItem: Icon(Icons.history, color: Color(0xFFFFD700)),
            itemLabel: 'History',
          ),
          BottomBarItem(
            inActiveItem: Icon(Icons.settings_outlined, color: Colors.black),
            activeItem: Icon(Icons.settings, color: Color(0xFFFFD700)),
            itemLabel: 'Settings',
          ),
        ],
        onTap: (index) {
          _controller.jumpTo(index);
        },
      ),
    );
  }
}
