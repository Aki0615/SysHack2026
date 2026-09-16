import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:syshack2026/common/widgets/level_display_card.dart';
import 'package:syshack2026/common/widgets/passly_header.dart';
import 'package:syshack2026/common/widgets/recent_encounter_card.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/home/domain/home_notifier.dart';
import 'package:syshack2026/features/home/domain/recent_encounter.dart';
import 'package:syshack2026/features/home/presentation/widgets/today_encounter_hero_card.dart';
import 'package:syshack2026/features/user/domain/level_info.dart';

/// ホーム画面 (Figma node 1110:2434 準拠)。
///
/// 上から順に: PasslyHeader.home / TodayEncounterHeroCard /
/// LevelDisplayCard / 「最近の出会い」タイトル + RecentEncounterCard 一覧。
///
/// ボトムナビは [MainScreen] 側で `PasslyBottomNav` として全タブ共通で描画する。
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            PasslyHeader.home(
              avatarUrl: user?.iconUrl.isNotEmpty == true ? user!.iconUrl : null,
            ),
            Expanded(
              child: homeState.when(
                data: (data) => _buildContent(context, ref, data),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: PasslyBrand.primary),
                ),
                error: (_, _) => _buildErrorState(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, HomeState data) {
    final levelInfo = LevelInfo.compute(data.totalEncounters);
    final avatarUrls = _pickTodayAvatarUrls(data);

    return RefreshIndicator(
      color: PasslyBrand.primary,
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: PasslySpace.s16,
          right: PasslySpace.s16,
          top: PasslySpace.s24,
          bottom: 120,
        ),
        children: [
          TodayEncounterHeroCard(
            todayCount: data.todayEncounters,
            avatarUrls: avatarUrls,
          ),
          const SizedBox(height: PasslySpace.s20),
          LevelDisplayCard(
            count: data.totalEncounters,
            remaining: levelInfo.remaining,
            currentLevel: levelInfo.level,
            progress: levelInfo.progress,
          ),
          const SizedBox(height: PasslySpace.s20),
          const Text(
            '最近の出会い',
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 24 / 20,
            ),
          ),
          const SizedBox(height: 13),
          ..._buildRecentEncounters(data.recentEncounters),
        ],
      ),
    );
  }

  List<Widget> _buildRecentEncounters(List<RecentEncounter> items) {
    if (items.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: PasslySpace.s16),
          child: Text(
            'まだ出会いがありません',
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: PasslyText.secondary,
              fontSize: 14,
              fontWeight: PasslyFont.medium,
            ),
          ),
        ),
      ];
    }
    return [
      for (final e in items)
        Padding(
          padding: const EdgeInsets.only(bottom: PasslySpace.s4),
          child: RecentEncounterCard(
            avatarUrl: e.iconUrl.isNotEmpty ? e.iconUrl : null,
            name: e.name,
            time: _formatTime(e.metAt),
            location: e.eventName,
          ),
        ),
    ];
  }

  /// `unconfirmed` / `randomThree` から今日のすれ違いカード用の 3 件を採る。
  /// サーバー側で `random_three` が空のときは `unconfirmed` にフォールバック。
  List<String> _pickTodayAvatarUrls(HomeState data) {
    final source = data.randomThree.isNotEmpty
        ? data.randomThree
        : data.unconfirmed;
    return source
        .map((e) => e['icon_url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .take(3)
        .toList();
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: PasslyText.secondary,
          ),
          const SizedBox(height: PasslySpace.s16),
          const Text(
            'データの取得に失敗しました',
            style: TextStyle(color: PasslyText.secondary, fontSize: 16),
          ),
          const SizedBox(height: PasslySpace.s16),
          ElevatedButton(
            onPressed: () => ref.read(homeNotifierProvider.notifier).refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PasslyBrand.primary,
            ),
            child: const Text('再試行', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

