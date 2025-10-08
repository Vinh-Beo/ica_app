import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key, required this.title}) : super(key: key);

  final String title;
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool phoneEnabled = true;
  double verificationProgress = 0.8;
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        // leading: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     child: IconButton(
        //       icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        //       onPressed: () {},
        //     ),
        //   ),
        // ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.all(8.0),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         color: Colors.white,
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //       child: IconButton(
        //         icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 24),
        //         onPressed: () {},
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade100,
                            image: const DecorationImage(
                              image: NetworkImage('https://i.pravatar.cc/300'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name
                    const Text(
                      'James',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Verification Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Identity verification',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${(verificationProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: verificationProgress,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Account Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        'Account setting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildSettingItem(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      trailing: Switch(
                        value: phoneEnabled,
                        onChanged: (value) {
                          setState(() {
                            phoneEnabled = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notification',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.location_on_outlined,
                      title: 'Saved address',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.language_outlined,
                      title: 'Select language',
                      onTap: () {},
                      isLast: true,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Login Button
              ElevatedButton(
                onPressed: isLoading ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.colorPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                    : const Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Row(
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                trailing ??
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey,
        size: 28,
      ),
    );
  }
}