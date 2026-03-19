import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/auth_notifier.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../main_screen.dart';
import '../widgets/placeholder_screen.dart';

/// GoRouterの設定を管理するプロバイダー
/// 認証状態の変化に応じてリダイレクトを行う
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // デバッグ用: ルーティングのログを出力
    // 認証状態に応じたリダイレクト処理
    redirect: (context, state) {
      final user = authState.whenOrNull(data: (user) => user);
      final isLoggedIn = user != null;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/';

      // ログイン済みで認証ページにいる場合 → ホームへ
      if (isLoggedIn && isOnAuthPage) return '/home';
      // 未ログインで認証ページ以外にいる場合 → ログインへ
      if (!isLoggedIn && !isOnAuthPage) return '/login';

      return null; // リダイレクトなし
    },

    routes: [
      // スプラッシュ画面（初期画面）
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // ログイン画面
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // アカウント作成画面
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
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
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'ホーム', icon: Icons.home),
              ),
            ],
          ),

          // タブ2: 広場
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plaza',
                builder: (context, state) =>
                    const PlaceholderScreen(title: '広場', icon: Icons.people),
              ),
            ],
          ),

          // タブ3: カレンダー
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const PlaceholderScreen(
                  title: 'カレンダー',
                  icon: Icons.calendar_month,
                ),
              ),
            ],
          ),

          // タブ4: マイページ
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mypage',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'マイページ', icon: Icons.person),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
