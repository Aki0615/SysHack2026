import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/auth/domain/auth_notifier.dart';
import 'package:syshack2026/features/close_friend/domain/close_friend_list_notifier.dart';
import 'package:syshack2026/features/user/domain/user_model.dart';
import 'package:syshack2026/features/calendar/domain/calendar_notifier.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/avatar_group_section.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/day_event_card.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/week_day_pill.dart';

/// 週表示のカレンダー画面（新規デフォルト）。
///
/// - ヘッダー：タイトル + 検索アイコン + 自分アバター
/// - 週ナビ：「YYYY年M月」+ 前後移動 + 「月表示はこちら」リンク
/// - 週の日付ピル（7 日）
/// - その日のイベントカード → /events/:id
/// - 「この日に出会った人」 → /encounters/day/:date
/// - 「親しい友達」 → /close-friends
class WeekCalendarScreen extends ConsumerStatefulWidget {
  const WeekCalendarScreen({super.key});

  @override
  ConsumerState<WeekCalendarScreen> createState() => _WeekCalendarScreenState();
}

class _WeekCalendarScreenState extends ConsumerState<WeekCalendarScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(calendarNotifierProvider.notifier)
          .fetchMonthData(_monthOf(_selectedDate));
    });
  }

  DateTime _monthOf(DateTime date) => DateTime(date.year, date.month);

  void _goToPreviousMonth() {
    final prev = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    setState(() => _selectedDate = prev);
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(prev);
  }

  void _goToNextMonth() {
    final next = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    setState(() => _selectedDate = next);
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(next);
  }

  void _onDayTap(DateTime date) {
    if (date.month != _selectedDate.month) {
      ref
          .read(calendarNotifierProvider.notifier)
          .fetchMonthData(_monthOf(date));
    }
    setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    final calendarState = ref.watch(calendarNotifierProvider);
    final authUser = ref.watch(authNotifierProvider).value;
    final closeFriendsAsync = ref.watch(closeFriendListProvider);

    final dayData = _findDayData(calendarState.encounterDays, _selectedDate);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(user: authUser),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 24, 15, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MonthNavigation(
                      month: _selectedDate,
                      onPrev: _goToPreviousMonth,
                      onNext: _goToNextMonth,
                      onOpenMonthView: () => context.push('/calendar/month'),
                    ),
                    const SizedBox(height: 8),
                    _WeekStrip(
                      selectedDate: _selectedDate,
                      onSelect: _onDayTap,
                    ),
                    const SizedBox(height: 24),
                    _EventCardSection(
                      dayData: dayData,
                      selectedDate: _selectedDate,
                    ),
                    const SizedBox(height: 24),
                    _EncounterSection(
                      selectedDate: _selectedDate,
                      dayData: dayData,
                    ),
                    _CloseFriendSection(closeFriendsAsync: closeFriendsAsync),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? _findDayData(
    Map<DateTime, Map<String, dynamic>> encounterDays,
    DateTime date,
  ) {
    for (final entry in encounterDays.entries) {
      if (entry.key.year == date.year &&
          entry.key.month == date.month &&
          entry.key.day == date.day) {
        return entry.value;
      }
    }
    return null;
  }
}

class _Header extends StatelessWidget {
  final UserModel? user;

