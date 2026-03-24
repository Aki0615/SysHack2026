import 'package:flutter/material.dart';

// 修正: 不要なコメントの削除、UI構成のコンポーネント化
class EventListItem extends StatelessWidget {
  final String eventName;
  final String date;
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
      decoration: _buildDecoration(), // 修正: メソッド化
      child: Row(
        children: [
          _buildLeadingIcon(),
          const SizedBox(width: 12),
          Expanded(child: _buildEventInfo()),
          const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x4D3AAA3A), width: 1),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
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

  Widget _buildEventInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              '$count人',
              style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
