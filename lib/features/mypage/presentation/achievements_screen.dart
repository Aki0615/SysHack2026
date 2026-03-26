import 'package:flutter/material.dart';

/// 実績（スタンプカード）一覧画面
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  /// ダミーの実績データ
  static final List<Achievement> _achievements = [
    Achievement(
      id: '1',
      emoji: '👋',
      title: 'はじめまして',
      condition: '初めてすれ違いをする',
      unlockedAt: DateTime(2024, 3, 15, 14, 30),
    ),
    Achievement(
      id: '2',
      emoji: '🔥',
      title: '3日連続',
      condition: '3日連続ですれ違いをする',
      unlockedAt: DateTime(2024, 3, 18, 10, 15),
    ),
    Achievement(
      id: '3',
      emoji: '🎯',
      title: '10人達成',
      condition: '累計10人とすれ違う',
      unlockedAt: DateTime(2024, 3, 20, 16, 45),
    ),
    Achievement(
      id: '4',
      emoji: '⭐',
      title: 'フルスタッカー',
      condition: 'フルスタックエンジニアとすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '5',
      emoji: '🌙',
      title: '夜更かし',
      condition: '深夜0時以降にすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '6',
      emoji: '☀️',
      title: '早起き',
      condition: '朝6時前にすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '7',
      emoji: '🏃',
      title: 'マラソン',
      condition: '1日に5人とすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '8',
      emoji: '🎉',
      title: 'イベントマスター',
      condition: 'イベント会場で10人とすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '9',
      emoji: '💯',
      title: '100人達成',
      condition: '累計100人とすれ違う',
      unlockedAt: null,
    ),
    Achievement(
      id: '10',
      emoji: '👑',
      title: 'レジェンド',
      condition: '全ての実績を解除する',
      unlockedAt: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _achievements.where((a) => a.isUnlocked).length;
    final totalCount = _achievements.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '実績一覧',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 進捗バー
            _buildProgressSection(unlockedCount, totalCount),
            // バッジグリッド
            Expanded(
              child: _buildBadgeGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 進捗バーセクション
  Widget _buildProgressSection(int unlockedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$unlockedCount / $totalCount 解除済み',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(unlockedCount / totalCount * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF3AAA3A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: unlockedCount / totalCount,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3AAA3A)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// バッジグリッド
  Widget _buildBadgeGrid(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _BadgeCard(
          achievement: achievement,
          onTap: () => _showAchievementDialog(context, achievement),
        );
      },
    );
  }

  /// 実績詳細ダイアログ
  void _showAchievementDialog(BuildContext context, Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFFFFF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: 64,
                color: achievement.isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              achievement.isUnlocked ? achievement.title : '???',
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                achievement.condition,
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (achievement.isUnlocked) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF3AAA3A),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${achievement.unlockedAt!.year}/${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day} に解除',
                    style: const TextStyle(
                      color: Color(0xFF3AAA3A),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '閉じる',
              style: TextStyle(
                color: Color(0xFF3AAA3A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// バッジカードWidget
class _BadgeCard extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onTap;

  const _BadgeCard({
    required this.achievement,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? const Color(0xFF3AAA3A).withValues(alpha: 0.3)
                : const Color(0xFFE0E0E0),
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: const Color(0xFF3AAA3A).withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 絵文字
            Text(
              achievement.emoji,
              style: TextStyle(
                fontSize: 48,
                color: isUnlocked ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            // タイトル
            Text(
              isUnlocked ? achievement.title : '???',
              style: TextStyle(
                color: isUnlocked
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF9E9E9E),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // 解除日時 or ロック状態
            if (isUnlocked)
              Text(
                '${achievement.unlockedAt!.month}/${achievement.unlockedAt!.day} 解除',
                style: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 12,
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    color: const Color(0xFF9E9E9E),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '未解除',
                    style: TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// 実績データモデル
class Achievement {
  final String id;
  final String emoji;
  final String title;
  final String condition;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.condition,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;
}
