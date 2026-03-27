// 修正: 不要なコメントを削除し、コードを最小化
import 'dart:math';
import 'package:flutter/material.dart';
import 'friend_grid_item.dart';

class _IconPosition {
  final double x, y; // 修正: 変数宣言をまとめて整理
  const _IconPosition(this.x, this.y); // 修正: シンプルなコンストラクタに変更
}

class FriendListView extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  const FriendListView({super.key, required this.friends});

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  static const double _iconSize = 72;
  static const double _pad = 16.0; // 修正: 定数化
  static const double _margin = 20.0; // 修正: 定数化

  List<_IconPosition>? _positions;

  // 修正: メソッド抽出でネストを浅く整理
  List<_IconPosition> _generatePositions(double width, double height) {
    final rand = Random();
    final positions = <_IconPosition>[];
    final maxX = width - _iconSize - _pad * 2;
    final maxY = height - _iconSize - _pad * 2;

    for (int i = 0; i < widget.friends.length; i++) {
      _tryPlaceIcon(rand, maxX, maxY, positions);
    }
    return positions;
  }

  // 修正: 位置座標の決定と衝突判定ループを別メソッドに分離
  void _tryPlaceIcon(
    Random rand,
    double maxX,
    double maxY,
    List<_IconPosition> positions,
  ) {
    for (int attempts = 0; attempts < 100; attempts++) {
      final x = _pad + rand.nextDouble() * maxX;
      final y = _pad + rand.nextDouble() * maxY;

      if (!_hasOverlap(x, y, positions)) {
        positions.add(_IconPosition(x, y));
        break; // 修正: 配置できたらループを抜ける
      }
    }
  }

  // 修正: 衝突判定ロジックの分離
  bool _hasOverlap(double x, double y, List<_IconPosition> positions) {
    return positions.any((p) {
      final dx = p.x - x;
      final dy = p.y - y;
      return sqrt(dx * dx + dy * dy) < _iconSize + _margin;
    });
  }

  Widget _buildFriendItem(int index) {
    if (index >= _positions!.length) return const SizedBox.shrink();

    final pos = _positions![index];
    return Positioned(
      left: pos.x,
      top: pos.y,
      child: FriendGridItem(
        name: widget.friends[index]['name']?.toString() ?? '',
        userId: widget.friends[index]['id']?.toString() ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 修正: 画面サイズ確定時の座標生成をスッキリ記述
        _positions ??= _generatePositions(
          constraints.maxWidth,
          constraints.maxHeight,
        );

        return Stack(
          // 修正: ネストを浅くするためメソッドで要素を展開
          children: List.generate(widget.friends.length, _buildFriendItem),
        );
      },
    );
  }
}
