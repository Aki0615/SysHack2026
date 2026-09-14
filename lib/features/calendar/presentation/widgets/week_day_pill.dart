import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// 週表示の 1 日分のピル型セル。
///
/// 選択時は AppColors.primary の緑、非選択は AppColors.divider のグレー。
class WeekDayPill extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const WeekDayPill({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? AppColors.primary : AppColors.divider;
    final fg = isSelected ? AppColors.backgroundWhite : AppColors.textDisabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: 46,
          height: 76,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                date.day.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 19.9 / 16,
                ),
              ),
              Text(
                _weekdayLabel(date.weekday),
                style: TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 17.4 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _weekdayLabel(int weekday) {
    // DateTime.weekday は 1(月) 〜 7(日)
    const labels = ['月', '火', '水', '木', '金', '土', '日'];
    return labels[weekday - 1];
  }
}
