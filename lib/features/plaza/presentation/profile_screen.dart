import 'package:flutter/material.dart';
import '../../plaza/data/plaza_dummy_data.dart';
import 'widgets/info_list_item.dart';

// 修正: 不要なコメント削減、階層の整理
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = dummyProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(), // 修正: メソッド化
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            _buildHeader(profile),
            const SizedBox(height: 32),
            _buildInfoList(profile),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const BackButton(color: Color(0xFF1A1A1A)),
    );
  }

  Widget _buildHeader(Map<String, String> profile) {
    return Column(
      children: [
        _buildProfileImage(profile),
        const SizedBox(height: 16),
        Text(
          profile['name'] ?? '',
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCommentBadge(profile['comment'] ?? ''),
      ],
    );
  }

  Widget _buildProfileImage(Map<String, String> profile) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x1A3AAA3A),
        border: Border.all(color: const Color(0xFF3AAA3A), width: 3),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: _buildProfileImageContent(profile),
    );
  }

  Widget _buildProfileImageContent(Map<String, String> profile) {
    final iconUrl = profile['icon_url'] ?? '';

    // Firebase URL から画像を表示
    if (iconUrl.isNotEmpty) {
      return Image.network(
        iconUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 48);
        },
      );
    }

    // デフォルトアイコン
    return const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 48);
  }

  Widget _buildCommentBadge(String comment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x1A3AAA3A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        comment,
        style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoList(Map<String, String> profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INFORMATION',
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              InfoListItem(
                icon: Icons.code,
                iconBackgroundColor: const Color(0xFF1565C0),
                title: '技術スタック',
                value: profile['techStack'] ?? '',
              ),
              InfoListItem(
                icon: Icons.alternate_email,
                iconBackgroundColor: const Color(0xFF1DA1F2),
                title: 'Twitter',
                value: profile['twitter'] ?? '',
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.link,
                iconBackgroundColor: const Color(0xFF333333),
                title: 'GitHub',
                value: profile['github'] ?? '',
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.language,
                iconBackgroundColor: const Color(0xFF3AAA3A),
                title: 'ポートフォリオ',
                value: profile['portfolio'] ?? '',
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.business,
                iconBackgroundColor: const Color(0xFFFF6F00),
                title: '所属団体',
                value: profile['organization'] ?? '',
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
