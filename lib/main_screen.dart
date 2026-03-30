import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'common/widgets/animated_bottom_nav_bar.dart';
import 'core/network/dio_client.dart';
import 'features/ble/ble_notifier.dart';
import 'features/auth/domain/auth_notifier.dart';
import 'features/encounter/domain/encounter_notifier.dart';
import 'features/encounter/domain/encounter_model.dart';
import 'features/user/domain/user_model.dart';

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
  static const MethodChannel _batteryChannel = MethodChannel(
    'syshack/battery_optimization',
  );

  bool _bleStarted = false;
  bool _batteryCheckRunning = false;
  String? _lastBleUserId;

  @override
  void initState() {
    super.initState();
    // アプリのライフサイクルイベントを監視
    WidgetsBinding.instance.addObserver(this);
    // ログイン済みならBLEを自動開始
    _startBleIfLoggedIn();
    _checkBatteryOptimizationOnce();
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
        _checkBatteryOptimizationOnce();
        _navigateToEncounterIfPending(reason: 'app_resumed');
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // バックグラウンド移行時点の未確認データを保存して次回起動比較に使う
        ref.read(encounterNotifierProvider.notifier).saveShutdownSnapshot();
        // バックグラウンドに移行 → BLEは停止しない（継続）
        debugPrint('アプリがバックグラウンドに移行しました（BLE継続中）');
        break;
      case AppLifecycleState.detached:
        // アプリが完全に終了 → BLEを停止
        ref.read(encounterNotifierProvider.notifier).saveShutdownSnapshot();
        debugPrint('アプリが終了します（BLE停止）');
        _stopBle();
        break;
    }
  }

  /// ログイン済みの場合にBLEすれ違い機能を開始する
  Future<void> _startBleIfLoggedIn() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    if (_bleStarted && _lastBleUserId == user.id) return;

    if (_bleStarted && _lastBleUserId != user.id) {
      await _stopBle();
    }

    try {
      await ref.read(bleNotifierProvider.notifier).start();
      _bleStarted = true;
      _lastBleUserId = user.id;
      debugPrint('BLEすれ違い機能を自動開始しました（ユーザー: ${user.id}）');
    } catch (e) {
      debugPrint('BLE自動開始エラー: $e');
    }
  }

  Future<void> _checkBatteryOptimizationOnce() async {
    if (!Platform.isAndroid || _batteryCheckRunning) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    _batteryCheckRunning = true;
    try {
      final storage = ref.read(secureStorageProvider);
      final alreadyShown = await storage.read(
        key: 'battery_optimization_prompt_shown',
      );
      if (alreadyShown == '1') return;

      final ignored = await _batteryChannel.invokeMethod<bool>(
        'isIgnoringBatteryOptimizations',
      );
      if (ignored == true) {
        await storage.write(
          key: 'battery_optimization_prompt_shown',
          value: '1',
        );
        return;
      }

      if (!mounted) return;
      final shouldOpenSettings =
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('バッテリー最適化の設定'),
                content: const Text(
                  'Androidの省電力機能により、バックグラウンドでのすれ違い検知が不安定になる場合があります。\n\n'
                  '「許可する」を押すと設定画面を開きます。',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('あとで'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('許可する'),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (shouldOpenSettings) {
        await _batteryChannel.invokeMethod('requestIgnoreBatteryOptimizations');
      }

      await storage.write(key: 'battery_optimization_prompt_shown', value: '1');
    } on PlatformException catch (e) {
      debugPrint('バッテリー最適化チェックエラー: ${e.message}');
    } finally {
      _batteryCheckRunning = false;
    }
  }

  /// BLEすれ違い機能を停止する
  Future<void> _stopBle() async {
    if (!_bleStarted) return;
    try {
      await ref.read(bleNotifierProvider.notifier).stop();
      _bleStarted = false;
      _lastBleUserId = null;
      debugPrint('BLEすれ違い機能を停止しました');
    } catch (e) {
      debugPrint('BLE停止エラー: $e');
    }
  }

  void _navigateToEncounterIfPending({required String reason}) {
    if (!mounted) return;

    final pending =
        ref.read(encounterNotifierProvider).asData?.value ?? const [];
    if (pending.isEmpty) {
      debugPrint('すれ違い結果遷移スキップ: pending=0 (reason=$reason)');
      return;
    }

    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/encounter-result') {
      debugPrint(
        'すれ違い結果遷移スキップ: 既に表示中 (reason=$reason, pending=${pending.length})',
      );
      return;
    }

    debugPrint(
      'すれ違い結果へ遷移: reason=$reason, pending=${pending.length}, from=$location',
    );
    context.go('/encounter-result');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      final prevId = previous?.asData?.value?.id;
      final nextId = next.asData?.value?.id;

      if (prevId == nextId) return;

      if (nextId == null) {
        _stopBle();
      } else {
        _startBleIfLoggedIn();
      }
    });

    ref.listen<AsyncValue<List<EncounterModel>>>(encounterNotifierProvider, (
      previous,
      next,
    ) {
      final prevCount = previous?.asData?.value.length ?? 0;
      final nextCount = next.asData?.value.length ?? 0;
      final hasNewPending = nextCount > prevCount;
      if (!hasNewPending) return;

      debugPrint('未確認すれ違い増加を検知: $prevCount -> $nextCount');
      _navigateToEncounterIfPending(reason: 'pending_increased');
    });

    ref.listen<BleState>(bleNotifierProvider, (previous, next) {
      final titles = next.newlyUnlockedAchievementTitles;
      if (titles.isEmpty) return;

      final previousTitles =
          previous?.newlyUnlockedAchievementTitles ?? const [];
      if (listEquals(previousTitles, titles)) return;

      final message = titles.length == 1
          ? '実績を解除: ${titles.first}'
          : '実績を${titles.length}件解除: ${titles.join(' / ')}';

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF3AAA3A),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

      ref
          .read(bleNotifierProvider.notifier)
          .consumeUnlockedAchievementNotifications();
    });

    final pendingState = ref.watch(encounterNotifierProvider);
    final pendingCount = pendingState.asData?.value.length ?? 0;
    if (pendingCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToEncounterIfPending(reason: 'build_pending_exists');
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBody: true, // タブバーの背後まで画面を広げる
      body: widget.navigationShell,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return AnimatedBottomNavBar(
      currentIndex: widget.navigationShell.currentIndex,
      onTap: (index) => _onTap(context, index),
      items: const [
        BottomNavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: 'ホーム',
        ),
        BottomNavItem(
          icon: Icons.people_outline,
          activeIcon: Icons.people,
          label: '広場',
        ),
        BottomNavItem(
          icon: Icons.calendar_today_outlined,
          activeIcon: Icons.calendar_month,
          label: 'カレンダー',
        ),
        BottomNavItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: 'マイページ',
        ),
      ],
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
