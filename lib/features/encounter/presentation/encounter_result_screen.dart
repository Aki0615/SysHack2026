import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/encounter_model.dart';
import '../domain/encounter_notifier.dart';

/// 今回のすれ違い画面
/// ループ型スクロールでアイコンを表示し、タップで一言を表示する
class EncounterResultScreen extends ConsumerStatefulWidget {
  const EncounterResultScreen({super.key});

  @override
  ConsumerState<EncounterResultScreen> createState() =>
      _EncounterResultScreenState();
}

class _EncounterResultScreenState extends ConsumerState<EncounterResultScreen>
    with TickerProviderStateMixin {
  int? _selectedIndex;
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // ループのための大きな初期値
  static const int _initialPage = 10000;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.3,
      initialPage: _initialPage,
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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

  Widget _buildContent(List<EncounterModel> encounters) {
    if (encounters.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/home');
      });
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const SizedBox(height: 48),
        // ヘッダー: タイトルと人数
        _buildHeader(encounters.length),
        const SizedBox(height: 48),
        // ループ型アイコンスクロール
        SizedBox(
          height: 160,
          child: _buildLoopingAvatarScroll(encounters),
        ),
        const SizedBox(height: 32),
        // 選択されたユーザーの一言表示エリア
        _buildOneWordDisplay(encounters),
        const Spacer(),
        // 確認ボタン
        _buildConfirmButton(),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildHeader(int count) {
    return Column(
      children: [
        const Text(
          '今回のすれ違い',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.people, color: Colors.blueAccent, size: 24),
              const SizedBox(width: 8),
              Text(
                '$count 人とすれ違いました',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoopingAvatarScroll(List<EncounterModel> encounters) {
    final itemCount = encounters.length;

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        // ループ用のインデックスを実際のインデックスに変換
        final realIndex = index % itemCount;
        setState(() {
          _selectedIndex = realIndex;
        });
        _fadeController.forward(from: 0.0);
      },
      itemBuilder: (context, index) {
        final realIndex = index % itemCount;
        final encounter = encounters[realIndex];
        final isSelected = _selectedIndex == realIndex;

        return _PageAnimatedBuilder(
          animation: _pageController,
          builder: (context, child) {
            double scale = 1.0;
            double opacity = 0.6;

            if (_pageController.position.haveDimensions) {
              final page = _pageController.page ?? _initialPage.toDouble();
              final diff = (index - page).abs();
              scale = (1 - (diff * 0.2)).clamp(0.7, 1.0);
              opacity = (1 - (diff * 0.3)).clamp(0.4, 1.0);
            }

            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: _AvatarItem(
                  encounter: encounter,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedIndex = realIndex;
                    });
                    _fadeController.forward(from: 0.0);
                    // タップしたアイテムを中央に移動
                    final targetPage = _pageController.page!.round() -
                        (_pageController.page!.round() % itemCount) +
                        realIndex;
                    _pageController.animateToPage(
                      targetPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOneWordDisplay(List<EncounterModel> encounters) {
    if (_selectedIndex == null) {
      return Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Text(
            'アイコンをタップして\n一言を見る',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final encounter = encounters[_selectedIndex!];
    final user = encounter.encounteredUser;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (user.oneWord.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '「${user.oneWord}」',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Text(
                '一言が設定されていません',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              _formatTime(encounter.encounteredAt),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _handleConfirmAll,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade700,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            '確認してホームへ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirmAll() async {
    await ref.read(encounterNotifierProvider.notifier).confirmAll();
    if (mounted) context.go('/home');
  }

  String _formatTime(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} にすれ違い';
  }
}

/// アバターアイテムウィジェット
class _AvatarItem extends StatelessWidget {
  final EncounterModel encounter;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarItem({
    required this.encounter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = encounter.encounteredUser;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: _buildAvatar(user.iconUrl),
      ),
    );
  }

  Widget _buildAvatar(String iconUrl) {
    if (iconUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(iconUrl),
      );
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blueAccent, Colors.blue.shade800],
        ),
      ),
      child: const Icon(Icons.person, size: 50, color: Colors.white),
    );
  }
}

/// PageController用のアニメーションビルダー
class _PageAnimatedBuilder extends StatelessWidget {
  final PageController animation;
  final Widget Function(BuildContext context, Widget? child) builder;

  const _PageAnimatedBuilder({
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
    );
  }
}
