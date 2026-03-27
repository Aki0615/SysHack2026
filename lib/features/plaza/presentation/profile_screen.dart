import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../user/data/user_repository.dart';
import '../../user/domain/user_model.dart';
import 'widgets/info_list_item.dart';

final profileProvider = FutureProvider.family<UserModel, String>((ref, userId) {
  return ref.read(userRepositoryProvider).getUser(userId);
});

class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: _buildAppBar(),
        body: const Center(
          child: Text('プロフィールIDが不正です'),
        ),
      );
    }

    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: profileAsync.when(
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              _buildHeader(profile),
              const SizedBox(height: 32),
              _buildInfoList(profile),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
        ),
        error: (error, _) => Center(
          child: Text(
            'プロフィールの取得に失敗しました\n$error',
            textAlign: TextAlign.center,
          ),
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

  Widget _buildHeader(UserModel profile) {
    return Column(
      children: [
        _buildProfileImage(profile),
        const SizedBox(height: 16),
        Text(
          profile.name,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCommentBadge(profile.oneWord),
      ],
    );
  }

  Widget _buildProfileImage(UserModel profile) {
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

  Widget _buildProfileImageContent(UserModel profile) {
    final iconUrl = profile.iconUrl;

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

  Widget _buildInfoList(UserModel profile) {
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
                value: profile.techStack,
              ),
              InfoListItem(
                icon: Icons.alternate_email,
                iconBackgroundColor: const Color(0xFF1DA1F2),
                title: 'Twitter',
                value: profile.twitterUrl,
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.link,
                iconBackgroundColor: const Color(0xFF333333),
                title: 'GitHub',
                value: profile.githubUrl,
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.language,
                iconBackgroundColor: const Color(0xFF3AAA3A),
                title: 'ポートフォリオ',
                value: profile.portfolioUrl,
                isUrl: true,
              ),
              InfoListItem(
                icon: Icons.business,
                iconBackgroundColor: const Color(0xFFFF6F00),
                title: '所属団体',
                value: profile.affiliation,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
