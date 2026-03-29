import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 修正: 不要なコメントの削除、コードのネスト解消
class FriendGridItem extends StatelessWidget {
  final String name;
  final String userId;
  final String iconUrl;

  const FriendGridItem({
    super.key,
    required this.name,
    required this.userId,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/profile/$userId'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIcon(), // 修正: アイコン構築を分離
          const SizedBox(height: 8),
          _buildNameText(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (iconUrl.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF3AAA3A), width: 2),
        ),
        child: ClipOval(
          child: Image.network(
            iconUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackIcon(),
          ),
        ),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0x263AAA3A),
        border: Border.all(color: const Color(0xFF3AAA3A), width: 2),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, color: Color(0xFF3AAA3A), size: 32),
    );
  }

  Widget _buildNameText() {
    return Text(
      name,
      style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 11),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
