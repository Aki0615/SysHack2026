import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/plaza_dummy_data.dart';
import 'widgets/friend_list_view.dart';
import 'widgets/event_list_view.dart';

/// 広場のタブ状態管理
class PlazaTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setTab(int index) => state = index;
}

final plazaTabProvider = NotifierProvider<PlazaTabNotifier, int>(
  PlazaTabNotifier.new,
);

/// 検索クエリの状態管理（Riverpod v3対応: Notifierベース）
class PlazaSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final plazaSearchQueryProvider =
    NotifierProvider<PlazaSearchQueryNotifier, String>(
      PlazaSearchQueryNotifier.new,
    );

class PlazaScreen extends ConsumerStatefulWidget {
  const PlazaScreen({super.key});

  @override
  ConsumerState<PlazaScreen> createState() => _PlazaScreenState();
}

class _PlazaScreenState extends ConsumerState<PlazaScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(plazaTabProvider);
    final searchQuery = ref.watch(plazaSearchQueryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(context, selectedIndex),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            Expanded(child: _buildContent(selectedIndex, searchQuery)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int selectedIndex) {
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        selectedIndex == 0 ? '友達一覧' : 'イベント一覧',
        style: const TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF1A1A1A)),
          onPressed: () => _showMenuBottomSheet(context),
        ),
      ],
    );
  }

  /// メニューボトムシート
  void _showMenuBottomSheet(BuildContext context) {
    final currentIndex = ref.read(plazaTabProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ハンドル
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // タイトル
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '表示切替',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 友達一覧
                _buildMenuItem(
                  icon: Icons.people,
                  title: '友達一覧',
                  isSelected: currentIndex == 0,
                  onTap: () {
                    ref.read(plazaTabProvider.notifier).setTab(0);
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // イベント一覧
                _buildMenuItem(
                  icon: Icons.event,
                  title: 'イベント一覧',
                  isSelected: currentIndex == 1,
                  onTap: () {
                    ref.read(plazaTabProvider.notifier).setTab(1);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected
            ? const Color(0xFF3AAA3A).withValues(alpha: 0.1)
            : Colors.transparent,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF3AAA3A)
                  : const Color(0xFF757575),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3AAA3A)
                      : const Color(0xFF1A1A1A),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) const Icon(Icons.check, color: Color(0xFF3AAA3A)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(int selectedIndex, String searchQuery) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 検索バー
          _buildSearchBar(),
          const SizedBox(height: 16),
          // リスト表示
          Expanded(
            child: selectedIndex == 0
                ? _buildFilteredFriendList(searchQuery)
                : _buildFilteredEventList(searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF3AAA3A), width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
          onChanged: (value) {
            ref.read(plazaSearchQueryProvider.notifier).setQuery(value);
          },
          decoration: InputDecoration(
            hintText: '人名・イベント名で検索',
            hintStyle: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF3AAA3A)),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF757575)),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(plazaSearchQueryProvider.notifier).clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// フィルタリングされた友達リスト
  Widget _buildFilteredFriendList(String query) {
    final filteredFriends = query.isEmpty
        ? dummyFriends
        : dummyFriends.where((friend) {
            final name = friend['name']?.toLowerCase() ?? '';
            return name.contains(query.toLowerCase());
          }).toList();

    if (filteredFriends.isEmpty) {
      return _buildEmptyState('該当する友達が見つかりません');
    }

    return FriendListView(friends: filteredFriends);
  }

  /// フィルタリングされたイベントリスト
  Widget _buildFilteredEventList(String query) {
    final filteredEvents = query.isEmpty
        ? dummyEvents
        : dummyEvents.where((event) {
            final name = event['name']?.toLowerCase() ?? '';
            return name.contains(query.toLowerCase());
          }).toList();

    if (filteredEvents.isEmpty) {
      return _buildEmptyState('該当するイベントが見つかりません');
    }

    return EventListView(events: filteredEvents);
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF757575), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
