import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// Figma node 1075:690 の「ナビゲーションバー」に準拠したシンプルなピル型
/// ボトムナビ。
///
/// - 白背景 / 角丸 100 / 大きめのソフトシャドウ
/// - 4 タブ横並び（アイコン + ラベル）
/// - アクティブは AppColors.primary の緑、非アクティブは textSecondary グレー
///
/// 既存の [AnimatedBottomNavBar]（`animated_bottom_nav_bar.dart`）は
/// アニメーション付きの独自デザインで一時的に温存する。移行の際に
/// `main_screen.dart` で本ウィジェットへ差し替える想定。
class PasslyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PasslyNavItem> items;

  const PasslyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF858E85).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < items.length; i++)
            _NavItem(
              item: items[i],
              active: i == currentIndex,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class PasslyNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const PasslyNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

class _NavItem extends StatelessWidget {
  final PasslyNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? (item.activeIcon ?? item.icon) : item.icon,
                color: color, size: 28),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
