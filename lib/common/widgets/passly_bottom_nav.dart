import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Figma node 1300:1627 の「ナビゲーションバー」ComponentSet 4 バリアント
/// (ホーム / 広場 / カレンダー / マイページ) 準拠のピル型ボトムナビ。
///
/// - 白背景 / 角丸 118 / ソフトシャドウ / 高さ 64
/// - 4 タブ横並び（アイコン 28 SVG + ラベル 7px SemiBold）
/// - アクティブ: `PasslyBrand.primaryLight (#6BD168)` に色替え
/// - 非アクティブ: `PasslyText.secondary (#6B7280)` に色替え
///
/// アイコンは `assets/images/nav/*.svg` を `ColorFilter.srcIn` で動的に着色する。
/// 既存の [PasslyNavItems.defaults] で Passly 標準 4 タブを取得できる。
class PasslyBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PasslyNavItem> items;

  const PasslyBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = PasslyNavItems.defaults,
  });

  static const double _height = 64;

  @override
  Widget build(BuildContext context) {
    // iOS 26 相当のリキッドグラス質感を持たせるため、
    // `liquid_glass_renderer` の LiquidGlass (RoundedSuperellipse) で背景を描く。
    return LiquidGlassLayer(
      settings: const LiquidGlassSettings(
        thickness: 22,
        blur: 10,
        glassColor: Color(0x33FFFFFF),
        lightIntensity: 1.4,
      ),
      child: LiquidGlass(
        // 高さ 64 のピル形状なので borderRadius は half-height (32) にする。
        shape: const LiquidRoundedSuperellipse(borderRadius: 32),
        child: SizedBox(
          height: _height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                _NavItem(
                  item: items[i],
                  active: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PasslyNavItem {
  /// SVG アセットパス (例: `assets/images/nav/home.svg`)。
  ///
  /// アクティブ / 非アクティブの色替えは `ColorFilter.srcIn` で行うため、
  /// SVG 側の元色は任意でよい（1 色の単色アイコン推奨）。
  final String iconAsset;
  final String label;

  const PasslyNavItem({required this.iconAsset, required this.label});
}

/// Passly 標準 4 タブ (Figma 1300:1627 準拠)。
abstract final class PasslyNavItems {
  static const home = PasslyNavItem(
    iconAsset: 'assets/images/nav/home.svg',
    label: 'ホーム',
  );
  static const plaza = PasslyNavItem(
    iconAsset: 'assets/images/nav/plaza.svg',
    label: '広場',
  );
  static const calendar = PasslyNavItem(
    iconAsset: 'assets/images/nav/calendar.svg',
    label: 'カレンダー',
  );
  static const myPage = PasslyNavItem(
    iconAsset: 'assets/images/nav/my_page.svg',
    label: 'マイページ',
  );

  static const List<PasslyNavItem> defaults = [home, plaza, calendar, myPage];
}

class _NavItem extends StatelessWidget {
  final PasslyNavItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? PasslyBrand.primaryLight : PasslyText.secondary;
    // Ink / スプラッシュ / ハイライトなどの視覚的モーションは付けない。
    // タップ時は currentIndex 変化に伴う色替えのみ発生する。
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              item.iconAsset,
              width: 28,
              height: 28,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: PasslyFont.family,
                color: color,
                fontSize: 7,
                height: 6 / 7,
                fontWeight: PasslyFont.semibold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
