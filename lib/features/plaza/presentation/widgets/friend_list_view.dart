import 'dart:math';
import 'package:flutter/material.dart';
import 'friend_grid_item.dart';

// ── アイコンの座標を管理するクラス（このファイル内で使う）──
class _IconPosition {
  final double x;
  final double y;
  const _IconPosition({required this.x, required this.y});
}

// ── ランダム配置で友達アイコンを表示するWidget ──
class FriendListView extends StatefulWidget {
  final List<Map<String, String>> friends;

  const FriendListView({super.key, required this.friends});

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {
  // アイコンのサイズ（px）
  static const double _iconSize = 72;

  // 生成した座標リスト（nullの間はまだ未生成）
  List<_IconPosition>? _positions;

  // 重ならないランダム座標を生成するメソッド
  List<_IconPosition> _generatePositions({
    required double areaWidth,
    required double areaHeight,
  }) {
    final random = Random();
    final positions = <_IconPosition>[];
    const padding = 16.0; // 端からの余白
    const margin = 20.0;   // アイコン間の最低余白

    for (int i = 0; i < widget.friends.length; i++) {
      int attempts = 0;
      bool placed = false;

      while (attempts < 100 && !placed) {
        // ランダムな座標を生成
        final x = padding +
            random.nextDouble() * (areaWidth - _iconSize - padding * 2);
        final y = padding +
            random.nextDouble() * (areaHeight - _iconSize - padding * 2);

        // 既存アイコンと重なっていないか確認
        final overlaps = positions.any((pos) {
          final dx = pos.x - x;
          final dy = pos.y - y;
          return sqrt(dx * dx + dy * dy) < _iconSize + margin;
        });

        if (!overlaps) {
          positions.add(_IconPosition(x: x, y: y));
          placed = true;
        }
        attempts++;
      }
    }
    return positions;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 画面サイズが確定してから座標を1回だけ生成する
        _positions ??= _generatePositions(
          areaWidth: constraints.maxWidth,
          areaHeight: constraints.maxHeight,
        );

        return Stack(
          children: List.generate(widget.friends.length, (index) {
            // 座標が生成できなかった場合はスキップ
            if (index >= _positions!.length) return const SizedBox.shrink();

            final pos = _positions![index];
            return Positioned(
              left: pos.x,
              top: pos.y,
              child: FriendGridItem(
                name: widget.friends[index]['name'] ?? '',
              ),
            );
          }),
        );
      },
    );
  }
}