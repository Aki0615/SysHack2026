import 'package:flutter/material.dart';
import '../../plaza/data/plaza_dummy_data.dart';
import 'widgets/info_list_item.dart';

/// プロフィール画面Widget
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーデータを取得
    final profile = dummyProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      // 戻るボタンのみのAppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(color: Color(0xFF1A1A1A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // 上部: プロフィールヘッダー
            _buildHeader(profile),
            const SizedBox(height: 32),
            // 下部: 情報リスト
            _buildInfoList(profile),
          ],
        ),
      ),
    );
  }

  /// プロフィールヘッダー（アイコン、名前、一言コメント）
  Widget _buildHeader(Map<String, String> profile) {
    return Column(
      children: [
        // 円形アイコン（96px）
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x1A3AAA3A),
            border: Border.all(color: const Color(0xFF3AAA3A), width: 3),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 48),
        ),
        const SizedBox(height: 16),
        // ユーザー名
        Text(
          profile['name'] ?? '',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // 一言コメント（カプセル型）
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x1A3AAA3A),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            profile['comment'] ?? '',
            style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// 情報リストセクション
  Widget _buildInfoList(Map<String, String> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // セクションタイトル
        const Text(
          'INFORMATION',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // 情報カード
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 技術スタック
              InfoListItem(
                icon: Icons.code,
                iconBackgroundColor: const Color(0xFF1565C0),
                title: '技術スタック',
                value: profile['techStack'] ?? '',
              ),
              // Twitter
              InfoListItem(
                icon: Icons.alternate_email,
                iconBackgroundColor: const Color(0xFF1DA1F2),
                title: 'Twitter',
                value: profile['twitter'] ?? '',
                isUrl: true,
              ),
              // GitHub
              InfoListItem(
                icon: Icons.link,
                iconBackgroundColor: const Color(0xFF333333),
                title: 'GitHub',
                value: profile['github'] ?? '',
                isUrl: true,
              ),
              // ポートフォリオ
              InfoListItem(
                icon: Icons.language,
                iconBackgroundColor: const Color(0xFF3AAA3A),
                title: 'ポートフォリオ',
                value: profile['portfolio'] ?? '',
                isUrl: true,
              ),
              // 所属団体
              InfoListItem(
                icon: Icons.business,
                iconBackgroundColor: const Color(0xFFFF6F00),
                title: '所属団体',
                value: profile['organization'] ?? '',
                showDivider: false, // 最後なのでDivider非表示
              ),
            ],
          ),
        ),
      ],
    );
  }
}
