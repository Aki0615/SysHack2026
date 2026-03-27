import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/ble/ble_notifier.dart';
import 'features/auth/domain/auth_notifier.dart';

/// メイン画面（4タブのBottomNavigationBar）
/// ログイン後に表示される画面で、BLEすれ違い機能のライフサイクルを管理する
class MainScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({super.key, required this.navigationShell});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  bool _bleStarted = false;

  @override
  void initState() {
    super.initState();
    // アプリのライフサイクルイベントを監視
    WidgetsBinding.instance.addObserver(this);
    // ログイン済みならBLEを自動開始
    _startBleIfLoggedIn();
  }

  @override
  void dispose() {
    // アプリ完全終了時にBLEを停止
    WidgetsBinding.instance.removeObserver(this);
    _stopBle();
    super.dispose();
  }

  /// アプリのライフサイクル変化を検知
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // フォアグラウンドに復帰 → BLEが停止していたら再開
        debugPrint('アプリがフォアグラウンドに復帰しました');
        _startBleIfLoggedIn();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // バックグラウンドに移行 → BLEは停止しない（継続）
        debugPrint('アプリがバックグラウンドに移行しました（BLE継続中）');
        break;
      case AppLifecycleState.detached:
        // アプリが完全に終了 → BLEを停止
        debugPrint('アプリが終了します（BLE停止）');
        _stopBle();
        break;
    }
  }

  /// ログイン済みの場合にBLEすれ違い機能を開始する
  Future<void> _startBleIfLoggedIn() async {
    if (_bleStarted) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    try {
      await ref.read(bleNotifierProvider.notifier).start();
      _bleStarted = true;
      debugPrint('BLEすれ違い機能を自動開始しました（ユーザー: ${user.id}）');
    } catch (e) {
      debugPrint('BLE自動開始エラー: $e');
    }
  }

  /// BLEすれ違い機能を停止する
  Future<void> _stopBle() async {
    if (!_bleStarted) return;
    try {
      await ref.read(bleNotifierProvider.notifier).stop();
      _bleStarted = false;
      debugPrint('BLEすれ違い機能を停止しました');
    } catch (e) {
      debugPrint('BLE停止エラー: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: widget.navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: (index) => _onTap(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF3AAA3A),
        unselectedItemColor: const Color(0xFF9E9E9E),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: '広場',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_month),
            label: 'カレンダー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
