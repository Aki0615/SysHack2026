import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plaza_dummy_data.dart';
import 'widgets/plaza_search_bar.dart';
import 'widgets/tab_switch_button.dart';
import 'widgets/friend_list_view.dart';
import 'widgets/event_list_view.dart';

// 修正: 不要なコメントの削除と記述の最適化
class PlazaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setTab(int index) => state = index;
}

final plazaTabProvider = NotifierProvider<PlazaTabNotifier, int>(
  PlazaTabNotifier.new,
);

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
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            Expanded(child: _buildContent(ref, selectedIndex)),
          ],
        ),
      ),
    );
  }

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

  Widget _buildContent(WidgetRef ref, int selectedIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const PlazaSearchBar(),
          TabSwitchButton(
            selectedIndex: selectedIndex,
            onTabChanged: (index) =>
                ref.read(plazaTabProvider.notifier).setTab(index),
          ),
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
    );
  }
}
