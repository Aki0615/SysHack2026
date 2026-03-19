import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// BottomNavigationBarを持つメイン画面
/// GoRouterのStatefulShellRouteから渡されるnavigationShellを使って
/// タブごとの画面遷移状態を保持する
class MainScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: navigationShell, // 現在選択中のタブの画面を表示する
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// BottomNavigationBarの構築
  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFF1A1A1A),
      indicatorColor: Colors.blueAccent.withValues(alpha: 0.2),
      selectedIndex: navigationShell.currentIndex,
      onDestinationSelected: (index) {
        // GoRouterのShellRoute内でタブを切り替える
        navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        );
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Colors.grey),
          selectedIcon: Icon(Icons.home, color: Colors.blueAccent),
          label: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline, color: Colors.grey),
          selectedIcon: Icon(Icons.people, color: Colors.blueAccent),
          label: '広場',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, color: Colors.grey),
          selectedIcon: Icon(Icons.calendar_month, color: Colors.blueAccent),
          label: 'カレンダー',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: Colors.grey),
          selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
          label: 'マイページ',
        ),
      ],
    );
  }
}
