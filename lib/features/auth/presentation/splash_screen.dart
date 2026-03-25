import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/auth_notifier.dart';
import '../../encounter/domain/encounter_notifier.dart';

/// スプラッシュ画面Widget
/// 2秒間ロゴを表示した後、認証状態に応じて適切な画面へ遷移する
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // フェードインアニメーションの設定
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();

    // 2秒後に遷移先を判定する
    _navigateAfterDelay();
  }

  /// 2秒待機後、初回の認証状態チェックを開始する
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    _checkAuthState();
  }

  /// 認証状態をポーリングでチェックし、ログインまたは結果待ちへと遷移する
  void _checkAuthState() {
    final authState = ref.read(authNotifierProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          // ログイン済み → 未確認すれ違いデータをチェック
          _checkPendingEncounters();
        } else {
          // 未ログイン → ログイン画面
          context.go('/login');
        }
      },
      loading: () {
        // まだ認証チェック中なら待って再帰（ここで2秒待機をスタックさせない）
        Future.delayed(const Duration(milliseconds: 500), _checkAuthState);
      },
      error: (_, _) {
        // エラー時はログイン画面へ
        context.go('/login');
      },
    );
  }

  /// 未確認のすれ違いデータをチェックし、結果画面またはホームへ遷移する
  void _checkPendingEncounters() {
    final encounterState = ref.read(encounterNotifierProvider);
    encounterState.when(
      data: (encounters) {
        if (encounters.isNotEmpty) {
          // 未確認データあり → すれ違い結果画面
          context.go('/encounter-result');
        } else {
          // 未確認データなし → ホーム画面
          context.go('/home');
        }
      },
      loading: () {
        // ロード中なら待って再帰
        Future.delayed(
          const Duration(milliseconds: 500),
          _checkPendingEncounters,
        );
      },
      error: (_, _) {
        // エラー時はホームへ
        context.go('/home');
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: FadeTransition(opacity: _fadeAnimation, child: _buildLogo()),
      ),
    );
  }

  /// ロゴ部分の構築
  Widget _buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bluetoothを連想させるアイコン
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.bluetooth, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 24),
        const Text(
          'StreetPass',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'すれ違いで、つながる',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
      ],
    );
  }
}
