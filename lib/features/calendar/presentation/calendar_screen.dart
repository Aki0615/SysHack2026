import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/calendar_notifier.dart';
import 'widgets/encounter_bubble.dart';
import 'widgets/month_selector.dart';
import 'widgets/calendar_grid.dart';

/// カレンダー画面本体Widget
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);

    // 初回データ取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
    });
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDay = null; // 月を変えたら選択解除
    });
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDay = null;
    });
    ref.read(calendarNotifierProvider.notifier).fetchMonthData(_currentMonth);
  }

  void _onDaySelected(DateTime date) {
    final calendarState = ref.read(calendarNotifierProvider);
    final dayData = calendarState.encounterDays.entries
        .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
        .firstWhere(
          (e) =>
              e != null &&
              e.key.year == date.year &&
              e.key.month == date.month &&
              e.key.day == date.day,
          orElse: () => null,
        );

    setState(() {
      // すれ違いの有無に関わらず、タップした日付を選択状態にする
      _selectedDay = date;
    });

    // すれ違いデータがある場合は詳細ボトムシートを表示
    if (dayData != null) {
      _showEventDetailBottomSheet(date, dayData.value);
    }
  }

  /// イベント詳細ボトムシートを表示
  void _showEventDetailBottomSheet(DateTime date, Map<String, dynamic> data) {
    final count = data['count'] as int;
    final eventName = data['event'] as String?;
    final normalizedEventName = eventName?.trim() ?? '';
    final hasEventName = normalizedEventName.isNotEmpty;
    final eventLocation = data['event_location'] as String?;
    final eventUrl = data['event_url'] as String?;
    final hasEventUrl =
        hasEventName && eventUrl != null && eventUrl.trim().isNotEmpty;
    final users =
        (data['users'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              '${date.year}年${date.month}月${date.day}日',
                              style: const TextStyle(
                                color: Color(0xFF757575),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasEventName ? normalizedEventName : 'イベントなし',
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF3AAA3A,
                                ).withValues(alpha: 0.1),
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
                                    '$count人',
                                    style: const TextStyle(
                                      color: Color(0xFF3AAA3A),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: hasEventUrl
                                    ? () => _openEventUrl(context, eventUrl)
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        color: Color(0xFF757575),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              hasEventUrl
                                                  ? 'イベント（タップで開く）'
                                                  : 'イベント',
                                              style: const TextStyle(
                                                color: Color(0xFF757575),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              hasEventName
                                                  ? normalizedEventName
                                                  : 'イベントなし',
                                              style: const TextStyle(
                                                color: Color(0xFF1A1A1A),
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (eventLocation != null &&
                                                eventLocation.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                eventLocation,
                                                style: const TextStyle(
                                                  color: Color(0xFF757575),
                                                  fontSize: 12,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      if (hasEventUrl)
                                        const Icon(
                                          Icons.open_in_new,
                                          color: Color(0xFF3AAA3A),
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (users.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              const Text(
                                'すれ違った人',
                                style: TextStyle(
                                  color: Color(0xFF1A1A1A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: users.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final user = users[index];
                                  return _buildEncounterUserCard(user);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3AAA3A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '閉じる',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEventUrl(BuildContext context, String? rawUrl) async {
    final url = rawUrl?.trim() ?? '';
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('イベントURLが不正です')));
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('イベントURLを開けませんでした')));
    }
  }

  Widget _buildEncounterUserCard(Map<String, dynamic> user) {
    final userId = user['id']?.toString() ?? '';
    final name = user['name']?.toString() ?? '';
    final comment = user['comment']?.toString() ?? '';
    final iconUrl = user['iconUrl']?.toString() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: userId.isEmpty ? null : () => context.push('/profile/$userId'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: iconUrl.isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.person,
                            color: Color(0xFF757575),
                          ),
                        ),
                      )
                    : const Icon(Icons.person, color: Color(0xFF757575)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 24,
                  bottom: 120,
                ),
                child: _buildContent(),
              ),
            ),
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
        'カレンダー',
        style: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final calendarState = ref.watch(calendarNotifierProvider);

    return Column(
      children: [
        // 吹き出しエリア
        _buildBubbleSection(calendarState),
        const SizedBox(height: 24),
        // 月切り替えとカレンダーグリッド
        MonthSelector(
          currentMonth: _currentMonth,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
        ),
        const SizedBox(height: 8),
        if (calendarState.isLoading)
          const Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: Color(0xFF3AAA3A)),
          )
        else
          CalendarGrid(
            currentMonth: _currentMonth,
            selectedDay: _selectedDay,
            encounterDays: calendarState.encounterDays,
            onDaySelected: _onDaySelected,
          ),
      ],
    );
  }

  Widget _buildBubbleSection(CalendarState calendarState) {
    // 選択された日付がある場合
    if (_selectedDay != null) {
      final entry = calendarState.encounterDays.entries
          .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
          .firstWhere(
            (e) =>
                e != null &&
                e.key.year == _selectedDay!.year &&
                e.key.month == _selectedDay!.month &&
                e.key.day == _selectedDay!.day,
            orElse: () => null,
          );

      if (entry != null) {
        final data = entry.value;
        final rawEventName = data['event'] as String?;
        final normalizedEventName = rawEventName?.trim() ?? '';
        return EncounterBubble(
          count: data['count'] as int,
          eventName: normalizedEventName.isNotEmpty
              ? normalizedEventName
              : 'イベントなし',
        );
      }

      // 選択日にすれ違いがない場合は 0 人を表示
      return const EncounterBubble(count: 0, eventName: 'イベントなし');
    }

    // 選択されていない場合は月の合計を表示
    return EncounterBubble(count: calendarState.monthTotal);
  }
}
