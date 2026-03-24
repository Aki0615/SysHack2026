import 'package:flutter/material.dart';

/// 表示月を切り替えるヘッダーWidget
class MonthSelector extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const MonthSelector({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左: ＜ 前月
          GestureDetector(
            onTap: onPreviousMonth,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '＜ 前月',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
            ),
          ),
          // 中央: 年月
          Text(
            '${currentMonth.year}年 ${currentMonth.month}月',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          // 右: 次月 ＞
          GestureDetector(
            onTap: onNextMonth,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                '次月 ＞',
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
