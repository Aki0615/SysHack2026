import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../user/data/user_repository.dart';
import '../../user/domain/user_model.dart';

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
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipOval(child: _buildProfileImageContent(profile)),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3AAA3A), width: 3),
              ),
            ),
          ),
        ],
      ),
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
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        comment.isEmpty ? '一言未設定' : comment,
        style: TextStyle(
          color: comment.isEmpty
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF1A1A1A),
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildInfoList(UserModel profile) {
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
              _buildViewItem(
                icon: Icons.code,
                iconColor: const Color(0xFF1565C0),
                label: '技術スタック',
                value: profile.techStack,
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildViewItem(
                icon: Icons.business,
                iconColor: const Color(0xFFFF6F00),
                label: '所属団体',
                value: profile.affiliation,
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildLinkItem(
                icon: Icons.alternate_email,
                iconColor: const Color(0xFF1DA1F2),
                label: 'Twitter',
                value: profile.twitterUrl,
                onLaunch: () => _launchUrl(_normalizeTwitterUrl(profile.twitterUrl)),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildLinkItem(
                icon: Icons.link,
                iconColor: const Color(0xFF333333),
                label: 'GitHub',
                value: profile.githubUrl,
                onLaunch: () => _launchUrl(_normalizeGitHubUrl(profile.githubUrl)),
              ),
              const Divider(
                color: Color(0xFFE0E0E0),
                height: 1,
                thickness: 0.5,
              ),
              _buildLinkItem(
                icon: Icons.event,
                iconColor: const Color(0xFFE53935),
                label: 'Connpass',
                value: profile.connpassUrl,
                onLaunch: () => _launchUrl(_normalizeConnpassUrl(profile.connpassUrl)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeTwitterUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final handle = value.startsWith('@') ? value.substring(1) : value;
    return 'https://x.com/$handle';
  }

  String _normalizeGitHubUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    if (value.startsWith('github.com/')) return 'https://$value';
    return 'https://github.com/$value';
  }

  String _normalizeConnpassUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://')) return value;
    final username = value.startsWith('@') ? value.substring(1) : value;
    return 'https://connpass.com/user/$username/';
  }

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

  Widget _buildLinkItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required VoidCallback onLaunch,
  }) {
    final isEmpty = value.isEmpty;

    return InkWell(
      onTap: isEmpty ? null : onLaunch,
      child: Padding(
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
                    isEmpty ? '未設定' : value,
                    style: TextStyle(
                      color: isEmpty
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: isEmpty
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFF757575),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle(IconData icon, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
