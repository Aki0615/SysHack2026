import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      if (dayData != null) {
        _selectedDay = date;
      } else {
        _selectedDay = null;
      }
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ハンドル
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
                  // 日付
                  Text(
                    '${date.year}年${date.month}月${date.day}日',
                    style: const TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // イベント名またはタイトル
                  Text(
                    eventName ?? 'すれ違い記録',
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                        Text(
                          'すれ違った人数',
                          style: const TextStyle(
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
                  if (eventName != null) ...[
                    const SizedBox(height: 16),
                    // イベント情報
                    Container(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'イベント',
                                  style: TextStyle(
                                    color: Color(0xFF757575),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  eventName,
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // 閉じるボタン
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 1, color: const Color(0xFFE0E0E0)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
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
        return EncounterBubble(
          count: data['count'] as int,
          eventName: data['event'] as String?,
        );
      }
    }

    // 選択されていない場合は月の合計を表示
    return EncounterBubble(count: calendarState.monthTotal);
  }
}
