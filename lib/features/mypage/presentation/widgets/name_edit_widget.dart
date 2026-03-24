import 'package:flutter/material.dart';

/// 名前と編集アイコンを表示し、自分自身でダイアログを開いて修正するWidget
class NameEditWidget extends StatelessWidget {
  final String name;
  final ValueChanged<String> onSaved;

  const NameEditWidget({super.key, required this.name, required this.onSaved});

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('名前を編集'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '新しい名前を入力'),
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
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.edit, color: Color(0xFF757575), size: 16),
        ],
      ),
    );
  }
}
