import 'package:flutter/material.dart';
import 'friend_grid_item.dart';

/// 友達一覧タブの全体Widget（4列のGridView）
class FriendListView extends StatelessWidget {
  /// 友達リストデータ（nameのマップ）
  final List<Map<String, String>> friends;

  const FriendListView({super.key, required this.friends});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // GridView自体のスクロール設定（親のColumn内でExpandされているため通常スクロール）
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4列
        crossAxisSpacing: 8, // 横の余白
        mainAxisSpacing: 16, // 縦の余白（アイコン下の余白を確保するため少し広め）
        childAspectRatio: 0.8, // 横幅：高さ の比率（アイコン+テキストの構成に合わせて調整）
      ),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return FriendGridItem(name: friend['name'] ?? '');
      },
    );
  }
}
