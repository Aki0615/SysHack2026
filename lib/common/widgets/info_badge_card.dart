import 'package:flutter/material.dart';

import 'package:syshack2026/core/constants/app_colors.dart';

/// Figma node 1076:695 の Component5「出会った場所」「共通タグ」で
/// 定義されている情報カード。
///
/// - 高さ 72px / 角丸 23 / bg backgroundGrey + border divider
/// - 左端に白い正方形アイコンバッジ（48x48、角丸 15、薄いドロップシャドウ）
/// - 右側に ラベル（Bold 14 secondary）+ 値（SemiBold 14）を縦積み
///
/// すれ違い結果画面 / プロフィール画面などで再利用する。
class InfoBadgeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  /// 値の文字色。デフォルトは textPrimary（黒）。
  /// 共通タグ表示など強調したい場合は AppColors.primary などを渡す。
  final Color valueColor;

  const InfoBadgeCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
      child: Row(
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 16.8 / 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: valueColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 16.8 / 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppColors.textPrimary, size: 24),
    );
  }
}
