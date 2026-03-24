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
      backgroundColor: const Color(0xFFFFFFFF),
      body: navigationShell, // 現在選択中のタブの画面を表示する
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  /// BottomNavigationBarの構築
  Widget _buildBottomNav(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFFFFFFFF),
      indicatorColor: const Color(0xFF3AAA3A).withValues(alpha: 0.15),
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
          icon: Icon(Icons.home_outlined, color: Color(0xFF757575)),
          selectedIcon: Icon(Icons.home, color: Color(0xFF3AAA3A)),
          label: 'ホーム',
        ),
        NavigationDestination(
          icon: Icon(Icons.people_outline, color: Color(0xFF757575)),
          selectedIcon: Icon(Icons.people, color: Color(0xFF3AAA3A)),
          label: '広場',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, color: Color(0xFF757575)),
          selectedIcon: Icon(Icons.calendar_month, color: Color(0xFF3AAA3A)),
          label: 'カレンダー',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline, color: Color(0xFF757575)),
          selectedIcon: Icon(Icons.person, color: Color(0xFF3AAA3A)),
          label: 'マイページ',
        ),
      ],
    );
  }
}
