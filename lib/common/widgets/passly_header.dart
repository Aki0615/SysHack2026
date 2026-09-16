import 'package:flutter/material.dart';

import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';

/// Passly 共通ヘッダー。
///
/// Figma のヘッダー ComponentSet (node 1191:1101) の 6 バリアントを
/// 名前付きコンストラクタで提供する:
/// - [PasslyHeader.home]           : おかえり！+ サブタイトル + アバター
/// - [PasslyHeader.calendar]       : カレンダー + サブタイトル + 検索 + アバター
/// - [PasslyHeader.otherProfile]   : 戻るボタンのみ（円形）
/// - [PasslyHeader.myProfile]      : 戻る + 編集ペン
/// - [PasslyHeader.search]         : 戻る（角丸小）+ 検索フィールド
/// - [PasslyHeader.encounteredList]: その日に出会った人 + サブタイトル
///
/// 既存のフレキシブル API（title / subtitle / leading / centerContent / trailing）は
/// そのまま利用可能。既存呼び出し側との後方互換を保つ。
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

  /// ホームヘッダー (Figma node 1110:2236)。
  /// 「おかえり！」+ サブタイトル + 右端にアバター。
  factory PasslyHeader.home({
    Key? key,
    String? avatarUrl,
    VoidCallback? onAvatarTap,
    String title = 'おかえり！',
    String subtitle = '今日の出会いを見てみよう',
  }) {
    return PasslyHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      trailing: [_HeaderAvatar(url: avatarUrl, onTap: onAvatarTap)],
    );
  }

  /// カレンダーヘッダー (Figma node 1191:1102)。
  /// 「カレンダー」+ サブタイトル + 検索アイコン。
  factory PasslyHeader.calendar({
    Key? key,
    VoidCallback? onSearchTap,
    String title = 'カレンダー',
    String subtitle = 'その日の記録',
  }) {
    return PasslyHeader(
      key: key,
      title: title,
      subtitle: subtitle,
      trailing: [_HeaderSearchIcon(onTap: onSearchTap)],
    );
  }

  /// 相手のプロフィールヘッダー (Figma node 1269:521)。
  /// 円形の戻るボタンのみ。divider・タイトルなし。
  factory PasslyHeader.otherProfile({
    Key? key,
    required VoidCallback onBack,
  }) {
    return PasslyHeader(
      key: key,
      leading: PasslyBackButton(onTap: onBack),
      showBottomDivider: false,
    );
  }

  /// 自分のプロフィールヘッダー (Figma node 1300:1904)。
  /// 戻るボタン + 右端に編集ペンボタン。divider なし。
  factory PasslyHeader.myProfile({
    Key? key,
    required VoidCallback onBack,
    required VoidCallback onEdit,
  }) {
    return PasslyHeader(
      key: key,
      leading: PasslyBackButton(onTap: onBack),
      trailing: [_HeaderEditButton(onTap: onEdit)],
      showBottomDivider: false,
    );
  }

  /// 検索ヘッダー (Figma node 1297:859)。
  /// 角丸小の戻るボタン + 検索フィールド。
  factory PasslyHeader.search({
    Key? key,
    required VoidCallback onBack,
    TextEditingController? controller,
    String hintText = 'なんかいい感じの検索',
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return PasslyHeader(
      key: key,
      leading: _SmallBackButton(onTap: onBack),
      centerContent: _HeaderSearchField(
        controller: controller,
        hintText: hintText,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
      ),
    );
  }

  /// 出会った人一覧ヘッダー (Figma node 1300:1257)。
  /// 「その日に出会った人」+ サブタイトル。leading / trailing なし。
  factory PasslyHeader.encounteredList({
    Key? key,
    String title = 'その日に出会った人',
    String subtitle = '気になる人を見つけよう！',
  }) {
    return PasslyHeader(key: key, title: title, subtitle: subtitle);
  }

  @override
  Widget build(BuildContext context) {
    // 白背景 + divider は SafeArea の外側 (DecoratedBox) に置く。
    // これで背景がステータスバー / Dynamic Island 領域まで完全に延びる。
    // SafeArea はコンテンツ (Row) の位置を top padding 分だけ押し下げる用途のみ。
    // 呼び出し側が SafeArea 内に置いていた場合は top padding が 0 になるだけ。
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: showBottomDivider
            ? const Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Container(
          height: 110,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(child: _buildCenter()),
              for (final w in trailing) ...[const SizedBox(width: 8), w],
            ],
          ),
        ),
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
///
/// Figma node 1269:520 準拠: 30x30 divider 背景 + chevron (左向き)。
class PasslyBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const PasslyBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: PasslyBorder.divider,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const PasslyIcon(
          asset: PasslyIcons.chevron,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// 検索ヘッダー用の一回り小さい角丸戻るボタン。
///
/// Figma node 1297:873 準拠: 22.84x22.84 角丸11.42 divider 背景。
class _SmallBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SmallBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 23,
        height: 23,
        decoration: BoxDecoration(
          color: PasslyBorder.divider,
          borderRadius: BorderRadius.circular(11.42),
        ),
        alignment: Alignment.center,
        child: const PasslyIcon(
          asset: PasslyIcons.chevron,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// ホーム/カレンダーヘッダー右端の丸型アバター（40x40）。
class _HeaderAvatar extends StatelessWidget {
  final String? url;
  final VoidCallback? onTap;

  const _HeaderAvatar({required this.url, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget avatar = ClipOval(
      child: SizedBox(
        width: 40,
        height: 40,
        child: url != null
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _AvatarFallback(),
              )
            : const _AvatarFallback(),
      ),
    );
    if (onTap != null) {
      avatar = InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: avatar,
      );
    }
    return avatar;
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PasslyBg.elevated,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: PasslyText.tertiary, size: 24),
    );
  }
}

/// カレンダーヘッダーの検索アイコン (Figma node 1191:1108, 35px)。
class _HeaderSearchIcon extends StatelessWidget {
  final VoidCallback? onTap;

  const _HeaderSearchIcon({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox(
        width: 35,
        height: 35,
        child: Center(
          child: PasslyIcon(
            asset: PasslyIcons.search,
            size: 30,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// 自分プロフィールヘッダーの編集ペンボタン (Figma node 1300:1909)。
///
/// 30x30 角丸15 divider 背景 + 24px ペンアイコン。
class _HeaderEditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HeaderEditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: PasslyBorder.divider,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: const PasslyIcon(
          asset: PasslyIcons.edit,
          size: 20,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// 検索ヘッダー中央の検索フィールド (Figma node 1297:877)。
class _HeaderSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const _HeaderSearchField({
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: PasslyBorder.divider,
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: PasslyBorder.strong, width: 0.9),
      ),
      child: Row(
        children: [
          const PasslyIcon(
            asset: PasslyIcons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 12.6,
                color: AppColors.textPrimary,
                height: 15.14 / 12.6,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 12.6,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
