import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 友達一覧グリッド用アイテムWidget
class FriendGridItem extends StatelessWidget {
  /// ユーザー名
  final String name;

  const FriendGridItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // プロフィール画面へ遷移
        context.push('/profile');
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 円形アイコン（64px）
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // 背景色: #3AAA3Aに15%透明度
              color: const Color(0x263AAA3A),
              // 枠線: #3AAA3A・2px
              border: Border.all(color: const Color(0xFF3AAA3A), width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 32),
          ),
          const SizedBox(height: 8),
          // ユーザー名
          Text(
            name,
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
