import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:syshack2026/common/widgets/passly_icon.dart';
import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/core/constants/passly_tokens.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/user/data/user_repository.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';

/// 自分のプロフィール画面 (Figma node 1300:1805 準拠)。
///
/// 上から: カバー写真 (背景) + 半透明ヘッダー (歯車 / 編集ペン) + アバター +
/// 名前 / 一言 / 組織チップ + ABOUT / TECH TAG / LINK / QR。
///
/// 編集ペンをタップすると同じ画面で編集モードに切り替わる (テキストは TextField 化)。
/// 保存すると PATCH /users/:id を呼んで再取得する。
class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isUploadingCover = false;

  /// アップロード直後のローカル一時パス (再取得までのプレビュー用)。
  String? _localAvatarPath;
  String? _localCoverPath;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _oneWordCtrl;
  late final TextEditingController _affiliationCtrl;
  late final TextEditingController _aboutCtrl;
  late final TextEditingController _techStackCtrl;
  late final TextEditingController _twitterCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _portfolioCtrl;
  late final TextEditingController _connpassCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _oneWordCtrl = TextEditingController();
    _affiliationCtrl = TextEditingController();
    _aboutCtrl = TextEditingController();
    _techStackCtrl = TextEditingController();
    _twitterCtrl = TextEditingController();
    _githubCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController();
    _connpassCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _oneWordCtrl.dispose();
    _affiliationCtrl.dispose();
    _aboutCtrl.dispose();
    _techStackCtrl.dispose();
    _twitterCtrl.dispose();
    _githubCtrl.dispose();
    _portfolioCtrl.dispose();
    _connpassCtrl.dispose();
    super.dispose();
  }

  void _enterEditMode(UserModel user) {
    _nameCtrl.text = user.name;
    _oneWordCtrl.text = user.oneWord;
    _affiliationCtrl.text = user.affiliation;
    _aboutCtrl.text = user.about;
    _techStackCtrl.text = user.techStack;
    _twitterCtrl.text = user.twitterUrl;
    _githubCtrl.text = user.githubUrl;
    _portfolioCtrl.text = user.portfolioUrl;
    _connpassCtrl.text = user.connpassUrl;
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  Future<void> _saveAll() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.updateUser(user.id, {
        'name': _nameCtrl.text.isEmpty ? '未設定' : _nameCtrl.text,
        'one_word': _oneWordCtrl.text,
        'affiliation': _affiliationCtrl.text,
        'about': _aboutCtrl.text,
        'tech_stack': _techStackCtrl.text,
        'twitter_url': _twitterCtrl.text,
        'github_url': _githubCtrl.text,
        'portfolio_url': _portfolioCtrl.text,
        'connpass_username': _connpassCtrl.text,
      });
      // 再取得
      await ref.read(authNotifierProvider.notifier).refresh();
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('プロフィールを保存しました'),
            duration: Duration(seconds: 1),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: PasslyState.error,
          ),
        );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _localAvatarPath = picked.path;
      _isUploadingAvatar = true;
    });
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.uploadAvatar(user.id, picked.path);
      await ref.read(authNotifierProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _localAvatarPath = null;
        _isUploadingAvatar = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localAvatarPath = null;
        _isUploadingAvatar = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('画像のアップロードに失敗しました: $e'),
            backgroundColor: PasslyState.error,
          ),
        );
    }
  }

  Future<void> _pickAndUploadCover() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      _localCoverPath = picked.path;
      _isUploadingCover = true;
    });
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.uploadCover(user.id, picked.path);
      await ref.read(authNotifierProvider.notifier).refresh();
      if (!mounted) return;
      setState(() {
        _localCoverPath = null;
        _isUploadingCover = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _localCoverPath = null;
        _isUploadingCover = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('カバー画像のアップロードに失敗しました: $e'),
            backgroundColor: PasslyState.error,
          ),
        );
    }
  }

  Future<void> _launchExternalUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;

    if (user == null) {
      return const Scaffold(
        backgroundColor: PasslyBg.defaultBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: PasslyBg.defaultBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CoverAndAvatar(
                  coverUrl: user.coverUrl,
                  iconUrl: user.iconUrl,
                  localAvatarPath: _localAvatarPath,
                  localCoverPath: _localCoverPath,
                  isUploadingAvatar: _isUploadingAvatar,
                  isUploadingCover: _isUploadingCover,
                  onEditAvatar: _isEditing ? _pickAndUploadAvatar : null,
                  onEditCover: _isEditing ? _pickAndUploadCover : null,
                ),
                const SizedBox(height: 16),
                _NameSection(
                  isEditing: _isEditing,
                  fallbackName: user.name,
                  fallbackOneWord: user.oneWord,
                  fallbackAffiliation: user.affiliation,
                  nameCtrl: _nameCtrl,
                  oneWordCtrl: _oneWordCtrl,
                  affiliationCtrl: _affiliationCtrl,
                ),
                const SizedBox(height: PasslySpace.s24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _AboutSection(
                    isEditing: _isEditing,
                    fallbackAbout: user.about,
                    controller: _aboutCtrl,
                  ),
                ),
                const SizedBox(height: PasslySpace.s24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _TechTagSection(
                    isEditing: _isEditing,
                    fallbackTechStack: user.techStack,
                    controller: _techStackCtrl,
                  ),
                ),
                const SizedBox(height: PasslySpace.s24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 21),
                  child: _LinkSection(
                    isEditing: _isEditing,
                    profile: user,
                    twitterCtrl: _twitterCtrl,
                    githubCtrl: _githubCtrl,
                    portfolioCtrl: _portfolioCtrl,
                    connpassCtrl: _connpassCtrl,
                    onOpen: _launchExternalUrl,
                  ),
                ),
                // QR コードは編集モード中は非表示 (編集対象ではないため)。
                if (!_isEditing) ...[
                  const SizedBox(height: PasslySpace.s24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21),
                    child: _QrShareSection(userId: user.id),
                  ),
                ],
                if (_isEditing) ...[
                  const SizedBox(height: PasslySpace.s24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21),
                    child: _EditActionButtons(
                      isSaving: _isSaving,
                      onCancel: _cancelEdit,
                      onSave: _saveAll,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 半透明のヘッダー: 歯車 + 編集ペン。カバー写真の上に配置する。
          SafeArea(
            child: _FloatingHeader(
              isEditing: _isEditing,
              onEdit: () => _enterEditMode(user),
              onOpenSettings: () => context.push('/settings'),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

/// カバー写真 + 中央に半分乗ったアバターの複合ビュー。
///
/// Figma spec: カバー 275x412 (top -85 で上端にせり出す) + アバター 100x100 中央下寄せ。
class _CoverAndAvatar extends StatelessWidget {
  final String coverUrl;
  final String iconUrl;
  final String? localAvatarPath;
  final String? localCoverPath;
  final bool isUploadingAvatar;
  final bool isUploadingCover;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditCover;

  const _CoverAndAvatar({
    required this.coverUrl,
    required this.iconUrl,
    required this.localAvatarPath,
    required this.localCoverPath,
    required this.isUploadingAvatar,
    required this.isUploadingCover,
    required this.onEditAvatar,
    required this.onEditCover,
  });

  // カバー写真の高さ (Figma: -85 → 190 = 275)。
  static const double _coverHeight = 190;
  static const double _avatarSize = 100;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // アバターが半分下にせり出す分だけ余白を確保。
      height: _coverHeight + _avatarSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: SizedBox(
              height: _coverHeight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _CoverImage(
                        url: coverUrl,
                        localPath: localCoverPath,
                      ),
                    ),
                    if (isUploadingCover)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (onEditCover != null)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onEditCover,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: _coverHeight - _avatarSize / 2,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: _avatarSize,
                height: _avatarSize,
                child: Stack(
                  children: [
                    _AvatarCircle(
                      url: iconUrl,
                      localPath: localAvatarPath,
                    ),
                    if (isUploadingAvatar)
                      Container(
                        width: _avatarSize,
                        height: _avatarSize,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    if (onEditAvatar != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onEditAvatar,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: PasslyBrand.primary,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String url;
  final String? localPath;
  const _CoverImage({required this.url, required this.localPath});

  @override
  Widget build(BuildContext context) {
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _CoverFallback(),
      );
    }
    if (url.isEmpty) return const _CoverFallback();
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _CoverFallback(),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PasslyBrand.primary.withValues(alpha: 0.6),
            PasslyBrand.primary.withValues(alpha: 0.9),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: Colors.white, size: 48),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String url;
  final String? localPath;
  const _AvatarCircle({required this.url, required this.localPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: PasslyBg.surface,
        border: Border.all(color: PasslyBg.surface, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: _buildImage()),
    );
  }

  Widget _buildImage() {
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarFallback(),
      );
    }
    if (url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _AvatarFallback(),
      );
    }
    return const _AvatarFallback();
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: PasslyBg.elevated,
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: PasslyText.tertiary, size: 48),
    );
  }
}

/// Figma のヘッダー (node 1300:1904) 準拠: 上端にせり出したカバー写真の上に、
/// 歯車 + 編集ペン (それぞれ 30x30 角丸15) を右端に並べる透明ヘッダー。
///
/// マイページはボトムナビタブから開くため戻る先が無く Figma の左上戻る
/// ボタンは撤去済み。代わりに歯車ボタンから設定画面へ遷移する。
class _FloatingHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onOpenSettings;

  const _FloatingHeader({
    required this.isEditing,
    required this.onEdit,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    // 編集ペンを左端、歯車を右端に配置。
    return Padding(
      padding: const EdgeInsets.fromLTRB(19, 12, 19, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _EditButton(active: isEditing, onTap: onEdit),
          _CircleIconButton(
            icon: Icons.settings_outlined,
            onTap: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

/// 歯車ボタンなど、divider 背景 + 角丸 15 の 30x30 円形ボタン。
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

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
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _EditButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: active ? PasslyBrand.primarySurface : PasslyBorder.divider,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: PasslyIcon(
          asset: PasslyIcons.edit,
          size: 20,
          color: active ? PasslyBrand.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _NameSection extends StatelessWidget {
  final bool isEditing;
  final String fallbackName;
  final String fallbackOneWord;
  final String fallbackAffiliation;
  final TextEditingController nameCtrl;
  final TextEditingController oneWordCtrl;
  final TextEditingController affiliationCtrl;

  const _NameSection({
    required this.isEditing,
    required this.fallbackName,
    required this.fallbackOneWord,
    required this.fallbackAffiliation,
    required this.nameCtrl,
    required this.oneWordCtrl,
    required this.affiliationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    if (isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          children: [
            _EditField(controller: nameCtrl, hint: '名前'),
            const SizedBox(height: PasslySpace.s8),
            _EditField(controller: oneWordCtrl, hint: '一言'),
            const SizedBox(height: PasslySpace.s8),
            _EditField(controller: affiliationCtrl, hint: '組織 / 所属 (例: 愛工大)'),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text(
          fallbackName.isEmpty ? '未設定' : fallbackName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: PasslyFont.family,
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 24 / 20,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          fallbackOneWord.isEmpty ? '一言未設定' : fallbackOneWord,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: PasslyFont.family,
            color: fallbackOneWord.isEmpty
                ? AppColors.textDisabled
                : PasslyText.secondary,
            fontSize: 14,
            fontWeight: PasslyFont.regular,
            height: 16.8 / 14,
          ),
        ),
        if (fallbackAffiliation.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AffiliationChip(text: fallbackAffiliation),
        ],
      ],
    );
  }
}

/// 組織 / 所属を表す小さめのチップ (Figma node 1242:1429 のタグと同構造)。
class _AffiliationChip extends StatelessWidget {
  final String text;
  const _AffiliationChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: PasslyBorder.strong, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.corporate_fare,
            size: 14,
            color: PasslyText.secondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: PasslyFont.family,
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: PasslyFont.medium,
              height: 14.4 / 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  final bool isEditing;
  final String fallbackAbout;
  final TextEditingController controller;

  const _AboutSection({
    required this.isEditing,
    required this.fallbackAbout,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('ABOUT'),
        const SizedBox(height: PasslySpace.s8),
        if (isEditing)
          _EditField(controller: controller, hint: '自己紹介', maxLines: 4)
        else
          Text(
            fallbackAbout.isEmpty ? '自己紹介は未設定です' : fallbackAbout,
            style: TextStyle(
              fontFamily: PasslyFont.family,
              color: fallbackAbout.isEmpty
                  ? AppColors.textDisabled
                  : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: PasslyFont.medium,
              height: 16.8 / 14,
            ),
          ),
      ],
    );
  }
}

class _TechTagSection extends StatelessWidget {
  final bool isEditing;
  final String fallbackTechStack;
  final TextEditingController controller;

  const _TechTagSection({
    required this.isEditing,
    required this.fallbackTechStack,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('TECH TAG'),
        const SizedBox(height: PasslySpace.s8),
        if (isEditing)
          _EditField(
            controller: controller,
            hint: 'カンマ / スラッシュ / 空白区切りで入力 (例: Go, Flutter)',
          )
        else
          _TagWrap(tags: _parseTags(fallbackTechStack)),
      ],
    );
  }

  static List<String> _parseTags(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(RegExp(r'[,、/／・\s]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
}

class _TagWrap extends StatelessWidget {
  final List<String> tags;
  const _TagWrap({required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Text(
        '未設定',
        style: TextStyle(
          fontFamily: PasslyFont.family,
          color: AppColors.textDisabled,
          fontSize: 12,
          fontWeight: PasslyFont.medium,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final tag in tags) _TagChip(label: tag)],
    );
  }
}

/// Figma node 1242:1429 準拠のタグチップ (Go / Figma / Flutter 等)。
class _TagChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  const _TagChip({required this.label, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 12 : 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: PasslyBg.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: PasslyBorder.strong, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: PasslyText.secondary, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              fontFamily: PasslyFont.family,
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: PasslyFont.medium,
              height: 14.4 / 12,
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: chip,
    );
  }
}

class _LinkSection extends StatelessWidget {
  final bool isEditing;
  final UserModel profile;
  final TextEditingController twitterCtrl;
  final TextEditingController githubCtrl;
  final TextEditingController portfolioCtrl;
  final TextEditingController connpassCtrl;
  final Future<void> Function(String url) onOpen;

  const _LinkSection({
    required this.isEditing,
    required this.profile,
    required this.twitterCtrl,
    required this.githubCtrl,
    required this.portfolioCtrl,
    required this.connpassCtrl,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('LINK'),
        const SizedBox(height: PasslySpace.s8),
        if (isEditing)
          Column(
            children: [
              _EditField(controller: twitterCtrl, hint: 'X (Twitter) ハンドルまたは URL'),
              const SizedBox(height: PasslySpace.s8),
              _EditField(controller: githubCtrl, hint: 'GitHub ハンドルまたは URL'),
              const SizedBox(height: PasslySpace.s8),
              _EditField(controller: portfolioCtrl, hint: 'Portfolio URL'),
              const SizedBox(height: PasslySpace.s8),
              _EditField(controller: connpassCtrl, hint: 'Connpass ハンドル'),
            ],
          )
        else
          _buildChips(),
      ],
    );
  }

  Widget _buildChips() {
    final links = <_LinkEntry>[
      if (profile.twitterUrl.isNotEmpty)
        _LinkEntry(
          label: 'X',
          icon: Icons.alternate_email,
          url: _normalizeTwitterUrl(profile.twitterUrl),
        ),
      if (profile.githubUrl.isNotEmpty)
        _LinkEntry(
          label: 'GitHub',
          icon: Icons.code,
          url: _normalizeGitHubUrl(profile.githubUrl),
        ),
      if (profile.portfolioUrl.isNotEmpty)
        _LinkEntry(
          label: 'Portfolio',
          icon: Icons.link,
          url: profile.portfolioUrl,
        ),
      if (profile.connpassUrl.isNotEmpty)
        _LinkEntry(
          label: 'Connpass',
          icon: Icons.event,
          url: _normalizeConnpassUrl(profile.connpassUrl),
        ),
    ];
    if (links.isEmpty) {
      return const Text(
        '未設定',
        style: TextStyle(
          fontFamily: PasslyFont.family,
          color: AppColors.textDisabled,
          fontSize: 12,
          fontWeight: PasslyFont.medium,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final link in links)
          _TagChip(
            label: link.label,
            icon: link.icon,
            onTap: () => onOpen(link.url),
          ),
      ],
    );
  }

  static String _normalizeTwitterUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    final handle = v.startsWith('@') ? v.substring(1) : v;
    return 'https://x.com/$handle';
  }

  static String _normalizeGitHubUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    if (v.startsWith('github.com/')) return 'https://$v';
    return 'https://github.com/$v';
  }

  static String _normalizeConnpassUrl(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    final username = v.startsWith('@') ? v.substring(1) : v;
    return 'https://connpass.com/user/$username/';
  }
}

class _LinkEntry {
  final String label;
  final IconData icon;
  final String url;

  const _LinkEntry({
    required this.label,
    required this.icon,
    required this.url,
  });
}

class _SectionHeading extends StatelessWidget {
  final String label;
  const _SectionHeading(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: PasslyFont.family,
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        height: 19.2 / 16,
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _EditField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: maxLines == 1 ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        fontFamily: PasslyFont.family,
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: PasslyFont.medium,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: PasslyFont.family,
          color: PasslyText.tertiary,
          fontSize: 14,
          fontWeight: PasslyFont.regular,
        ),
        isDense: true,
        filled: true,
        fillColor: PasslyBg.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PasslyBorder.strong, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PasslyBorder.strong, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: PasslyBrand.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
    );
  }
}

class _EditActionButtons extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onCancel;
  final Future<void> Function() onSave;

  const _EditActionButtons({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: PasslyBorder.strong, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              foregroundColor: AppColors.textPrimary,
            ),
            child: const Text(
              'キャンセル',
              style: TextStyle(
                fontFamily: PasslyFont.family,
                fontSize: 14,
                fontWeight: PasslyFont.medium,
              ),
            ),
          ),
        ),
        const SizedBox(width: PasslySpace.s12),
        Expanded(
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: PasslyBrand.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              isSaving ? '保存中…' : '保存',
              style: const TextStyle(
                fontFamily: PasslyFont.family,
                fontSize: 14,
                fontWeight: PasslyFont.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// プロフィールを QR コードで共有するセクション。
///
/// スキーム: `passly://profile/:userId` (アプリで受けたら該当プロフィール
/// に遷移する想定。当面はスキャン → コピーで手入力運用でも実質機能する)。
class _QrShareSection extends StatelessWidget {
  final String userId;

  const _QrShareSection({required this.userId});

  static const double _previewSize = 140;
  static const double _expandedSize = 280;

  String get _data => 'passly://profile/$userId';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading('QR'),
        const SizedBox(height: PasslySpace.s8),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _showExpanded(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PasslyBg.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PasslyBorder.strong, width: 1),
              ),
              child: Column(
                children: [
                  QrImageView(
                    data: _data,
                    size: _previewSize,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.textPrimary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'タップで拡大',
                    style: TextStyle(
                      fontFamily: PasslyFont.family,
                      color: PasslyText.secondary,
                      fontSize: 11,
                      fontWeight: PasslyFont.medium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showExpanded(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: PasslyBg.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: _data,
                  size: _expandedSize,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.textPrimary,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '@$userId',
                  style: const TextStyle(
                    fontFamily: PasslyFont.family,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: PasslyFont.medium,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'このコードをスキャンしてプロフィール共有',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: PasslyFont.family,
                    color: PasslyText.secondary,
                    fontSize: 12,
                    fontWeight: PasslyFont.regular,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
