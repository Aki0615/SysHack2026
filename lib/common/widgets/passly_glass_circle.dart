import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// iOS 26 相当のリキッドグラス質感を持つ 40x40 円形ボタン背景。
///
/// `liquid_glass_renderer` パッケージの [LiquidGlass] を使い、シェーダーで
/// 本物のガラス玉のような屈折 + specular highlight + 背景ブラーを描画する。
///
/// QR 画面 / マイページヘッダー の両方で共有する部品。カラフルな背景の
/// 上に載せると背景の色がやわらかく屈折して透ける。
class PasslyGlassCircle extends StatelessWidget {
  final double diameter;
  final Widget child;

  const PasslyGlassCircle({
    super.key,
    this.diameter = 40,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassLayer(
      settings: const LiquidGlassSettings(
        thickness: 12,
        blur: 8,
        glassColor: Color(0x1AFFFFFF),
      ),
      child: LiquidGlass(
        shape: const LiquidOval(),
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Center(child: child),
        ),
      ),
    );
  }
}
