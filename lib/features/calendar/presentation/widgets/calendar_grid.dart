import 'package:flutter/material.dart';
import 'calendar_day_cell.dart';

/// 曜日ヘッダーと日付セルで構成されるカレンダーグリッド
class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDay;
  final Map<DateTime, Map<String, dynamic>> encounterDays;
  final ValueChanged<DateTime> onDaySelected;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDay,
    required this.encounterDays,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildWeekdayHeader(),
          const SizedBox(height: 8),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  /// 曜日ヘッダー（日〜土）
  Widget _buildWeekdayHeader() {
    final weekdays = ['日', '月', '火', '水', '木', '金', '土'];
    final colors = [
      const Color(0xFFE53935), // 日
      const Color(0xFF757575), // 月
      const Color(0xFF757575), // 火
      const Color(0xFF757575), // 水
      const Color(0xFF757575), // 木
      const Color(0xFF757575), // 金
      const Color(0xFF1565C0), // 土
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        return Expanded(
          child: Center(
            child: Text(
              weekdays[index],
              style: TextStyle(
                color: colors[index],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 日付セルのグリッド（7列 x 最大6行）
  Widget _buildDaysGrid() {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      currentMonth.year,
      currentMonth.month,
    );
    // 日曜は DateTime.sunday (7) なので 7の余りを取ると 0 になる
    final emptyCellsBefore = firstDay.weekday % 7;
    final totalCells = emptyCellsBefore + daysInMonth;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        // 月の開始日より前は空のセルを表示
        if (index < emptyCellsBefore) {
          return const SizedBox.shrink();
        }

        final day = index - emptyCellsBefore + 1;
        final date = DateTime(currentMonth.year, currentMonth.month, day);
        final now = DateTime.now();
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

        // すれ違いデータの確認。時刻部分を無視して年月日で一致判定
        final hasEncounter = encounterDays.keys.any(
          (d) =>
              d.year == date.year && d.month == date.month && d.day == date.day,
        );

        return CalendarDayCell(
          date: date,
          isToday: isToday,
          hasEncounter: hasEncounter,
          onTap: () => onDaySelected(date),
        );
      },
    );
  }
}
