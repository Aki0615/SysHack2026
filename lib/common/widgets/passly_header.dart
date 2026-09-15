import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// Passly 共通ヘッダー。
///
/// Figma のヘッダーコンポーネント（node 1076:695 内 Component）で
/// 定義されている 5 バリアントを、フレキシブルな API で表現する:
/// - ホームヘッダー: title=おかえり！, subtitle=..., trailing=avatar
/// - カレンダーヘッダー: title=カレンダー, subtitle=..., trailing=[search, avatar]
/// - 相手プロフィールヘッダー: leading=戻る（円形グレー）
/// - 自分のプロフィールヘッダー: leading=戻る + trailing=[pen]
/// - 検索ヘッダー: leading=戻る（角丸小）+ 検索フィールド
/// - 出会った人一覧: title=その日に出会った人 + subtitle=気になる人を見つけよう！
///
/// 各画面はこのヘッダーを組み合わせて使う。詳細は README 参照。
class PasslyHeader extends StatelessWidget {
  /// 左端に置くウィジェット（例: 戻るボタン、なし）
  final Widget? leading;

  /// 大見出し（H1 24px w900）
  final String? title;

  /// 副見出し（14px w500 secondary）
  final String? subtitle;

  /// タイトル領域の代わりに任意ウィジェット（例: 検索フィールド全体）を差し込む場合に使う。
  /// これが与えられている場合、title / subtitle は無視される。
  final Widget? centerContent;

  /// 右端に並べるウィジェット群（例: 検索アイコン、アバター、ペン）
  final List<Widget> trailing;

  /// 下線 divider を表示するか
  final bool showBottomDivider;

  const PasslyHeader({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.centerContent,
    this.trailing = const [],
    this.showBottomDivider = true,
  }) : assert(
         title != null || centerContent != null || leading != null,
         'PasslyHeader には title / centerContent / leading のいずれかを与える必要があります',
       );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: showBottomDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              )
            : null,
      ),
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(child: _buildCenter()),
          for (final w in trailing) ...[const SizedBox(width: 8), w],
        ],
      ),
    );
  }

  Widget _buildCenter() {
    if (centerContent != null) return centerContent!;
    if (title == null && subtitle == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (title != null)
          Text(
            title!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 28.8 / 24,
            ),
          ),
        if (title != null && subtitle != null) const SizedBox(height: 4),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 16.8 / 14,
            ),
          ),
      ],
    );
  }
}

/// Figma のプロフィール系ヘッダーで使う「丸型グレー背景の戻るボタン」。
class PasslyBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const PasslyBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.divider,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}
