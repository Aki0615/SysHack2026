import 'package:flutter/material.dart';
import '../data/calendar_dummy_data.dart';
import 'widgets/encounter_bubble.dart';
import 'widgets/month_selector.dart';
import 'widgets/calendar_grid.dart';

/// カレンダー画面本体Widget
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
  }

  void _onPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _selectedDay = null; // 月を変えたら選択解除
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _selectedDay = null;
    });
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      // 選択した日付がダミーデータ内に存在するかチェック
      final hasEncounter = dummyEncounterDays.keys.any(
        (d) =>
            d.year == date.year && d.month == date.month && d.day == date.day,
      );

      // 存在する場合は吹き出しに表示し、存在しない場合は選択解除（月の合計表示）
      if (hasEncounter) {
        _selectedDay = date;
      } else {
        _selectedDay = null;
      }
    });
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
    return Column(
      children: [
        // 吹き出しエリア
        _buildBubbleSection(),
        const SizedBox(height: 24),
        // 月切り替えとカレンダーグリッド
        MonthSelector(
          currentMonth: _currentMonth,
          onPreviousMonth: _onPreviousMonth,
          onNextMonth: _onNextMonth,
        ),
        const SizedBox(height: 8),
        CalendarGrid(
          currentMonth: _currentMonth,
          selectedDay: _selectedDay,
          encounterDays: dummyEncounterDays,
          onDaySelected: _onDaySelected,
        ),
      ],
    );
  }

  Widget _buildBubbleSection() {
    // 選択された日付がある場合
    if (_selectedDay != null) {
      final entry = dummyEncounterDays.entries.firstWhere(
        (e) =>
            e.key.year == _selectedDay!.year &&
            e.key.month == _selectedDay!.month &&
            e.key.day == _selectedDay!.day,
      );

      final data = entry.value;
      return EncounterBubble(
        count: data['count'] as int,
        eventName: data['event'] as String?,
      );
    }

    // 選択されていない場合は月の合計を表示
    return EncounterBubble(count: dummyMonthTotal);
  }
}
