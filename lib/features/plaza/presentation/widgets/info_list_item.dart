import 'package:flutter/material.dart';

// 修正: 不要なコメントの削除と階層の整理
class InfoListItem extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final String title;
  final String value;
  final bool isUrl;
  final bool showDivider;

  const InfoListItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.value,
    this.isUrl = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildIcon(), // 修正: メソッド化してネストを浅く
              const SizedBox(width: 16),
              Expanded(child: _buildTextContent()),
              if (isUrl) _buildUrlArrow(),
            ],
          ),
        ),
        if (showDivider) _buildDivider(),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF757575), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUrlArrow() {
    return const Padding(
      padding: EdgeInsets.only(left: 8),
      child: Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Color(0xFFE0E0E0),
      indent: 16,
      endIndent: 16,
    );
  }
}
