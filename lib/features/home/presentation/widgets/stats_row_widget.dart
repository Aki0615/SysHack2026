import 'package:flutter/material.dart';
import 'plaza_count_card.dart';
import 'today_encounter_card.dart';

// 修正: 不要なコメントを削除、コードを最小化
class StatsRowWidget extends StatelessWidget {
  final int plazaCount;
  final int todayCount;
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
        PlazaCountCard(count: plazaCount),
        const SizedBox(width: 8),
        TodayEncounterCard(todayCount: todayCount, dailyLimit: dailyLimit),
      ],
    );
  }
}
