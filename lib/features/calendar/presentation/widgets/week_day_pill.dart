import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// 週表示の 1 日分のピル型セル。
///
/// Figma node 1305:2149 の仕様: 縦長 pill の中に「日番号が入る円」を
/// 上部に重ねた 2 段構造。
///
/// - 選択時 (isSelected = true):
///   - 外側 pill: primary の濃い緑
///   - 上部の円: primary の明るい緑
///   - テキスト: 白
/// - 非選択時:
///   - 外側 pill: divider グレー
///   - 上部の円: 白
///   - テキスト: 薄いグレー
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

  static const double _pillWidth = 46;
  static const double _pillHeight = 76;

  @override
  Widget build(BuildContext context) {
    // Figma 1297:592 準拠のカラースキーム。
    // - 選択時: 外側は primary-dark (#1E7F1E)、内側は primary-light (#6BD168)
    // - 非選択時: 外側は border-strong (divider)、内側は白
    // - テキスト: 選択時は白、非選択時は tertiary グレー
    const primaryDark = Color(0xFF1E7F1E);
    const primaryLight = Color(0xFF6BD168);
    final outerColor = isSelected ? primaryDark : AppColors.divider;
    final innerCircleColor =
        isSelected ? primaryLight : AppColors.backgroundWhite;
    final textColor = isSelected
        ? AppColors.backgroundWhite
        : AppColors.textDisabled;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          width: _pillWidth,
          height: _pillHeight,
          decoration: BoxDecoration(
            color: outerColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              // 上部の丸（日番号を入れる）
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: _pillWidth,
                  height: _pillWidth, // 円なので正方形
                  decoration: BoxDecoration(
                    color: innerCircleColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 19.93 / 16,
                    ),
                  ),
                ),
              ),
              // 下部の曜日ラベル（pill の下半分の中央）
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Center(
                  child: Text(
                    _weekdayLabel(date.weekday),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 17.4 / 14,
                    ),
                  ),
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
