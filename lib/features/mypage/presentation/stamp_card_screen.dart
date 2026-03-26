import 'package:flutter/material.dart';

/// スタンプカード（実績確認）画面
/// マイページの「スタンプカード > 実績の確認」から遷移して表示される
class StampCardScreen extends StatelessWidget {
  const StampCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _ProgressCard(
              unlockedCount: _achievements.where((a) => a.isUnlocked).length,
              totalCount: _achievements.length,
            ),
            const SizedBox(height: 20),
            _AchievementGrid(achievements: _achievements),
          ],
        ),
      ),
    );
  }

  /// AppBar: 戻るボタンと「スタンプカード」タイトル
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: const Text(
        'スタンプカード',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  ダミーデータ（実績一覧）
// ─────────────────────────────────────────────────────────

/// 実績データモデル
class _AchievementData {
  final String emoji;
  final String title;
  final String description;
  final String? unlockedDate; // nullなら未解除
  bool get isUnlocked => unlockedDate != null;

  const _AchievementData({
    required this.emoji,
    required this.title,
    required this.description,
    this.unlockedDate,
  });
}

/// ダミーの実績一覧
const List<_AchievementData> _achievements = [
  _AchievementData(
    emoji: '🎉',
    title: 'はじめてのすれ違い',
    description: '初めて誰かとすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(
    emoji: '👥',
    title: '10人達成',
    description: '累計10人とすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(
    emoji: '⭐',
    title: '50人達成',
    description: '累計50人とすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(
    emoji: '💯',
    title: '100人達成',
    description: '累計100人とすれ違いました！',
    unlockedDate: '2026/3/20',
  ),
  _AchievementData(
    emoji: '🎨',
    title: 'オールロール',
    description: '全ロールの人とすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(
    emoji: '⚡',
    title: '1日5人',
    description: '1日で5人とすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(
    emoji: '🔥',
    title: '3日連続',
    description: '3日連続ですれ違いました！',
    unlockedDate: '2026/3/21',
  ),
  _AchievementData(
    emoji: '🏆',
    title: '7日連続',
    description: '7日連続ですれ違いました！',
    unlockedDate: '2026/3/25',
  ),
  _AchievementData(
    emoji: '🌟',
    title: 'イベント参加',
    description: 'イベントに参加してすれ違いました！',
    unlockedDate: '2026/3/19',
  ),
  _AchievementData(emoji: '🔒', title: '???', description: '条件を満たすと解除されます。'),
];

// ─────────────────────────────────────────────────────────
//  解除状況カード（プログレスバー）
// ─────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final int unlockedCount;
  final int totalCount;

  const _ProgressCard({required this.unlockedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // タイトル行: 「解除状況」 と 「9 / 10」
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '解除状況',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCountLabel(),
            ],
          ),
          const SizedBox(height: 12),
          // プログレスバー
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3AAA3A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 解除数 / 合計数 のラベル
  Widget _buildCountLabel() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$unlockedCount',
            style: const TextStyle(
              color: Color(0xFF3AAA3A),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: ' / $totalCount',
            style: const TextStyle(
              color: Color(0xFF757575),
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  実績グリッド（2カラム）
// ─────────────────────────────────────────────────────────

class _AchievementGrid extends StatelessWidget {
  final List<_AchievementData> achievements;

  const _AchievementGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _AchievementCard(achievement: achievements[index]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  個別の実績カード
// ─────────────────────────────────────────────────────────

class _AchievementCard extends StatelessWidget {
  final _AchievementData achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: () => _showDetailDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? const Color(0xFFF5F5F5) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? Border.all(
                  color: const Color(0xFF3AAA3A).withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 絵文字アイコン（未解除ならロックアイコン）
            Text(
              isUnlocked ? achievement.emoji : '🔒',
              style: TextStyle(
                fontSize: 36,
                color: isUnlocked ? null : const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 8),
            // 実績タイトル
            Text(
              isUnlocked ? achievement.title : '???',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF9E9E9E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // 解除日
            Text(
              isUnlocked ? achievement.unlockedDate! : '未解除',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  /// タップ時に詳細ダイアログを表示する
  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _AchievementDetailDialog(achievement: achievement);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────
//  詳細ダイアログ（タップ時の拡大表示）
// ─────────────────────────────────────────────────────────

class _AchievementDetailDialog extends StatelessWidget {
  final _AchievementData achievement;

  const _AchievementDetailDialog({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFFFFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 絵文字（大きく表示）
            Text(
              achievement.isUnlocked ? achievement.emoji : '🔒',
              style: const TextStyle(fontSize: 56),
            ),
            const SizedBox(height: 16),
            // タイトル
            Text(
              achievement.isUnlocked ? achievement.title : '???',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // 説明文
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 14),
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 4),
              Text(
                '達成日: ${achievement.unlockedDate}',
                style: const TextStyle(
                  color: Color(0xFF3AAA3A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5F5F5),
                  foregroundColor: const Color(0xFF1A1A1A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
