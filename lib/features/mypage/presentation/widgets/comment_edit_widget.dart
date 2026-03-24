import 'package:flutter/material.dart';

/// 「一言」を表示し、必要に応じてダイアログから編集できるカプセル型Widget
class CommentEditWidget extends StatelessWidget {
  final String comment;
  final ValueChanged<String> onSaved;

  const CommentEditWidget({
    super.key,
    required this.comment,
    required this.onSaved,
  });

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: comment);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('一言を編集'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '新しい一言を入力'),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ),
            TextButton(
              onPressed: () {
                onSaved(controller.text);
                Navigator.pop(context);
              },
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Color(0xFF3AAA3A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showEditDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                comment,
                style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, color: Color(0xFF757575), size: 16),
          ],
        ),
      ),
    );
  }
}
