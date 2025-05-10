import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartfeed/const/color.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartfeed/controller/auth_controller.dart';
import 'package:smartfeed/view/auth/change_name_view.dart';
import 'package:smartfeed/view/auth/login_view.dart';
import 'auth/change_password_view.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  String? userName;
  String? userEmail;
  String? userId;
  String? appVersion;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadVersion();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      userEmail = user.email;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = doc.data()?['name'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = info.version;
    });
  }

  Future<void> _logout() async {
    try {
      final AuthController authController = AuthController();
      await authController.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully!'),
            backgroundColor: AppColors.commonSuccess,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginView(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout. Please try again.'),
            backgroundColor: AppColors.commonError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.commonBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 64,
                    backgroundColor: AppColors.primary,
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo/logo_no-bg.png',
                        width: 256,
                        height: 256,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'SmartFeed v${appVersion ?? ""}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                ),
                if ((userName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      '$userName',
                      style: TextStyle(
                        color: AppColors.commonSuccess,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSettingsTile(
                  context,
                  icon: Icons.person,
                  title: 'Change Name',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNameView(
                          currentName: userName ?? '',
                          userId: userId ?? '',
                        ),
                      ),
                    );
                    await _loadUser();
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.email,
                  title: userEmail ?? '',
                  onTap: () {},
                  enabled: false,
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordView(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.info,
                  title: 'About',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'SmartFeed',
                      applicationVersion: appVersion ?? '',
                      applicationIcon: Image.asset(
                        'assets/logo/logo_no-bg.png',
                        width: 60,
                        height: 60,
                      ),
                      children: [
                        const Text(
                          'SmartFeed is a smart pet feeder that allows you to feed your pets remotely. Developed by SmartFeed UNSRI Team.',
                        ),
                      ],
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () async {
                    showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.pop(context);
                                  await _logout();
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Function() onTap,
    bool enabled = true,
  }) {
    return Column(
      children: [
        Material(
          color: enabled ? Theme.of(context).primaryColor : Colors.grey[400],
          borderRadius: BorderRadius.circular(12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: enabled ? onTap : null,
            splashColor: Colors.white24,
            child: ListTile(
              leading: Icon(icon, color: Colors.white),
              title: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
              ),
              trailing: enabled
                  ? const Icon(Icons.arrow_forward_ios, color: Colors.white)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
