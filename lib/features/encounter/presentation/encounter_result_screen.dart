import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/ble/ble_notifier.dart';
import 'package:syshack2026/features/encounter/domain/encounter_model.dart';
import 'package:syshack2026/features/encounter/domain/encounter_notifier.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';

/// すれ違い結果画面。
///
/// Figma node 1100:1602 に準拠。
/// - 自分と相手のアイコンを重ねて表示
/// - 相手の表示名
/// - 「出会った場所」= イベント名（未取得なら非表示）
/// - 「共通タグ」= 自分と相手の tech_stack の積集合（片方でも空なら非表示）
///
/// TODO(passly): 複数件の見せ方は未確定。
/// 現状は最新（先頭）1 件のみ表示している。
/// PageView や横スワイプ切替 / まとめ表示など、UX が決まったら書き換える。
class EncounterResultScreen extends ConsumerWidget {
  const EncounterResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encounterState = ref.watch(encounterNotifierProvider);
    final me = ref.watch(authNotifierProvider).value;

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: encounterState.when(
          data: (encounters) => _buildContent(context, ref, me, encounters),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'すれ違い情報の取得に失敗しました\n$err',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    UserModel? me,
    List<EncounterModel> encounters,
  ) {
    if (encounters.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
      return const SizedBox.shrink();
    }

    // TODO(passly): 複数件の見せ方は未確定。当面は最新 1 件のみ扱う。
    final encounter = encounters.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          const _TitleSection(),
          const SizedBox(height: 40),
          _AvatarPair(myIconUrl: me?.iconUrl ?? '', encounter: encounter),
          const SizedBox(height: 32),
          _EncounteredName(name: encounter.encounteredUser.name),
          const SizedBox(height: 32),
          _InfoCards(myTechStack: me?.techStack ?? '', encounter: encounter),
          const Spacer(),
          _ActionButtons(
            targetUserId: encounter.encounteredUser.id,
            onClose: () async {
              await ref.read(encounterNotifierProvider.notifier).confirmAll();
              ref.read(bleNotifierProvider.notifier).resetEncounterCount();
              if (context.mounted) context.go('/home');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'すれ違いました!',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 28.8 / 24,
          ),
        ),
        SizedBox(height: 9),
        Text(
          'やったね!!',
          style: TextStyle(
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

/// 自分と相手のアイコンを 16px 分だけ重ねて表示するペア。
class _AvatarPair extends StatelessWidget {
  final String myIconUrl;
  final EncounterModel encounter;

  const _AvatarPair({required this.myIconUrl, required this.encounter});

  static const double _avatarSize = 100;
  static const double _overlap = 16;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _avatarSize * 2 - _overlap,
      height: _avatarSize,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _Avatar(iconUrl: myIconUrl),
          ),
          Positioned(
            left: _avatarSize - _overlap,
            top: 0,
            child: _Avatar(iconUrl: encounter.encounteredUser.iconUrl),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String iconUrl;

  const _Avatar({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.backgroundWhite, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(
        child: iconUrl.isNotEmpty
            ? Image.network(
                iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.backgroundGrey,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        color: AppColors.textLight,
        size: 48,
      ),
    );
  }
}

class _EncounteredName extends StatelessWidget {
  final String name;

  const _EncounteredName({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name.isEmpty ? '名前未設定' : name,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        height: 24 / 20,
      ),
    );
  }
}

class _InfoCards extends StatelessWidget {
  final String myTechStack;
  final EncounterModel encounter;

  const _InfoCards({required this.myTechStack, required this.encounter});

  @override
  Widget build(BuildContext context) {
    final commonTags = _commonTags(myTechStack, encounter.encounteredUser.techStack);
    final eventName = encounter.eventName.trim();

    return Column(
      children: [
        if (eventName.isNotEmpty)
          _InfoCard(
            icon: Icons.location_on_outlined,
            label: '出会った場所',
            value: eventName,
            valueColor: AppColors.textPrimary,
          ),
        if (eventName.isNotEmpty && commonTags.isNotEmpty)
          const SizedBox(height: 12),
        if (commonTags.isNotEmpty)
          _InfoCard(
            icon: Icons.local_offer_outlined,
            label: '共通タグ',
            value: commonTags.join(' '),
            valueColor: AppColors.primary,
          ),
      ],
    );
  }

  /// 大文字小文字を無視して積集合を返す。表示順は自分側の順序を維持。
  List<String> _commonTags(String mine, String other) {
    final mineTags = _parseTags(mine);
    final otherTagsLower =
        _parseTags(other).map((t) => t.toLowerCase()).toSet();
    return mineTags
        .where((t) => otherTagsLower.contains(t.toLowerCase()))
        .toList();
  }

  /// カンマ / スラッシュ / 中点 / 空白 で区切られた文字列をタグ配列にする。
  /// profile_screen.dart の tech tag パースと同じロジック。
  List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(RegExp(r'[,、/／・\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
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
      child: Icon(
        icon,
        color: AppColors.textPrimary,
        size: 24,
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String targetUserId;
  final Future<void> Function() onClose;

  const _ActionButtons({required this.targetUserId, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PillButton(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          label: 'プロフィールを見る',
          shadow: BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          onTap: targetUserId.isEmpty
              ? null
              : () => context.push('/profile/$targetUserId'),
        ),
        const SizedBox(height: 9),
        _PillButton(
          backgroundColor: AppColors.backgroundWhite,
          textColor: AppColors.textSecondary,
          label: '閉じる',
          border: Border.all(color: AppColors.divider, width: 1),
          onTap: () async {
            await onClose();
          },
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String label;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final BoxShadow? shadow;

  const _PillButton({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.onTap,
    this.border,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(100),
            border: border,
            boxShadow: shadow == null ? null : [shadow!],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 16.8 / 18,
            ),
          ),
        ),
      ),
    );
  }
}
