import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartfeed/const/color.dart';
import 'package:smartfeed/controller/auth_controller.dart';
import 'package:smartfeed/util/form_validator.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController reNewPasswordController = TextEditingController();
  bool currentPasswordVisible = false;
  bool newPasswordVisible = false;
  bool reNewPasswordVisible = false;
  bool isProcessing = false;

  Future<void> _changePassword() async {
    setState(() {
      isProcessing = true;
    });
    try {
      await AuthController().changePassword(
        newPasswordController.text.trim(),
        currentPasswordController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password changed successfully.'),
            backgroundColor: AppColors.commonSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to change password.'),
            backgroundColor: AppColors.commonError,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(children: [
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/illustration/change.svg',
                    height: height * 0.25,
                  ),
                ),
              ),
              Positioned(
                top: height * 0.25,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const ShapeDecoration(
                    color: AppColors.commonBackground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(50),
                        topLeft: Radius.circular(50),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Text('Change Password',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 10),
                            StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  children: [
                                    TextFormField(
                                      controller: currentPasswordController,
                                      validator: FormValidator.validatePassword,
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'Current Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(currentPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              currentPasswordVisible =
                                                  !currentPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !currentPasswordVisible,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: newPasswordController,
                                      validator: FormValidator.validatePassword,
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'New Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(newPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              newPasswordVisible =
                                                  !newPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !newPasswordVisible,
                                    ),
                                    const SizedBox(height: 12),
                                    TextFormField(
                                      controller: reNewPasswordController,
                                      validator: (value) =>
                                          FormValidator.validateRePassword(
                                              newPasswordController.text,
                                              reNewPasswordController.text),
                                      decoration: InputDecoration(
                                        hintText: '********',
                                        labelText: 'Re-enter New Password',
                                        prefixIcon: const Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(reNewPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off),
                                          onPressed: () {
                                            setState(() {
                                              reNewPasswordVisible =
                                                  !reNewPasswordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !reNewPasswordVisible,
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shadowColor: Colors.grey,
                                elevation: 5,
                              ),
                              onPressed: isProcessing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _changePassword();
                                      }
                                    },
                              child: isProcessing
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Change Password',
                                      style: TextStyle(fontSize: 20),
                                    ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
