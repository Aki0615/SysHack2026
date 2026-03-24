import 'package:flutter/material.dart';
import 'event_list_item.dart';

/// イベント一覧タブの全体Widget（ListView）
class EventListView extends StatelessWidget {
  /// イベントリストデータ（name, date, countのマップ）
  final List<Map<String, String>> events;

  const EventListView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8), // 8pxの余白
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListItem(
          eventName: event['name'] ?? '',
          date: event['date'] ?? '',
          count: event['count'] ?? '',
        );
      },
    );
  }
}
