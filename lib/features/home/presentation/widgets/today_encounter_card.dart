import 'package:flutter/material.dart';

// 修正: 不要なコメントを削除、定数とレイアウトを整理
class TodayEncounterCard extends StatelessWidget {
  final int todayCount;
  final int dailyLimit;

  const TodayEncounterCard({
    super.key,
    required this.todayCount,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _buildDecoration(), // 修正: メソッドに切り出し
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildLabel(), const SizedBox(height: 8), _buildCount()],
        ),
      ),
    );
  }

  // 修正: BoxDecorationを分離
  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: const Color(0x1A3AAA3A),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x4D3AAA3A)),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 8,
          color: Color(0x203AAA3A),
        ),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        const Icon(Icons.people, color: Color(0xFF3AAA3A), size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '今日のすれ違い回数',
            style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildCount() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$todayCount',
            style: const TextStyle(
              color: Color(0xFF3AAA3A),
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '/ $dailyLimit人',
            style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
