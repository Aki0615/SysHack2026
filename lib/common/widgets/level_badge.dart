import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// Figma node 1077:773 の「レベル別バッチ」を Flutter で近似実装したもの。
///
/// レベル 1〜4 に応じて多角形の辺数と色が変わる:
/// - Lv.1: 五角形 / 緑（AppColors.primary）
/// - Lv.2: 六角形 / 青
/// - Lv.3: 七角形 / オレンジ
/// - Lv.4: 八角形 / 紫
///
/// Figma オリジナルは SVG アセットだが、flutter_svg 依存を増やさないため
/// [CustomClipper] で多角形を描いて近似する。星は Material Icons.star_rounded、
/// リボンは下部の 2 つの三角形で表現する。
///
/// [size] は多角形部分の一辺（幅・高さ共通）。ラベルとリボンは外側に付く。
class LevelBadge extends StatelessWidget {
  final int level;
  final double size;
  final bool showLabel;

  const LevelBadge({
    super.key,
    required this.level,
    this.size = 80,
    this.showLabel = true,
  }) : assert(level >= 1 && level <= 4, 'level は 1〜4 の範囲');

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(level);
    final sides = _sidesFor(level);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 1.15,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 下部のリボン（三角形 x 2）
              Positioned(
                bottom: 0,
                child: _Ribbon(color: const Color(0xFF1F2A44), width: size * 0.55),
              ),
              // メインの多角形
              Positioned(
                top: 0,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 外側のライトリング
                      ClipPath(
                        clipper: _PolygonClipper(sides: sides),
                        child: Container(
                          width: size,
                          height: size,
                          color: palette.ring,
                        ),
                      ),
                      // 内側の濃い多角形
                      ClipPath(
                        clipper: _PolygonClipper(sides: sides),
                        child: Container(
                          width: size * 0.82,
                          height: size * 0.82,
                          color: palette.core,
                        ),
                      ),
                      // 中央の星
                      Icon(
                        Icons.star_rounded,
                        color: Colors.white.withValues(alpha: 0.95),
                        size: size * 0.5,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            'レベル$level',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ],
    );
  }

  static _LevelPalette _paletteFor(int level) {
    switch (level) {
      case 1:
        return const _LevelPalette(
          core: AppColors.primary,
          ring: Color(0xFFB7E5B4),
        );
      case 2:
        return const _LevelPalette(
          core: Color(0xFF3B82F6),
          ring: Color(0xFF7CC4FF),
        );
      case 3:
        return const _LevelPalette(
          core: Color(0xFFF59E0B),
          ring: Color(0xFFFCD87A),
        );
      case 4:
      default:
        return const _LevelPalette(
          core: Color(0xFF8B5CF6),
          ring: Color(0xFFC9A6FF),
        );
    }
  }

  static int _sidesFor(int level) {
    switch (level) {
      case 1:
        return 5;
      case 2:
        return 6;
      case 3:
        return 7;
      case 4:
      default:
        return 8;
    }
  }
}

class _LevelPalette {
  final Color core;
  final Color ring;

  const _LevelPalette({required this.core, required this.ring});
}

/// 頂点が上向きの正 n 角形パスを生成する [CustomClipper]。
class _PolygonClipper extends CustomClipper<Path> {
  final int sides;

  _PolygonClipper({required this.sides});

  @override
  Path getClip(Size size) {
    final path = Path();
    final radius = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < sides; i++) {
      // -pi/2 スタート = 頂点が真上を向く
      final angle = -math.pi / 2 + (2 * math.pi * i) / sides;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _PolygonClipper oldClipper) =>
      oldClipper.sides != sides;
}

/// 下部リボン（三角形 x 2 の V 字カット付き長方形）。
class _Ribbon extends StatelessWidget {
  final Color color;
  final double width;

  const _Ribbon({required this.color, required this.width});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.35),
      painter: _RibbonPainter(color: color),
    );
  }
}

class _RibbonPainter extends CustomPainter {
  final Color color;

  _RibbonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    // 左側の三角形
    final left = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.25, size.height)
      ..close();
    canvas.drawPath(left, paint);

    // 右側の三角形
    final right = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.75, size.height)
      ..close();
    canvas.drawPath(right, paint);
  }

  @override
  bool shouldRepaint(covariant _RibbonPainter oldDelegate) =>
      oldDelegate.color != color;
}
