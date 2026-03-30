import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/calendar_repository.dart';
import '../../auth/domain/auth_notifier.dart';

/// カレンダー画面のデータ状態
class CalendarState {
  /// 日付ごとのすれ違いデータ（キー: DateTime、値: {count, event, users}）
  final Map<DateTime, Map<String, dynamic>> encounterDays;

  /// 月の合計すれ違い数
  final int monthTotal;

  /// ロード中かどうか
  final bool isLoading;

  const CalendarState({
    required this.encounterDays,
    required this.monthTotal,
    this.isLoading = false,
  });

  factory CalendarState.empty() => const CalendarState(
        encounterDays: {},
        monthTotal: 0,
      );

  CalendarState copyWith({
    Map<DateTime, Map<String, dynamic>>? encounterDays,
    int? monthTotal,
    bool? isLoading,
  }) {
    return CalendarState(
      encounterDays: encounterDays ?? this.encounterDays,
      monthTotal: monthTotal ?? this.monthTotal,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// カレンダー画面のデータを管理するプロバイダー
final calendarNotifierProvider =
    NotifierProvider<CalendarNotifier, CalendarState>(CalendarNotifier.new);

/// カレンダー画面のデータ管理を行うNotifier
class CalendarNotifier extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    return CalendarState.empty();
  }

  /// 指定月のデータを取得
  Future<void> fetchMonthData(DateTime month) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(calendarRepositoryProvider);
      final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

      final newEncounterDays = Map<DateTime, Map<String, dynamic>>.from(
        state.encounterDays,
      );
      int monthTotal = 0;

      final monthEventsFuture = repo.fetchMonthEvents(month);

      // 月の各日のデータを取得（並列で取得）
      final futures = <Future<MapEntry<DateTime, Map<String, dynamic>>?>>[];

      for (int day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        futures.add(_fetchDayData(repo, user.id, date, dateString));
      }

      final results = await Future.wait(futures);
      final monthEvents = await monthEventsFuture;

      for (final entry in results) {
        if (entry != null) {
          newEncounterDays[entry.key] = entry.value;
          monthTotal += (entry.value['count'] as int?) ?? 0;
        }
      }

      for (final event in monthEvents) {
        final startAt = DateTime.tryParse(event['start_at']?.toString() ?? '');
        if (startAt == null) continue;
        final date = DateTime(startAt.year, startAt.month, startAt.day);

        final existing = newEncounterDays[date] ?? const <String, dynamic>{};
        final merged = Map<String, dynamic>.from(existing);

        merged['event'] = merged['event'] ?? event['name']?.toString() ?? '';
        merged['event_location'] =
            event['location']?.toString() ?? merged['event_location']?.toString() ?? '';
        merged['count'] = merged['count'] ?? 0;
        merged['users'] = merged['users'] ?? const <Map<String, dynamic>>[];

        newEncounterDays[date] = merged;
      }

      state = CalendarState(
        encounterDays: newEncounterDays,
        monthTotal: monthTotal,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<MapEntry<DateTime, Map<String, dynamic>>?> _fetchDayData(
    CalendarRepository repo,
    String userId,
    DateTime date,
    String dateString,
  ) async {
    try {
      final data = await repo.fetchDailyEncounters(
        userId: userId,
        dateString: dateString,
      );

      final count =
          (data['encounter_count'] as int?) ?? (data['count'] as int?) ?? 0;
      final event =
          data['event'] as String? ??
          ((data['event_names'] as List?)?.cast<String?>().firstWhere(
            (name) => name != null && name.isNotEmpty,
            orElse: () => null,
          ));
      final users = _parseEncounterUsers(data);

      if (count > 0) {
        return MapEntry(date, {
          'count': count,
          'event': event,
          'event_location': data['event_location']?.toString() ?? '',
          'users': users,
        });
      }
    } catch (_) {
      // エラーは無視
    }
    return null;
  }

  List<Map<String, dynamic>> _parseEncounterUsers(Map<String, dynamic> data) {
    final candidates = [
      data['users'],
      data['encounter_users'],
      data['encounters'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map(
              (raw) => {
                'id': raw['id']?.toString() ?? '',
                'name': raw['name']?.toString() ?? '',
                'iconUrl':
                    (raw['icon_url'] ?? raw['iconUrl'])?.toString() ?? '',
                'comment': (raw['one_word'] ?? raw['comment'])?.toString() ?? '',
              },
            )
            .where((user) => user['id']!.isNotEmpty)
            .toList();
      }
    }

    return const [];
  }

  /// 特定日のデータを取得
  Map<String, dynamic>? getDayData(DateTime date) {
    return state.encounterDays.entries
        .cast<MapEntry<DateTime, Map<String, dynamic>>?>()
        .firstWhere(
          (e) =>
              e != null &&
              e.key.year == date.year &&
              e.key.month == date.month &&
              e.key.day == date.day,
          orElse: () => null,
        )
        ?.value;
  }
}

/// DateUtils補助クラス
class DateUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }
}
