import 'package:flutter/material.dart';

/// 友達一覧・イベント一覧の切り替えボタンWidget
class TabSwitchButton extends StatelessWidget {
  /// 現在選択されているタブ（0: 友達一覧, 1: イベント一覧）
  final int selectedIndex;

  /// タブ切り替え時のコールバック
  final ValueChanged<int> onTabChanged;

  const TabSwitchButton({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: '友達一覧',
              isSelected: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildTabButton(
              title: 'イベント一覧',
              isSelected: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3AAA3A) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFFFFFFF)
                : const Color(0xFF757575),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
