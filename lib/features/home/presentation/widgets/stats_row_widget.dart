import 'package:flutter/material.dart';
import 'plaza_count_card.dart';
import 'today_encounter_card.dart';

/// 上部2カードを横並びで表示するWidget
/// PlazaCountCardとTodayEncounterCardを均等幅で配置する
class StatsRowWidget extends StatelessWidget {
  /// 広場の人数
  final int plazaCount;

  /// 今日のすれ違い回数
  final int todayCount;

  /// 1日のすれ違い上限
  final int dailyLimit;

  const StatsRowWidget({
    super.key,
    required this.plazaCount,
    required this.todayCount,
    required this.dailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 左カード: 広場の人数
        PlazaCountCard(count: plazaCount),
        const SizedBox(width: 8),
        // 右カード: 今日のすれ違い回数
        TodayEncounterCard(todayCount: todayCount, dailyLimit: dailyLimit),
      ],
    );
  }
}
