import 'package:flutter/material.dart';

class QuestProgressCard extends StatelessWidget {
  final String questName;
  final double progress;
  final VoidCallback? onViewAllTap;

  const QuestProgressCard({
    super.key,
    required this.questName,
    required this.progress,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _buildDecoration(), // 修正: 装飾を分離
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildQuestItem(),
        ],
      ),
    );
  }

  // 修正: BoxDecorationを分離
  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0x4D3AAA3A)),
      boxShadow: const [
        BoxShadow(
          offset: Offset(0, 2),
          blurRadius: 8,
          color: Color(0x203AAA3A),
        ),
      ],
    );
  }

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
          onTap: onViewAllTap,
          child: const Text(
            'すべて見る',
            style: TextStyle(color: Color(0xFF3AAA3A), fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestItem() {
    final percentText = '${(progress * 100).toInt()}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questName,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: const Color(0xFF3AAA3A),
                  backgroundColor: const Color(0x4D3AAA3A),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
