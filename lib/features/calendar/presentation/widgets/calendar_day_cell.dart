import 'package:flutter/material.dart';

/// カレンダーの各日付セルを描画するWidget
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool hasEncounter;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.hasEncounter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(alignment: Alignment.center, child: _buildCellContent()),
    );
  }

  Widget _buildCellContent() {
    // すれ違いがある場合: 緑の丸背景 + 白文字
    if (hasEncounter) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFF3AAA3A),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 今日の場合: 緑の枠線 + 緑文字（太字）
    if (isToday) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3AAA3A), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: Color(0xFF3AAA3A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 通常の日付: 黒文字
    return Text(
      '${date.day}',
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
    );
  }
}
