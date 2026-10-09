import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class KMartBottomNav extends StatelessWidget {
  const KMartBottomNav({super.key, required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 16,
      shadowColor: Colors.black.withValues(alpha: .10),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _Item(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', selected: currentIndex == 0, onTap: () => onTap(0)),
              _Item(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view, label: 'Categories', selected: currentIndex == 1, onTap: () => onTap(1)),
              _Item(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Orders', selected: currentIndex == 2, onTap: () => onTap(2)),
              _Item(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Account', selected: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.selectedIcon, required this.label, required this.selected, required this.onTap});
  final IconData icon, selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, size: 22, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 10.5, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? AppColors.primary : AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
