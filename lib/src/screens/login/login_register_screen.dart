import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ica_app/l10n/l10n.dart';
import 'package:ica_app/src/cores/components/bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:ica_app/src/cores/components/texts/w_normal_text.dart';
import 'package:ica_app/src/cores/components/texts/w_title_text.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/screens/login/auth/auth_bloc.dart';
import 'package:ica_app/src/screens/login/auth/auth_event.dart';
import 'package:ica_app/src/screens/login/auth/auth_state.dart';

class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({Key? key}) : super(key: key);

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {

  final AuthBloc _authBloc = AuthBloc();
  bool isLoginTab = true;
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    nameController.text = '';
    passwordController.text = '';
    // Listen to auth state changes
    _authBloc.state.listen((state) {
      if (state is AuthSuccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AnimatedBottomNavBar(),
          ),
        );
      } else if (state is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _handleLogin() {
    _authBloc.eventSink.add(
      LoginRequested(
        nameController.text,
        passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Tab Switcher
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoginTab = true;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isLoginTab ? AppColors.colorPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isLoginTab
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: WNormalText(text: context.l10n!.login,color: isLoginTab ? AppColors.colorWhite : AppColors.colorIconLight)
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isLoginTab = false;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: !isLoginTab ? AppColors.colorPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: !isLoginTab
                                  ? [
                                      const BoxShadow(
                                        color: AppColors.colorWhite,
                                        blurRadius: 10,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: WNormalText(text: context.l10n!.register, color: !isLoginTab ? AppColors.colorWhite : AppColors.colorIconLight),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/images/login.svg',
                  semanticsLabel: 'My SVG Image',
                  height: 240,
                  width: 240,
                ),
                // Email Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: Colors.grey.shade600),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Name',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Password Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lock_outline, color: Colors.grey.shade600),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n!.password,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            activeColor: AppColors.colorPurple,
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.l10n!.remember,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        context.l10n!.forgot_password,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Login Button
                ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.l10n!.login,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}



