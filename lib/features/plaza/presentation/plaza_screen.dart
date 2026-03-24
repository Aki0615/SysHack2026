import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plaza_dummy_data.dart';
import 'widgets/plaza_search_bar.dart';
import 'widgets/tab_switch_button.dart';
import 'widgets/friend_list_view.dart';
import 'widgets/event_list_view.dart';

/// 広場画面の選択中タブ（0: 友達一覧, 1: イベント一覧）を管理するNotifier
class PlazaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }
}

/// ノティファイアのプロバイダー
final plazaTabProvider = NotifierProvider<PlazaTabNotifier, int>(
  PlazaTabNotifier.new,
);

/// 広場画面本体Widget
/// StatelessWidget（ConsumerWidget）として定義し、Riverpodでタブ状態を管理する
class PlazaScreen extends ConsumerWidget {
  const PlazaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(plazaTabProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar下のセパレーターライン（1px）
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            // コンテンツ部分
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // 検索バー
                    const PlazaSearchBar(),
                    // 切り替えボタン
                    TabSwitchButton(
                      selectedIndex: selectedIndex,
                      onTabChanged: (index) {
                        ref.read(plazaTabProvider.notifier).setTab(index);
                      },
                    ),
                    // リスト部分（選択中のタブに応じて切り替え）
                    Expanded(
                      child: selectedIndex == 0
                          ? SizedBox(
                              height: 600,
                              child: FriendListView(friends: dummyFriends),
                            )
                          : EventListView(events: dummyEvents),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AppBarの構築
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: const Text(
        '広場',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
