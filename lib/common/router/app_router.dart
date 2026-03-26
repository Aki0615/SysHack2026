import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_notifier.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/encounter/presentation/encounter_result_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/plaza/presentation/plaza_screen.dart';
import '../../features/plaza/presentation/profile_screen.dart';
import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/mypage/presentation/mypage_screen.dart';
import '../../features/mypage/presentation/achievements_screen.dart';
import '../../main_screen.dart';

/// GoRouterのリフレッシュ用Notifier
class RouterNotifier extends ChangeNotifier {
  final Ref ref;
  RouterNotifier(this.ref) {
    ref.listen<AsyncValue<dynamic>>(
      authNotifierProvider,
      (_, __) => notifyListeners(),
    );
  }
}

/// GoRouterの設定を管理するプロバイダー
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    debugLogDiagnostics: true, // デバッグ用: ルーティングのログを出力
    // 認証状態に応じたリダイレクト処理
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final user = authState.whenOrNull(data: (user) => user);
      final isLoggedIn = user != null;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/' ||
          state.matchedLocation == '/encounter-result';

      // ログイン済みで認証ページにいる場合 → ホームへ
      if (isLoggedIn && isOnAuthPage) return '/home';
      // 未ログインで認証ページ以外にいる場合 → ログインへ
      if (!isLoggedIn && !isOnAuthPage) return '/login';

      return null; // リダイレクトなし
    },

    routes: [
      // スプラッシュ画面（初期画面）
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // すれ違い結果画面（Mii広場風）
      GoRoute(
        path: '/encounter-result',
        builder: (context, state) => const EncounterResultScreen(),
      ),

      // ログイン画面
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // アカウント作成画面
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // プロフィール画面
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // 実績一覧画面
      GoRoute(
        path: '/achievements',
        builder: (context, state) => const AchievementsScreen(),
      ),

      // メイン画面（4タブのBottomNavigationBar）
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // タブ1: ホーム
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // タブ2: 広場
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plaza',
                builder: (context, state) => const PlazaScreen(),
              ),
            ],
          ),

          // タブ3: カレンダー
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),

          // タブ4: マイページ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) => const MyPageScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
