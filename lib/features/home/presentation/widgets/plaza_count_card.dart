import 'package:flutter/material.dart';

/// 広場の人数を表示するカードWidget
/// コンストラクタでデータを受け取り、バックエンド連携時に差し替えやすい設計
class PlazaCountCard extends StatelessWidget {
  /// 広場にいる人数
  final int count;

  const PlazaCountCard({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // 背景: primaryカラーに10%透明度
          color: const Color(0x1A3AAA3A),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 上部: アイコン + ラベル
            _buildLabel(),
            const SizedBox(height: 8),
            // 下部: 人数表示
            _buildCount(),
          ],
        ),
      ),
    );
  }

  /// アイコンとラベルの横並び表示
  Widget _buildLabel() {
    return Row(
      children: [
        const Icon(Icons.people, color: Color(0xFF3AAA3A), size: 16),
        const SizedBox(width: 4),
        Text(
          '広場の人数',
          style: TextStyle(color: const Color(0xFF757575), fontSize: 12),
        ),
      ],
    );
  }

  /// 人数の数値表示
  Widget _buildCount() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        const Text(
          '人',
          style: TextStyle(color: Color(0xFF757575), fontSize: 14),
        ),
      ],
    );
  }
}
