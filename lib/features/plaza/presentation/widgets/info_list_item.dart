import 'package:flutter/material.dart';

/// プロフィール画面の各種情報リスト用アイテムWidget
class InfoListItem extends StatelessWidget {
  /// 左端に表示するアイコン
  final IconData icon;

  /// アイコンの背景色
  final Color iconBackgroundColor;

  /// 項目名（「技術スタック」「Twitter」など）
  final String title;

  /// 項目の値
  final String value;

  /// URLかどうか（trueなら右端に矢印アイコンを表示）
  final bool isUrl;

  /// 下部のDividerを表示するかどうか（最後のアイテムはfalseにする想定）
  final bool showDivider;

  const InfoListItem({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.title,
    required this.value,
    this.isUrl = false,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 左: アイコン（円形背景）
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              // 中央: 項目名と値
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // 右: 矢印アイコン（URLの場合のみ）
              if (isUrl) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
              ],
            ],
          ),
        ),
        // Divider
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: Color(0xFFE0E0E0),
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }
}
