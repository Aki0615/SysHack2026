import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:syshack2026/common/widgets/passly_header.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/ble/ble_notifier.dart';
import 'package:syshack2026/features/user/data/user_repository.dart';

/// アプリの設定画面。マイページ右上の歯車ボタンから遷移する。
///
/// 内容:
/// - すれ違い検知 (BLE) の ON/OFF トグル
/// - 利用規約 / プライバシーポリシー (外部リンク)
/// - ログアウト
/// - アカウント削除
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _termsUrl = 'https://example.com/terms';
  static const String _privacyUrl = 'https://example.com/privacy';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bleState = ref.watch(bleNotifierProvider);
    final bleActive = bleState.isScanning || bleState.isAdvertising;

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Column(
        children: [
          PasslyHeader(
            leading: PasslyBackButton(
              onTap: () {
                if (context.canPop()) context.pop();
              },
            ),
            title: '設定',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(15, 24, 15, 120),
              children: [
                _SectionLabel('すれ違い検知'),
                _SettingsCard(
                  children: [
                    _ToggleRow(
                      title: 'すれ違いを検知する',
                      subtitle:
                          'オフにすると Bluetooth のスキャン / 発信を一時停止します',
                      value: bleActive,
                      onChanged: (next) => _toggleBle(context, ref, next),
                    ),
                  ],
                ),
                const SizedBox(height: PasslySpace.s24),
                _SectionLabel('その他'),
                _SettingsCard(
                  children: [
                    _LinkRow(
                      icon: Icons.description_outlined,
                      label: '利用規約',
                      onTap: () => _launchUrl(_termsUrl),
                    ),
                    const _Divider(),
                    _LinkRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'プライバシーポリシー',
                      onTap: () => _launchUrl(_privacyUrl),
                    ),
                  ],
                ),
                const SizedBox(height: PasslySpace.s24),
                _SectionLabel('アカウント'),
                _SettingsCard(
                  children: [
                    _LinkRow(
                      icon: Icons.logout,
                      label: 'ログアウト',
                      onTap: () => _confirmAndLogout(context, ref),
                    ),
                    const _Divider(),
                    _LinkRow(
                      icon: Icons.delete_outline,
                      label: 'アカウント削除',
                      color: PasslyState.error,
                      onTap: () => _confirmAndDeleteAccount(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleBle(
    BuildContext context,
    WidgetRef ref,
    bool next,
  ) async {
    final notifier = ref.read(bleNotifierProvider.notifier);
    try {
      if (next) {
        await notifier.start();
      } else {
        await notifier.stop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                next
                    ? 'すれ違い検知の開始に失敗しました: $e'
                    : 'すれ違い検知の停止に失敗しました: $e',
              ),
              backgroundColor: PasslyState.error,
            ),
          );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _confirmAndLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: 'ログアウトしますか？',
      confirmLabel: 'ログアウト',
      isDestructive: false,
    );
    if (confirmed != true) return;
    await ref.read(authNotifierProvider.notifier).logout();
    if (context.mounted) context.go('/login');
  }

  Future<void> _confirmAndDeleteAccount(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: '本当にアカウントを削除しますか？',
      message: 'この操作は取り消せません。すれ違い履歴や親しい友達などの情報が全て消えます。',
      confirmLabel: '削除する',
      isDestructive: true,
    );
    if (confirmed != true) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;
    try {
      await ref.read(userRepositoryProvider).deleteUser(user.id);
      await ref.read(authNotifierProvider.notifier).logout();
      if (context.mounted) context.go('/login');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('アカウント削除に失敗しました: $e'),
              backgroundColor: PasslyState.error,
            ),
          );
      }
    }
  }

  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required String title,
    String? message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isDestructive ? PasslyState.error : PasslyBrand.primary,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: PasslyFont.family,
          color: PasslyText.secondary,
          fontSize: 12,
          fontWeight: PasslyFont.semibold,
          height: 14.4 / 12,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PasslyBorder.divider, width: 1),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: PasslyBorder.divider, height: 1, thickness: 1),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fg = color ?? AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: PasslyFont.family,
                  color: fg,
                  fontSize: 14,
                  fontWeight: PasslyFont.medium,
                  height: 16.8 / 14,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: PasslyText.tertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: PasslyFont.family,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: PasslyFont.medium,
                    height: 16.8 / 14,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: PasslyFont.family,
                      color: PasslyText.secondary,
                      fontSize: 12,
                      fontWeight: PasslyFont.regular,
                      height: 14.4 / 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PasslyBrand.primary,
          ),
        ],
      ),
    );
  }
}
