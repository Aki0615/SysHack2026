import 'package:flutter/material.dart';
import '../data/home_dummy_data.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/quest_progress_card.dart';
import 'widgets/comment_card_widget.dart';

/// ホーム画面Widget
/// ダミーデータを使って各セクションを表示する
/// バックエンド連携時にはProviderから取得したデータを渡す形に変更する
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
              // セクション①: 上部2カード
              StatsRowWidget(
                plazaCount: dummyPlazaCount,
                todayCount: dummyTodayCount,
                dailyLimit: dummyDailyLimit,
              ),
              const SizedBox(height: 20),

              // セクション②: クエスト進捗カード
              QuestProgressCard(
                questName: dummyQuestName,
                progress: dummyQuestProgress,
              ),
              const SizedBox(height: 24),

              // セクション③: みんなの一言カード
              CommentCardWidget(comments: dummyComments),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBarの構築
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: false,
      title: const Row(
        children: [
          Icon(Icons.bluetooth, color: Color(0xFF3AAA3A), size: 28),
          SizedBox(width: 8),
          Text(
            'StreetPass',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
