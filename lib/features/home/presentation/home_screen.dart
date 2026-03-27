import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/home_dummy_data.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/quest_progress_card.dart';
import 'widgets/comment_card_widget.dart';

// 修正: サブウィジェットの切り出し、不要なコメント削除
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatsRowWidget(
                plazaCount: dummyPlazaCount,
                todayCount: dummyTodayCount,
                dailyLimit: dummyDailyLimit,
              ),
              const SizedBox(height: 24),
              QuestProgressCard(
                questName: '人とすれ違う',
                progress: dummyQuestProgress,
                onViewAllTap: () => context.push('/stamp-card'),
              ),
              const SizedBox(height: 24),
              CommentCardWidget(comments: dummyComments),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: const Text(
        'ホーム',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
