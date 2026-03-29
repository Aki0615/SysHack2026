import 'package:flutter/material.dart';

// 修正: 不要コメント削除、UI要素のコンポーネント化によりネスト軽減
class CommentItemWidget extends StatelessWidget {
  final String name;
  final String comment;
  final String iconUrl;

  const CommentItemWidget({
    super.key,
    required this.name,
    required this.comment,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProfileSection(),
        const SizedBox(width: 12),
        Expanded(child: _buildCommentBubble()),
      ],
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x333AAA3A),
            border: Border.all(color: const Color(0xFF3AAA3A), width: 2),
          ),
          child: ClipOval(
            child: iconUrl.isNotEmpty
                ? Image.network(
                    iconUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      color: Color(0xFF3AAA3A),
                      size: 28,
                    ),
                  )
                : const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCommentBubble() {
    final displayComment = comment.trim().isEmpty ? '一言未設定' : comment;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 4,
            color: Color(0x15000000),
          ),
        ],
      ),
      child: Text(
        displayComment,
        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
      ),
    );
  }
}