  const _Header({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'カレンダー',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 28.8 / 24,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'その日の記録',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 16.8 / 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO(passly): 検索画面の実装後にルート追加
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text('検索機能は準備中です'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
            icon: const Icon(
              Icons.search,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          const SizedBox(width: 4),
          _HeaderAvatar(user: user),
        ],
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  final UserModel? user;

  const _HeaderAvatar({this.user});

  @override
  Widget build(BuildContext context) {
    final iconUrl = user?.iconUrl ?? '';
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundGrey,
      ),
      child: ClipOval(
        child: iconUrl.isNotEmpty
            ? Image.network(
                iconUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() {
    return const Icon(Icons.person, color: AppColors.textLight, size: 24);
  }
}

class _MonthNavigation extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onOpenMonthView;

  const _MonthNavigation({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onOpenMonthView,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrev,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${month.year}年${month.month}月',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            height: 24 / 20,
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: onNext,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          icon: const Icon(
            Icons.chevron_right,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onOpenMonthView,
          borderRadius: BorderRadius.circular(4),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              '月表示はこちら',
              style: TextStyle(
                color: AppColors.iconBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 14.4 / 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 選択日を含む週の 7 日を横並びで表示。
/// 週の起点は月曜（DateTime.weekday の 1）。
class _WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final void Function(DateTime date) onSelect;

  const _WeekStrip({required this.selectedDate, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final weekStart = _startOfWeek(selectedDate);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = weekStart.add(Duration(days: index));
        return WeekDayPill(
          date: date,
          isSelected: _isSameDay(date, selectedDate),
          onTap: () => onSelect(date),
        );
      }),
    );
  }

  DateTime _startOfWeek(DateTime date) {
    // 月曜始まり: weekday 1 (月) が起点。日曜は 7。
    final delta = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - delta);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _EventCardSection extends StatelessWidget {
  final Map<String, dynamic>? dayData;
  final DateTime selectedDate;

  const _EventCardSection({required this.dayData, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final eventName = (dayData?['event'] as String?)?.trim() ?? '';
    if (eventName.isEmpty) {
      return _EmptyEventCard();
    }

    final location = (dayData?['event_location'] as String?)?.trim() ?? '';
    // 参加者数はカレンダー API 側にまだ含まれないため 0 表示。
    // TODO(passly): カレンダー daily/monthly API が participant_count を返すようになったら埋める
    final count = (dayData?['participant_count'] as int?) ?? 0;
    final eventIdRaw = dayData?['event_id'];
    final eventId = eventIdRaw is int
        ? eventIdRaw
        : int.tryParse('$eventIdRaw');

    return DayEventCard(
      eventName: eventName,
      date: selectedDate,
      location: location,
      participantCount: count,
      imageUrl: null,
      onTap: () {
        if (eventId != null) {
          context.push('/events/$eventId');
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('イベント ID が未取得のため詳細を開けません'),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
    );
  }
}

class _EmptyEventCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      alignment: Alignment.center,
      child: const Text(
        'この日のイベントはありません',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EncounterSection extends StatelessWidget {
  final DateTime selectedDate;
  final Map<String, dynamic>? dayData;

  const _EncounterSection({required this.selectedDate, required this.dayData});

  @override
  Widget build(BuildContext context) {
    final count = (dayData?['count'] as int?) ?? 0;
    final rawUsers = dayData?['users'];
    final users = rawUsers is List
        ? rawUsers
              .whereType<Map>()
              .map((raw) {
                final map = Map<String, dynamic>.from(raw);
                return AvatarItem(
                  userId: map['id']?.toString() ?? '',
                  iconUrl: map['iconUrl']?.toString() ?? '',
                );
              })
              .where((u) => u.userId.isNotEmpty)
              .toList()
        : const <AvatarItem>[];

    return AvatarGroupSection(
      title: 'この日に出会った人',
      subtitle: '$count人と出会いました',
      items: users,
      totalCount: count > 0 ? count : users.length,
      onTap: () {
        final dateParam =
            '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
        context.push('/encounters/day/$dateParam');
      },
    );
  }
}

class _CloseFriendSection extends StatelessWidget {
  final AsyncValue<List<UserModel>> closeFriendsAsync;

  const _CloseFriendSection({required this.closeFriendsAsync});

  @override
  Widget build(BuildContext context) {
    final users = closeFriendsAsync.asData?.value ?? const <UserModel>[];
    final items = users
        .map((u) => AvatarItem(userId: u.id, iconUrl: u.iconUrl))
        .toList();

    return AvatarGroupSection(
      title: '親しい友達',
      subtitle: '${users.length}人と出会いました',
      items: items,
      totalCount: users.length,
      onTap: () => context.push('/close-friends'),
    );
  }
}
