import 'package:flutter/material.dart';
import 'event_list_item.dart';

// 修正: 不要なコメントの削除とコードの最小化
class EventListView extends StatelessWidget {
  final List<Map<String, String>> events;

  const EventListView({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: 8), // 修正: 引数名を省略しない
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
