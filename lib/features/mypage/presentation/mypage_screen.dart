import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/domain/auth_notifier.dart';
import '../../user/data/user_repository.dart';
import 'widgets/profile_icon_widget.dart';
import 'widgets/name_edit_widget.dart';
import 'widgets/comment_edit_widget.dart';
import 'widgets/stamp_card_item.dart';

/// マイページ本体。ログイン中のユーザー情報を表示し、編集・保存機能を提供
class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String? _imagePath;
  String _name = '';
  String _comment = '';
  String _techStack = '';
  String _twitter = '';
  String _github = '';
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// ログイン中のユーザー情報を読み込む
  Future<void> _loadUserData() async {
    final user = ref.read(authNotifierProvider).value;
    if (user != null) {
      setState(() {
        _name = user.name;
        _comment = user.oneWord;
        _techStack = user.techStack;
        _twitter = user.twitterUrl;
        _github = user.githubUrl;
        _imagePath = user.iconUrl.isNotEmpty ? user.iconUrl : null;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// サーバーにプロフィール情報を保存
  Future<void> _saveToServer(String field, String value) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.updateUser(user.id, {field: value});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存しました'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存に失敗しました: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// URLを開く
  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;

    // URLにプロトコルがなければhttps://を追加
    String fullUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      fullUrl = 'https://$url';
    }

    final uri = Uri.parse(fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URLを開けませんでした')),
        );
      }
    }
  }

  // 汎用テキスト編集ダイアログ
  void _showEditDialog(
    String title,
    String initialValue,
    String serverField,
    ValueChanged<String> onSaved,
  ) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '入力してください'),
          ),
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
                onSaved(controller.text);
                Navigator.pop(context);
                _saveToServer(serverField, controller.text);
              },
              child: const Text(
                '保存',
                style: TextStyle(
                  color: Color(0xFF3AAA3A),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 確認用ダイアログ
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
                  const SizedBox(height: 32),
                  _buildInformationSection(),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                  const SizedBox(height: 48),
                ],
              ),
            ),
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        ProfileIconWidget(
          imagePath: _imagePath,
          onImageSelected: (path) {
            setState(() => _imagePath = path);
            // アイコンURLの保存はファイルアップロード機能が必要なため、ローカルのみ
          },
        ),
        const SizedBox(height: 16),
        NameEditWidget(
          name: _name,
          onSaved: (val) {
            setState(() => _name = val);
            _saveToServer('name', val);
          },
        ),
        const SizedBox(height: 16),
        CommentEditWidget(
          comment: _comment,
          onSaved: (val) {
            setState(() => _comment = val);
            _saveToServer('one_word', val);
          },
        ),
      ],
    );
  }

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
              StampCardItem(onTap: () {}),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildInfoEditItem(
                icon: Icons.code,
                iconBackgroundColor: const Color(0xFF1565C0),
                label: '技術スタック',
                value: _techStack,
                onEdit: () => _showEditDialog(
                  '技術スタックを編集',
                  _techStack,
                  'tech_stack',
                  (val) => setState(() => _techStack = val),
                ),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildLinkEditItem(
                icon: Icons.alternate_email,
                iconBackgroundColor: const Color(0xFF1DA1F2),
                label: 'Twitter',
                value: _twitter,
                onEdit: () => _showEditDialog(
                  'Twitterを編集',
                  _twitter,
                  'twitter_url',
                  (val) => setState(() => _twitter = val),
                ),
                onLaunch: () => _launchUrl(_twitter),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildLinkEditItem(
                icon: Icons.link,
                iconBackgroundColor: const Color(0xFF333333),
                label: 'GitHub',
                value: _github,
                onEdit: () => _showEditDialog(
                  'GitHubを編集',
                  _github,
                  'github_url',
                  (val) => setState(() => _github = val),
                ),
                onLaunch: () => _launchUrl(_github),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 通常の編集アイテム
  Widget _buildInfoEditItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
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
            const Icon(Icons.edit, color: Color(0xFF757575), size: 20),
          ],
        ),
      ),
    );
  }

  /// リンク付き編集アイテム（Twitter/GitHub用）
  Widget _buildLinkEditItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required String label,
    required String value,
    required VoidCallback onEdit,
    required VoidCallback onLaunch,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
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
          // リンクボタン
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
          // 編集ボタン
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Color(0xFF757575), size: 20),
            tooltip: '編集',
          ),
        ],
      ),
    );
  }

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
                    () {},
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
