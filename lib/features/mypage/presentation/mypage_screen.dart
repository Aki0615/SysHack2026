import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../user/data/user_repository.dart';
import 'widgets/profile_icon_widget.dart';
import 'widgets/stamp_card_item.dart';

/// マイページ本体
/// 閲覧モードと編集モードを切り替え、編集モードでは全項目を一括で編集・保存する
class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  // --- 表示用（現在の確定値）---
  String? _imagePath; // ローカルファイルパス（表示用）
  String? _imageUrl; // Firebase URL
  String _name = '';
  String _comment = '';
  String _techStack = '';
  String _affiliation = '';
  String _twitter = '';
  String _github = '';
  String _connpass = '';

  // --- 編集用（一時バッファ）---
  late TextEditingController _nameCtrl;
  late TextEditingController _commentCtrl;
  late TextEditingController _techStackCtrl;
  late TextEditingController _affiliationCtrl;
  late TextEditingController _twitterCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _connpassCtrl;

  // --- 状態フラグ ---
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploading = false;
  bool _isEditing = false; // true: 編集モード, false: 閲覧モード

  @override
  void initState() {
    super.initState();
    // テキストコントローラーの初期化
    _nameCtrl = TextEditingController();
    _commentCtrl = TextEditingController();
    _techStackCtrl = TextEditingController();
    _affiliationCtrl = TextEditingController();
    _twitterCtrl = TextEditingController();
    _githubCtrl = TextEditingController();
    _connpassCtrl = TextEditingController();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _commentCtrl.dispose();
    _techStackCtrl.dispose();
    _affiliationCtrl.dispose();
    _twitterCtrl.dispose();
    _githubCtrl.dispose();
    _connpassCtrl.dispose();
    super.dispose();
  }

  /// ログイン中のユーザー情報を読み込む
  Future<void> _loadUserData() async {
    final user = ref.read(authNotifierProvider).value;
    if (user != null) {
      setState(() {
        // データがない場合はデフォルト値を設定（?? '' でフォールバック）
        _name = user.name.isNotEmpty ? user.name : '';
        _comment = user.oneWord.isNotEmpty ? user.oneWord : '';
        _techStack = user.techStack.isNotEmpty ? user.techStack : '';
        _affiliation = user.affiliation.isNotEmpty ? user.affiliation : '';
        _twitter = user.twitterUrl.isNotEmpty ? user.twitterUrl : '';
        _github = user.githubUrl.isNotEmpty ? user.githubUrl : '';
        _connpass = user.connpassUrl.isNotEmpty ? user.connpassUrl : '';
        _imageUrl = user.iconUrl.isNotEmpty ? user.iconUrl : null;
        _imagePath = null;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// 画像が選択されたときの処理（アップロード実行）
  Future<void> _handleImageSelected(String localPath) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ユーザー情報が見つかりません')));
      }
      return;
    }

    setState(() {
      _imagePath = localPath; // 一時的にローカルパスを表示用に設定
      _isUploading = true;
    });

    try {
      final repo = ref.read(userRepositoryProvider);
      final uploadedUrl = await repo.uploadAvatar(user.id, localPath);

      setState(() {
        _imageUrl = uploadedUrl;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('画像をアップロードしました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _imagePath = null;
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('画像のアップロードに失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 編集モードに切り替える（コントローラーに現在の値をセット）
  void _enterEditMode() {
    setState(() {
      _isEditing = true;
      _nameCtrl.text = _name;
      _commentCtrl.text = _comment;
      _techStackCtrl.text = _techStack;
      _affiliationCtrl.text = _affiliation;
      _twitterCtrl.text = _twitter;
      _githubCtrl.text = _github;
      _connpassCtrl.text = _connpass;
    });
  }

  /// 編集をキャンセルして閲覧モードに戻る
  void _cancelEdit() {
    setState(() => _isEditing = false);
  }

  /// 全項目を一括でサーバーに保存する
  Future<void> _saveAll() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userRepositoryProvider);

      // すべてのフィールドを送信（空のフィールドも含む）
      // これにより「削除」の意思が正しく伝わる
      final updateData = <String, dynamic>{
        'name': _nameCtrl.text.isEmpty ? '未設定' : _nameCtrl.text,
        'one_word': _commentCtrl.text, // 空でも送信（削除の意思を表現）
        'tech_stack': _techStackCtrl.text, // 空でも送信
        'affiliation': _affiliationCtrl.text,
        'twitter_url': _twitterCtrl.text,   // 空でも送信
        'github_url': _githubCtrl.text,     // 空でも送信
        'connpass_username': _connpassCtrl.text, // 空でも送信
      };

      // デバッグ: 送信データを表示
      print('Sending update data: $updateData');

      // フィールドを送信
      await repo.updateUser(user.id, updateData);

      // 保存成功後、表示を更新して閲覧モードへ
      setState(() {
        _name = _nameCtrl.text.isEmpty ? '未設定' : _nameCtrl.text;
        _comment = _commentCtrl.text;
        _techStack = _techStackCtrl.text;
        _affiliation = _affiliationCtrl.text;
        _twitter = _twitterCtrl.text;
        _github = _githubCtrl.text;
        _connpass = _connpassCtrl.text;
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('プロフィールを保存しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // エラー詳細を表示
        print('Save error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// URLを外部ブラウザで開く
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URL形式が不正です')));
      }
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('URLを開けませんでした')));
      }
    }
  }

  String _normalizeTwitterUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final handle = value.startsWith('@') ? value.substring(1) : value;
    return 'https://x.com/$handle';
  }

  String _normalizeGitHubUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('github.com/')) {
      return 'https://$value';
    }
    return 'https://github.com/$value';
  }

  String _normalizeConnpassUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final username = value.startsWith('@') ? value.substring(1) : value;
    return 'https://connpass.com/user/$username/';
  }

  /// 確認用ダイアログ（ログアウト・削除用）
  void _showConfirmDialog(
    String title,
    String confirmLabel,
    Color confirmColor,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Color(0xFF757575)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              child: Text(
                confirmLabel,
                style: TextStyle(
                  color: confirmColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// アカウント削除処理
  Future<void> _handleDeleteAccount() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.deleteUser(user.id);

      // 削除成功後、ログアウトしてログイン画面へ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('アカウントを削除しました'),
            backgroundColor: Color(0xFF3AAA3A),
          ),
        );
      }
      ref.read(authNotifierProvider.notifier).logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('削除に失敗しました: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ═══════════════════════════════════════════════════════
  //  ビルド
  // ═══════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildEditButton(),
                  const SizedBox(height: 24),
                  _buildInformationSection(),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
            // 保存中のオーバーレイ
            if (_isSaving)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  プロフィールヘッダー（アイコン・名前・一言）
  // ─────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // アイコン（編集モードでもタップ可能）
        Stack(
          alignment: Alignment.center,
          children: [
            ProfileIconWidget(
              imagePath: _imagePath,
              imageUrl: _imageUrl,
              onImageSelected: _handleImageSelected,
            ),
            // アップロード中のオーバーレイ
            if (_isUploading)
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // 名前
        _isEditing ? _buildNameField() : _buildNameLabel(),
        const SizedBox(height: 12),
        // 一言コメント
        _isEditing ? _buildCommentField() : _buildCommentLabel(),
      ],
    );
  }

  /// 閲覧モード: 名前テキスト
  Widget _buildNameLabel() {
    return Text(
      _name.isEmpty ? '名前を入力' : _name,
      style: TextStyle(
        color: _name.isEmpty
            ? const Color(0xFF9E9E9E)
            : const Color(0xFF1A1A1A),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// 編集モード: 名前入力フィールド
  Widget _buildNameField() {
    return TextField(
      controller: _nameCtrl,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: '名前を入力',
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A), width: 2),
        ),
      ),
    );
  }

  /// 閲覧モード: 一言テキスト（カプセル型背景）
  Widget _buildCommentLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        _comment.isEmpty ? '一言を入力' : _comment,
        style: TextStyle(
          color: _comment.isEmpty
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF1A1A1A),
          fontSize: 14,
        ),
      ),
    );
  }

  /// 編集モード: 一言入力フィールド
  Widget _buildCommentField() {
    return TextField(
      controller: _commentCtrl,
      textAlign: TextAlign.center,
      maxLines: 2,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
      decoration: InputDecoration(
        hintText: '一言を入力',
        hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Color(0xFF3AAA3A), width: 2),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  編集する / すべて保存 / キャンセル ボタン
  // ─────────────────────────────────────────────────────

  Widget _buildEditButton() {
    if (_isEditing) {
      // 編集モード: 「すべて保存」と「キャンセル」ボタン
      return Row(
        children: [
          // キャンセルボタン
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelEdit,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFF757575)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'キャンセル',
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // すべて保存ボタン
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AAA3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'すべて保存',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    // 閲覧モード: 「編集する」ボタン
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _enterEditMode,
        icon: const Icon(Icons.edit, size: 18),
        label: const Text(
          '編集する',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3AAA3A),
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFF3AAA3A)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────
  //  MY INFORMATION セクション
  // ─────────────────────────────────────────────────────

  Widget _buildInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MY INFORMATION',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // スタンプカード（モードに関係なく常に表示）
              StampCardItem(onTap: () => context.push('/stamp-card')),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              // 技術スタック
              _isEditing
                  ? _buildEditField(
                      icon: Icons.code,
                      iconColor: const Color(0xFF1565C0),
                      label: '技術スタック',
                      controller: _techStackCtrl,
                    )
                  : _buildViewItem(
                      icon: Icons.code,
                      iconColor: const Color(0xFF1565C0),
                      label: '技術スタック',
                      value: _techStack,
                    ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              // 所属団体
              _isEditing
                  ? _buildEditField(
                      icon: Icons.business,
                      iconColor: const Color(0xFFFF6F00),
                      label: '所属団体',
                      controller: _affiliationCtrl,
                    )
                  : _buildViewItem(
                      icon: Icons.business,
                      iconColor: const Color(0xFFFF6F00),
                      label: '所属団体',
                      value: _affiliation,
                    ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              // Twitter
              _isEditing
                  ? _buildEditField(
                      icon: Icons.alternate_email,
                      iconColor: const Color(0xFF1DA1F2),
                      label: 'Twitter',
                      controller: _twitterCtrl,
                    )
                  : _buildLinkItem(
                      icon: Icons.alternate_email,
                      iconColor: const Color(0xFF1DA1F2),
                      label: 'Twitter',
                      value: _twitter,
                      onLaunch: () => _launchUrl(_normalizeTwitterUrl(_twitter)),
                    ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              // GitHub
              _isEditing
                  ? _buildEditField(
                      icon: Icons.link,
                      iconColor: const Color(0xFF333333),
                      label: 'GitHub',
                      controller: _githubCtrl,
                    )
                  : _buildLinkItem(
                      icon: Icons.link,
                      iconColor: const Color(0xFF333333),
                      label: 'GitHub',
                      value: _github,
                      onLaunch: () => _launchUrl(_normalizeGitHubUrl(_github)),
                    ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              // Connpass
              _isEditing
                  ? _buildEditField(
                      icon: Icons.event,
                      iconColor: const Color(0xFFE53935),
                      label: 'Connpass',
                      controller: _connpassCtrl,
                    )
                  : _buildLinkItem(
                      icon: Icons.event,
                      iconColor: const Color(0xFFE53935),
                      label: 'Connpass',
                      value: _connpass,
                    onLaunch: () =>
                      _launchUrl(_normalizeConnpassUrl(_connpass)),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  /// 閲覧モード: 通常の表示アイテム
  Widget _buildViewItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconCircle(icon, iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '未設定' : value,
                  style: TextStyle(
                    color: value.isEmpty
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF1A1A1A),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 閲覧モード: リンク付きアイテム（Twitter/GitHub）
  Widget _buildLinkItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onLaunch,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildIconCircle(icon, iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: value.isNotEmpty ? onLaunch : null,
                  child: Text(
                    value.isEmpty ? '未設定' : value,
                    style: TextStyle(
                      color: value.isEmpty
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF1565C0),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      decoration: value.isNotEmpty
                          ? TextDecoration.underline
                          : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (value.isNotEmpty)
            IconButton(
              onPressed: onLaunch,
              icon: const Icon(
                Icons.open_in_new,
                color: Color(0xFF1565C0),
                size: 20,
              ),
              tooltip: '開く',
            ),
        ],
      ),
    );
  }

  /// 編集モード: テキスト入力フィールド付きアイテム
  Widget _buildEditField({
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconCircle(icon, iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 12,
                ),
                hintText: '$labelを入力',
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF3AAA3A),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 共通のアイコン丸（左側のカラーアイコン）
  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // ─────────────────────────────────────────────────────
  //  SETTINGS セクション（変更なし）
  // ─────────────────────────────────────────────────────

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SETTINGS',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildSettingsRow(
                Icons.open_in_new,
                '利用規約',
                const Color(0xFF757575),
                const Color(0xFF1A1A1A),
                trailing: Icons.chevron_right,
                onTap: () => _launchUrl('https://example.com/terms'),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildSettingsRow(
                Icons.open_in_new,
                'プライバシーポリシー',
                const Color(0xFF757575),
                const Color(0xFF1A1A1A),
                trailing: Icons.chevron_right,
                onTap: () => _launchUrl('https://example.com/privacy'),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildSettingsRow(
                Icons.logout,
                'ログアウト',
                const Color(0xFF757575),
                const Color(0xFF1A1A1A),
                onTap: () {
                  _showConfirmDialog(
                    'ログアウトしますか？',
                    'ログアウト',
                    const Color(0xFFE53935),
                    () {
                      ref.read(authNotifierProvider.notifier).logout();
                    },
                  );
                },
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildSettingsRow(
                Icons.delete,
                'アカウント削除',
                const Color(0xFFE53935),
                const Color(0xFFE53935),
                onTap: () {
                  _showConfirmDialog(
                    '本当に削除しますか？\n（この操作は取り消せません）',
                    '削除する',
                    const Color(0xFFE53935),
                    _handleDeleteAccount,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(
    IconData icon,
    String text,
    Color iconColor,
    Color textColor, {
    IconData? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
            if (trailing != null)
              Icon(trailing, color: const Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }
}
