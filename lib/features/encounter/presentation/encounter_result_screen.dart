import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/encounter_model.dart';
import '../domain/encounter_notifier.dart';

/// Mii広場風のすれ違い結果画面
/// 未確認のすれ違いユーザーをアニメーション付きで順番に紹介する
class EncounterResultScreen extends ConsumerStatefulWidget {
  const EncounterResultScreen({super.key});

  @override
  ConsumerState<EncounterResultScreen> createState() =>
      _EncounterResultScreenState();
}

class _EncounterResultScreenState extends ConsumerState<EncounterResultScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // スライドインアニメーション（右から入ってくる）
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // フェードインアニメーション
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final encounterState = ref.watch(encounterNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: encounterState.when(
          data: (encounters) => _buildContent(encounters),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Text('エラー: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  /// メインコンテンツの構築
  Widget _buildContent(List<EncounterModel> encounters) {
    if (encounters.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const SizedBox.shrink();
    }

    final isLastUser = _currentIndex >= encounters.length - 1;
    final currentEncounter = encounters[_currentIndex];

    return Column(
      children: [
        const SizedBox(height: 32),
        _EncounterHeader(
          currentIndex: _currentIndex,
          totalCount: encounters.length,
        ),
        const Spacer(),
        SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _EncounterUserCard(encounter: currentEncounter),
          ),
        ),
        const Spacer(),
        _EncounterActionButton(
          isLastUser: isLastUser,
          onNextUser: () => _showNextUser(encounters.length),
          onConfirmAll: () => _handleConfirmAll(),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  /// 次のユーザーを表示する
  void _showNextUser(int totalCount) {
    if (_currentIndex >= totalCount - 1) return;
    _slideController.reset();
    _fadeController.reset();
    setState(() => _currentIndex++);
    _slideController.forward();
    _fadeController.forward();
  }

  /// 全て確認済みにする処理
  Future<void> _handleConfirmAll() async {
    await ref.read(encounterNotifierProvider.notifier).confirmAll();
    if (mounted) context.go('/home');
  }
}

// ─────────────────────────────────────────────────
// 以下、子Widget群（ネスト防止のため分割）
// ─────────────────────────────────────────────────

/// ヘッダー部分（進捗表示）
class _EncounterHeader extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const _EncounterHeader({
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🎉 すれ違いました！',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${currentIndex + 1} / $totalCount 人',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / totalCount,
            backgroundColor: Colors.grey.shade800,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// すれ違ったユーザーの情報カード
class _EncounterUserCard extends StatelessWidget {
  final EncounterModel encounter;

  const _EncounterUserCard({required this.encounter});

  @override
  Widget build(BuildContext context) {
    final user = encounter.encounteredUser;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // アバター（アイコンURLがある場合は画像、なければデフォルトアイコン）
          _buildAvatar(user.iconUrl),
          const SizedBox(height: 16),
          // 名前
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 一言コメント
          if (user.oneWord.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade800.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '「${user.oneWord}」',
                style: TextStyle(color: Colors.grey.shade300, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 16),
          // すれ違い時刻
          Text(
            _formatTime(encounter.encounteredAt),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// アバターを構築する
  Widget _buildAvatar(String iconUrl) {
    if (iconUrl.isNotEmpty) {
      return CircleAvatar(radius: 40, backgroundImage: NetworkImage(iconUrl));
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade800],
        ),
      ),
      child: const Icon(Icons.person, size: 40, color: Colors.white),
    );
  }

  /// 時刻をフォーマットする
  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} にすれ違い';
  }
}

/// 「次の人を見る」/「確認した！」ボタン
class _EncounterActionButton extends StatelessWidget {
  final bool isLastUser;
  final VoidCallback onNextUser;
  final VoidCallback onConfirmAll;

  const _EncounterActionButton({
    required this.isLastUser,
    required this.onNextUser,
    required this.onConfirmAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLastUser ? onConfirmAll : onNextUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastUser
                ? Colors.greenAccent.shade700
                : Colors.blueAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            isLastUser ? '✅ 確認した！' : '次の人を見る →',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
