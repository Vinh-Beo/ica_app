import 'package:flutter/material.dart';
import 'package:ica_app/src/cores/themes/app_colors.dart';
import 'package:ica_app/src/screens/debt/debtscreen.dart';
import 'package:ica_app/src/screens/order/orderscreen.dart';
import 'package:ica_app/src/screens/purchase/purchase_screen.dart';
import 'package:ica_app/src/screens/setting/setting.dart';

class AnimatedBottomNavBar extends StatefulWidget {
  const AnimatedBottomNavBar({super.key});

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}


class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar> {
  int _selectedIndex = 0;

  final List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded, label: 'Home'),
    NavItem(icon: Icons.search_rounded, label: 'Debt'),
    NavItem(icon: Icons.favorite_rounded, label: 'Purchase'),
    NavItem(icon: Icons.person_rounded, label: 'Setting'),
  ];

  final List<Widget> _pages = [
    const OrderScreen(title: 'Home'),
    const DebtScreen(title: 'Debt'),
    const PurchaseScreen(title: 'Purchase'),
    const SettingScreen(title: 'Setting'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _selectedIndex * (MediaQuery.of(context).size.width / 4) +
                  (MediaQuery.of(context).size.width / 8) -
                  30,
              top: 0,
              child: Container(
                width: 60,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.colorPurple,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (index) => _buildNavItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isSelected ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.colorPurple.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: isSelected
                    ? AppColors.colorPurple
                    : Colors.grey.shade400,
                size: isSelected ? 28 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isSelected
                    ? AppColors.colorPurple
                    : Colors.grey.shade400,
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
class NavItem {
  final IconData icon;
  final String label;

  NavItem({required this.icon, required this.label});
}

