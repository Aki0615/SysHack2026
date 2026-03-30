import 'package:flutter/material.dart';

/// カレンダーの各日付セルを描画するWidget
class CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool hasEncounter;
  final bool hasEvent;
  final String? eventName;
  final VoidCallback onTap;

  const CalendarDayCell({
    super.key,
    required this.date,
    required this.isToday,
    required this.hasEncounter,
    required this.hasEvent,
    this.eventName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        child: _buildCellContent(),
      ),
    );
  }

  Widget _buildCellContent() {
    // すれ違いがある日は元の表示（緑の丸背景 + 白文字 + イベント名）
    if (hasEncounter) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFF3AAA3A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (eventName != null && eventName!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              _truncateEventName(eventName!),
              style: const TextStyle(
                color: Color(0xFF3AAA3A),
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      );
    }

    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: _buildDayNumber(),
          ),
          if (hasEvent)
            const Positioned(
              top: 1,
              right: 1,
              child: _EventDot(),
            ),
        ],
      ),
    );
  }

  Widget _buildDayNumber() {
    // 今日の場合: 緑の枠線 + 緑文字（太字）
    if (isToday) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3AAA3A), width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: const TextStyle(
            color: Color(0xFF3AAA3A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // 通常の日付: 黒文字
    return Text(
      '${date.day}',
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 12),
    );
  }

  /// イベント名を短縮表示（最大6文字）
  String _truncateEventName(String name) {
    if (name.length <= 6) return name;
    return '${name.substring(0, 5)}…';
  }
}

class _EventDot extends StatelessWidget {
  const _EventDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF3AAA3A), width: 1),
      ),
    );
  }
}
