import 'package:flutter/material.dart';

/// 一言アイテム（1人分の表示）Widget
/// プロフィールアイコン + ユーザー名 + 吹き出し風コメントを表示する
class CommentItemWidget extends StatelessWidget {
  /// ユーザー名
  final String name;

  /// 一言コメント
  final String comment;

  const CommentItemWidget({
    super.key,
    required this.name,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左: プロフィールアイコン + ユーザー名
        _buildProfileSection(),
        const SizedBox(width: 12),
        // 右: 吹き出し風コメント
        Expanded(child: _buildCommentBubble()),
      ],
    );
  }

  /// プロフィールアイコンとユーザー名
  Widget _buildProfileSection() {
    return Column(
      children: [
        // 円形プロフィールアイコン（56px）
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // 背景: primaryカラーに20%透明度
            color: const Color(0x333AAA3A),
            // 枠線: primaryカラー・2px
            border: Border.all(color: const Color(0xFF3AAA3A), width: 2),
          ),
          child: const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 28),
        ),
        const SizedBox(height: 4),
        // ユーザー名
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

  /// 吹き出し風コメントカード
  Widget _buildCommentBubble() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        // 角丸16px（左下のみ4px）
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(16),
        ),
        // ドロップシャドウ
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 4,
            color: Color(0x15000000),
          ),
        ],
      ),
      child: Text(
        comment,
        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
      ),
    );
  }
}
