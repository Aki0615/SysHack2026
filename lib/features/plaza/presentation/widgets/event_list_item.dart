import 'package:flutter/material.dart';

/// イベント一覧リスト用アイテムWidget
class EventListItem extends StatelessWidget {
  /// イベント名
  final String eventName;

  /// 日付
  final String date;

  /// 参加人数
  final String count;

  const EventListItem({
    super.key,
    required this.eventName,
    required this.date,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        // 枠線: #3AAA3Aに30%透明度・1px
        border: Border.all(color: const Color(0x4D3AAA3A), width: 1),
      ),
      child: Row(
        children: [
          // 左: カレンダーチェックアイコン
          _buildLeadingIcon(),
          const SizedBox(width: 12),
          // 中央: イベント情報
          Expanded(child: _buildEventInfo()),
          // 右: 矢印アイコン
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
        ],
      ),
    );
  }

  /// カレンダーアイコン部分
  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // 背景: #3AAA3Aに15%透明度
        color: const Color(0x263AAA3A),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.event_available,
        color: Color(0xFF3AAA3A),
        size: 32,
      ),
    );
  }

  /// イベント情報テキスト部分
  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // イベント名
        Text(
          eventName,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // 日付 + アイコン + 人数
        Row(
          children: [
            Text(
              date,
              style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.people, color: Color(0xFF757575), size: 12),
            const SizedBox(width: 4),
            Text(
              '\$count人',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
