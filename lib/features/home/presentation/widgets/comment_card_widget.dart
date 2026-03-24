import 'package:flutter/material.dart';
import 'comment_item_widget.dart';

/// みんなの一言セクション全体のWidget
/// セクションタイトルとコメントリストを表示する
class CommentCardWidget extends StatelessWidget {
  /// 一言コメントのリスト（name, commentのマップ）
  final List<Map<String, String>> comments;

  const CommentCardWidget({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションタイトル（カードの外に表示）
        const Text(
          'みんなの一言 💬',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // コメントリストカード
        _buildCommentListCard(),
      ],
    );
  }

  /// コメントリストを囲むカード
  Widget _buildCommentListCard() {
    return Container(
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
      child: Column(children: _buildCommentItems()),
    );
  }

  /// コメントアイテムのリストを生成する（間に16pxの余白を挿入）
  List<Widget> _buildCommentItems() {
    final items = <Widget>[];
    for (var i = 0; i < comments.length; i++) {
      // 各一言アイテム
      items.add(
        CommentItemWidget(
          name: comments[i]['name'] ?? '',
          comment: comments[i]['comment'] ?? '',
        ),
      );
      // 最後のアイテム以外に余白を追加
      if (i < comments.length - 1) {
        items.add(const SizedBox(height: 16));
      }
    }
    return items;
  }
}
