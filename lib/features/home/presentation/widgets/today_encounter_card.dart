import 'package:flutter/material.dart';

/// 今日のすれ違い回数を表示するカードWidget
/// コンストラクタでデータを受け取り、バックエンド連携時に差し替えやすい設計
class TodayEncounterCard extends StatelessWidget {
  /// 今日のすれ違い回数
  final int todayCount;

  /// 1日のすれ違い上限
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
        decoration: BoxDecoration(
          // 背景: primaryカラーに10%透明度
          color: const Color(0x1A3AAA3A),
          borderRadius: BorderRadius.circular(20),
          // 枠線: primaryカラーに30%透明度
          border: Border.all(color: const Color(0x4D3AAA3A)),
          // ドロップシャドウ
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 2),
              blurRadius: 8,
              color: Color(0x203AAA3A),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部: アイコン + ラベル
            _buildLabel(),
            const SizedBox(height: 8),
            // 下部: 回数表示
            _buildCount(),
          ],
        ),
      ),
    );
  }

  /// アイコンとラベルの横並び表示
  Widget _buildLabel() {
    return Row(
      children: [
        const Icon(Icons.people, color: Color(0xFF3AAA3A), size: 16),
        const SizedBox(width: 4),
        Text(
          '今日のすれ違い回数',
          style: TextStyle(color: const Color(0xFF757575), fontSize: 12),
        ),
      ],
    );
  }

  /// すれ違い回数と上限の表示
  Widget _buildCount() {
    return Row(
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
    );
  }
}
