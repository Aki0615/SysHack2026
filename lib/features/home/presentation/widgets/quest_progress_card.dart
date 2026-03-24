import 'package:flutter/material.dart';

/// クエスト進捗を表示するカードWidget
/// クエスト名・進捗バー・達成率を表示する
class QuestProgressCard extends StatelessWidget {
  /// クエスト名
  final String questName;

  /// クエスト進捗（0.0〜1.0）
  final double progress;

  const QuestProgressCard({
    super.key,
    required this.questName,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
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
        children: [
          // 上部: タイトルと「すべて見る」ボタン
          _buildHeader(),
          const SizedBox(height: 16),
          // クエスト内容
          _buildQuestItem(),
        ],
      ),
    );
  }

  /// ヘッダー行（タイトル + すべて見るボタン）
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '🎯 クエスト進捗',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: クエスト一覧画面への遷移
          },
          child: const Text(
            'すべて見る',
            style: TextStyle(color: Color(0xFF3AAA3A), fontSize: 12),
          ),
        ),
      ],
    );
  }

  /// クエストアイテム（名前 + プログレスバー + 達成率）
  Widget _buildQuestItem() {
    // 達成率をパーセント表示に変換
    final percentText = '${(progress * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // クエスト名
        Text(
          questName,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
        ),
        const SizedBox(height: 8),
        // プログレスバー + 達成率
        Row(
          children: [
            // プログレスバー
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  // primaryカラー
                  color: const Color(0xFF3AAA3A),
                  // 背景: primaryカラーに30%透明度
                  backgroundColor: const Color(0x4D3AAA3A),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 達成率テキスト
            Text(
              percentText,
              style: const TextStyle(
                color: Color(0xFF3AAA3A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
