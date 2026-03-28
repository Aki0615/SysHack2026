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
  static const double _pad = 16.0;
  static const double _itemWidth = 96.0;
  static const double _itemHeight = 104.0;
  static const double _itemGap = 8.0;

  List<_IconPosition>? _positions;
  double? _lastWidth;
  double? _lastHeight;
  String _lastLayoutKey = '';

  // 修正: メソッド抽出でネストを浅く整理
  List<_IconPosition> _generatePositions(double width, double height) {
    final rand = Random();
    final positions = <_IconPosition>[];
    final maxX = width - _itemWidth - _pad * 2;
    final maxY = height - _itemHeight - _pad * 2;

    for (int i = 0; i < widget.friends.length; i++) {
      _tryPlaceItem(rand, maxX, maxY, positions);
    }
    return positions;
  }

  void _tryPlaceItem(
    Random rand,
    double maxX,
    double maxY,
    List<_IconPosition> positions,
  ) {
    for (int attempts = 0; attempts < 300; attempts++) {
      final x = _pad + rand.nextDouble() * maxX;
      final y = _pad + rand.nextDouble() * maxY;

      if (!_hasOverlap(x, y, positions)) {
        positions.add(_IconPosition(x, y));
        break;
      }
    }
  }

  bool _hasOverlap(double x, double y, List<_IconPosition> positions) {
    return positions.any((p) {
      final horizontalOverlap =
          (x < p.x + _itemWidth + _itemGap) &&
          (x + _itemWidth + _itemGap > p.x);
      final verticalOverlap =
          (y < p.y + _itemHeight + _itemGap) &&
          (y + _itemHeight + _itemGap > p.y);
      return horizontalOverlap && verticalOverlap;
    });
  }

  String _buildLayoutKey() {
    return widget.friends
        .map((f) => '${f['id'] ?? ''}:${f['name'] ?? ''}')
        .join('|');
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
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final layoutKey = _buildLayoutKey();

        final needsRebuild =
            _positions == null ||
            _lastWidth != width ||
            _lastHeight != height ||
            _lastLayoutKey != layoutKey;

        if (needsRebuild) {
          _positions = _generatePositions(width, height);
          _lastWidth = width;
          _lastHeight = height;
          _lastLayoutKey = layoutKey;
        }

        return Stack(
          children: List.generate(widget.friends.length, _buildFriendItem),
        );
      },
    );
  }
}
