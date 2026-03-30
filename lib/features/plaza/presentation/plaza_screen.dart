import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/plaza_notifier.dart';
import '../../user/domain/user_model.dart';
import 'widgets/friend_list_view.dart';
import 'widgets/event_list_view.dart';

/// 広場のタブ状態管理
class PlazaTabNotifier extends Notifier<int> {
  @override
  int build() => 2; // デフォルトはランダム表示
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
    final titles = ['友達一覧', 'イベント一覧', 'ランダム表示'];
    return AppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Text(
        titles[selectedIndex],
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
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // ランダム表示
                _buildMenuItem(
                  icon: Icons.shuffle,
                  title: 'ランダム表示',
                  isSelected: currentIndex == 2,
                  onTap: () {
                    ref.read(plazaTabProvider.notifier).setTab(2);
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
    // ランダム表示の場合は検索バーなし
    if (selectedIndex == 2) {
      return _buildRandomFriendList();
    }

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
    final plazaState = ref.watch(plazaNotifierProvider);

    return plazaState.when(
      data: (users) {
        final filteredFriends = query.isEmpty
            ? users
            : users.where((user) {
                return user.name.toLowerCase().contains(query.toLowerCase());
              }).toList();

        if (filteredFriends.isEmpty) {
          return _buildEmptyState('該当する友達が見つかりません');
        }

        return ListView.separated(
          itemCount: filteredFriends.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = filteredFriends[index];
            return _buildUserCard(user);
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
      ),
      error: (_, __) => _buildEmptyState('データの取得に失敗しました'),
    );
  }

  /// フィルタリングされたイベントリスト
  Widget _buildFilteredEventList(String query) {
    final eventState = ref.watch(plazaEventNotifierProvider);

    return eventState.when(
      data: (events) {
        final filteredEvents = query.isEmpty
            ? events
            : events.where((event) {
                final name = event['name']?.toString().toLowerCase() ?? '';
                return name.contains(query.toLowerCase());
              }).toList();

        if (filteredEvents.isEmpty) {
          return _buildEmptyState('該当するイベントが見つかりません');
        }

        return EventListView(
          events: filteredEvents,
          onEventTap: _onEventTap,
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
      ),
      error: (_, __) => _buildEmptyState('イベントの取得に失敗しました'),
    );
  }

  Future<void> _onEventTap(Map<String, dynamic> event) async {
    final url = event['event_url']?.toString().trim() ?? '';
    if (url.isEmpty) {
      _showEventDetailBottomSheet(event);
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントURLが不正です')),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベントURLを開けませんでした')),
      );
    }
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

  /// ランダム表示（友達をランダムに最大7人表示）
  Widget _buildRandomFriendList() {
    final plazaState = ref.watch(plazaNotifierProvider);

    return plazaState.when(
      data: (users) => _buildRandomFriendContent(users),
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
      ),
      error: (_, __) => _buildEmptyState('データの取得に失敗しました'),
    );
  }

  Widget _buildRandomFriendContent(List<UserModel> users) {
    if (users.isEmpty) {
      return _buildEmptyState('すれ違った人がいません');
    }

    final shuffled = List<UserModel>.from(users)..shuffle();
    final randomFriends = shuffled.take(7).toList();

    final randomFriendMaps = randomFriends
        .map((user) => {
              'id': user.id,
              'name': user.name,
              'comment': user.oneWord,
              'iconUrl': user.iconUrl,
            })
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // 説明テキスト
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3AAA3A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.shuffle, color: Color(0xFF3AAA3A)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ランダムに選ばれた友達です',
                    style: TextStyle(
                      color: Color(0xFF3AAA3A),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: FriendListView(friends: randomFriendMaps)),
          // シャッフルボタン
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() {}), // リビルドでシャッフル
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'シャッフル',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3AAA3A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// UserModel用のカード（ランダム表示用）
  Widget _buildUserCard(UserModel user) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/profile/${user.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // アイコン
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: user.iconUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          user.iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.person, color: Color(0xFF757575)),
                        ),
                      )
                    : const Icon(Icons.person, color: Color(0xFF757575)),
              ),
              const SizedBox(width: 16),
              // 名前とコメント
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.oneWord,
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF757575)),
            ],
          ),
        ),
      ),
    );
  }

  /// イベント詳細ボトムシートを表示
  void _showEventDetailBottomSheet(Map<String, dynamic> event) {
    final participantUsers = const <Map<String, dynamic>>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
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
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日付
                      Text(
                        event['date'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // イベント名
                      Text(
                        event['name'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 場所
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF757575),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event['location'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // すれ違い人数
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3AAA3A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.people,
                              color: Color(0xFF3AAA3A),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'すれ違った人数',
                              style: TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${event['count']}人',
                              style: const TextStyle(
                                color: Color(0xFF3AAA3A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                // すれ違った人一覧
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const Text(
                        'すれ違った人',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${participantUsers.length}人',
                        style: const TextStyle(
                          color: Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (participantUsers.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Text(
                      '参加者の詳細データはまだありません',
                      style: TextStyle(color: Color(0xFF757575), fontSize: 14),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shrinkWrap: true,
                      itemCount: participantUsers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final user = participantUsers[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE0E0E0),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF757575),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                user['name'] ?? '',
                                style: const TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
