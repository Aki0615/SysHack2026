import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/domain/auth_notifier.dart';
import '../data/mypage_dummy_data.dart';
import 'widgets/profile_icon_widget.dart';
import 'widgets/name_edit_widget.dart';
import 'widgets/comment_edit_widget.dart';
import 'widgets/info_edit_item.dart';
import 'widgets/stamp_card_item.dart';

/// マイページ本体。ステート（ダミー）を保持してUI更新を即座に反映します。
class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  String? _imagePath;
  String _name = dummyName;
  String _comment = dummyComment;
  String _techStack = dummyTechStack;
  String _twitter = dummyTwitter;
  String _github = dummyGitHub;

  // 汎用テキスト編集ダイアログ（情報行の一括管理用）
  void _showEditDialog(
    String title,
    String initialValue,
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      // AppBarなし、SafeAreaで上部余白を確保
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 32),
              _buildInformationSection(),
              const SizedBox(height: 32),
              _buildSettingsSection(),
              // 一番下にスクロール用の余白
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        ProfileIconWidget(
          imagePath: _imagePath,
          onImageSelected: (path) => setState(() => _imagePath = path),
        ),
        const SizedBox(height: 16),
        NameEditWidget(
          name: _name,
          onSaved: (val) => setState(() => _name = val),
        ),
        const SizedBox(height: 16),
        CommentEditWidget(
          comment: _comment,
          onSaved: (val) => setState(() => _comment = val),
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
              StampCardItem(onTap: () {}), // タップ時は何もしないか、実績画面へのルーティング処理
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              InfoEditItem(
                icon: Icons.code,
                iconBackgroundColor: const Color(0xFF1565C0),
                label: '技術スタック',
                value: _techStack,
                onEdit: () => _showEditDialog(
                  '技術スタックを編集',
                  _techStack,
                  (val) => setState(() => _techStack = val),
                ),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              InfoEditItem(
                icon: Icons.alternate_email,
                iconBackgroundColor: const Color(0xFF1DA1F2),
                label: 'Twitter',
                value: _twitter,
                onEdit: () => _showEditDialog(
                  'Twitterを編集',
                  _twitter,
                  (val) => setState(() => _twitter = val),
                ),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              InfoEditItem(
                icon: Icons.link,
                iconBackgroundColor: const Color(0xFF333333),
                label: 'GitHub',
                value: _github,
                onEdit: () => _showEditDialog(
                  'GitHubを編集',
                  _github,
                  (val) => setState(() => _github = val),
                ),
              ),
            ],
          ),
        ),
      ],
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
