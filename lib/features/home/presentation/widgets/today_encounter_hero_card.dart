import 'package:flutter/material.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1079:865 「今日のすれ違いカード」。
///
/// 破線の緑ボーダー + 公園の背景画像 + 左上にタイトル/カウント +
/// 右下にすれ違ったユーザーのアバター3個。
///
/// アバターは NetworkImage (icon_url) を想定。空リストの場合はアバターを描画しない。
/// カードは親幅にフィットし、Figma 原寸 382x208.364 のアスペクト比 (約 1.834) を保つ。
class TodayEncounterHeroCard extends StatelessWidget {
  final int todayCount;
  final List<String> avatarUrls;

  const TodayEncounterHeroCard({
    super.key,
    required this.todayCount,
    this.avatarUrls = const [],
  });

  // Figma 原寸 (px)。全ての内部座標はこれを基準にスケールする。
  static const double _designW = 382;
  static const double _designH = 208.364;
  static const double _borderRadius = 23.152;
  static const double _borderWidth = 4;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _designW / _designH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final scale = constraints.maxWidth / _designW;
          return _buildCard(scale);
        },
      ),
    );
  }

  Widget _buildCard(double scale) {
    return CustomPaint(
      // 破線の緑ボーダーを CustomPainter で描画 (Flutter 標準の Border は破線非対応)。
      foregroundPainter: _DashedBorderPainter(
        color: PasslyBrand.primary,
        strokeWidth: _borderWidth,
        radius: _borderRadius,
        dashLength: 8,
        gapLength: 6,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: PasslyBg.surface,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: const [
            BoxShadow(
              offset: Offset(0, 2.315),
              blurRadius: 34.727,
              color: Color(0x407E857E),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 背景の公園イラスト。Figma 上では -2,-7 オフセットで少しはみ出して配置される。
            Positioned(
              left: -2 * scale,
              top: -7 * scale,
              width: _designW * scale,
              height: 217.432 * scale,
              child: Image.asset(
                'assets/images/home/today_encounter_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            // タイトル + カウント
            Positioned(
              left: 21.15 * scale,
              top: 16.52 * scale,
              width: 129.648 * scale,
              child: _TitleAndCount(scale: scale, count: todayCount),
            ),
            // アバター3個 (右下)
            ..._buildAvatars(scale),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAvatars(double scale) {
    // Figma spec: 全て top=137, left=220/257/295, size=57.88
    const size = 57.88;
    const top = 137.0;
    const lefts = [220.0, 257.0, 295.0];
    final avatars = <Widget>[];
    for (int i = 0; i < avatarUrls.length && i < 3; i++) {
      avatars.add(
        Positioned(
          left: lefts[i] * scale,
          top: top * scale,
          width: size * scale,
          height: size * scale,
          child: _AvatarCircle(url: avatarUrls[i]),
        ),
      );
    }
    return avatars;
  }
}

class _TitleAndCount extends StatelessWidget {
  final double scale;
  final int count;

  const _TitleAndCount({required this.scale, required this.count});

  @override
  Widget build(BuildContext context) {
    // Figma: Noto Sans JP Black (w900)、PasslyFont は w700 までしか定義が無いため w900 を直接指定。
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '今日のすれ違い',
          style: TextStyle(
            fontFamily: PasslyFont.family,
            fontWeight: FontWeight.w900,
            fontSize: 18.521 * scale,
            height: 22.225 / 18.521,
            color: PasslyText.primary,
          ),
        ),
        SizedBox(height: 15.048 * scale),
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontFamily: PasslyFont.family,
              fontWeight: FontWeight.w900,
              color: PasslyText.primary,
              height: 22.225 / 55.564,
            ),
            children: [
              TextSpan(
                text: '$count',
                style: TextStyle(fontSize: 55.564 * scale),
              ),
              TextSpan(
                text: '人',
                style: TextStyle(fontSize: 18.521 * scale),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String url;

  const _AvatarCircle({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: PasslyBg.elevated,
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: PasslyText.tertiary),
        ),
      ),
    );
  }
}

/// 角丸長方形の外周に破線を描画するペインター。
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashLength;
  final double gapLength;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    // PathMetric を dashLength ごとに切り出して破線を作る。
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final dashEnd = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, dashEnd), paint);
        distance = dashEnd + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength;
}
