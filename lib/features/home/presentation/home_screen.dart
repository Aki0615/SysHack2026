import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/home_notifier.dart';
import '../../mypage/data/achievement_repository.dart';
import '../../mypage/domain/achievement_notifier.dart';
import 'widgets/stats_row_widget.dart';
import 'widgets/quest_progress_card.dart';
import 'widgets/comment_card_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final achievementState = ref.watch(achievementNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: homeState.when(
          data: (data) => _buildContent(
            context,
            ref,
            data,
            achievementState.asData?.value,
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
          ),
          error: (error, _) => _buildErrorState(ref),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HomeState data,
    AchievementResponse? achievementData,
  ) {
    // randomThreeが空ならunconfirmedをフォールバックとして使用
    final commentSource =
        data.randomThree.isNotEmpty ? data.randomThree : data.unconfirmed;

    final comments = commentSource
        .map((user) => {
              'name': user['name']?.toString() ?? '',
              'comment': user['one_word']?.toString() ?? '',
              'iconUrl': user['icon_url']?.toString() ?? '',
            })
        .toList();

    // クエスト進捗: 実績APIの解除率を優先し、未取得時のみ従来の今日の進捗で表示。
    final achievementProgress = (achievementData != null &&
        achievementData.totalCount > 0)
      ? (achievementData.unlockedCount / achievementData.totalCount)
        .clamp(0.0, 1.0)
      : null;

    const dailyLimit = 5;
    final fallbackProgress = (data.todayEncounters / dailyLimit).clamp(0.0, 1.0);
    final progress = achievementProgress ?? fallbackProgress;

    return RefreshIndicator(
      color: const Color(0xFF3AAA3A),
      onRefresh: () async {
        await Future.wait([
          ref.read(homeNotifierProvider.notifier).refresh(),
          ref.read(achievementNotifierProvider.notifier).refresh(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatsRowWidget(
              plazaCount: data.totalEncounters,
              todayCount: data.todayEncounters,
            ),
            const SizedBox(height: 24),
            QuestProgressCard(
              questName: '人とすれ違う',
              progress: progress,
              onViewAllTap: () => context.push('/stamp-card'),
            ),
            const SizedBox(height: 24),
            CommentCardWidget(comments: comments),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFF757575)),
          const SizedBox(height: 16),
          const Text(
            'データの取得に失敗しました',
            style: TextStyle(color: Color(0xFF757575), fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(homeNotifierProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3AAA3A),
            ),
            child: const Text(
              '再試行',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
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
