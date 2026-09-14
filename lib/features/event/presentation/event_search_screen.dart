import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:syshack2026/core/constants/app_colors.dart';
import 'package:syshack2026/features/calendar/presentation/widgets/day_event_card.dart';
import 'package:syshack2026/features/plaza/domain/plaza_notifier.dart';

/// イベント検索画面。
///
/// - 上部: 戻るボタン + 検索フィールド（プレースホルダ「イベント名を入力」）
/// - 本体: 「関連イベント」見出し + フィルタ済みイベントリスト
/// - タップ時: そのイベントの開催日を `context.pop<DateTime>(date)` で呼び出し元へ返す
///
/// データ取得は既存の `plazaEventNotifierProvider`（GET /events）を再利用。
/// フィルタは name への部分一致（大文字小文字無視）でクライアント側完結。
/// 入力のたびに再フェッチはしない。
class EventSearchScreen extends ConsumerStatefulWidget {
  const EventSearchScreen({super.key});

  @override
  ConsumerState<EventSearchScreen> createState() => _EventSearchScreenState();
}

class _EventSearchScreenState extends ConsumerState<EventSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final next = _controller.text.trim();
      if (next != _query) {
        setState(() => _query = next);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(plazaEventNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(controller: _controller),
            Expanded(
              child: eventsAsync.when(
                data: (events) => _buildResults(_filter(events)),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'イベントの取得に失敗しました\n$error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filter(List<Map<String, dynamic>> events) {
    if (_query.isEmpty) return events;
    final q = _query.toLowerCase();
    return events
        .where((e) => (e['name']?.toString() ?? '').toLowerCase().contains(q))
        .toList();
  }

  Widget _buildResults(List<Map<String, dynamic>> events) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(15, 24, 15, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '関連イベント',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 24 / 20,
            ),
          ),
          const SizedBox(height: 12),
          if (events.isEmpty)
            const _EmptyState()
          else
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _ResultCard(event: event),
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final TextEditingController controller;

  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: _SearchField(controller: controller)),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(90),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'イベント名を入力',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 18,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  onPressed: controller.clear,
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

/// 検索結果カード。`DayEventCard` を薄くラップして pop 動作を追加。
class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> event;

  const _ResultCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final date = _parseDate(event['date']?.toString());

    return DayEventCard(
      eventName: event['name']?.toString() ?? '',
      date: date ?? DateTime.now(),
      location: event['location']?.toString() ?? '',
      participantCount:
          (event['count'] as int?) ?? (event['accepted'] as int?) ?? 0,
      onTap: () {
        if (date == null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('このイベントには有効な開催日が設定されていません'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          return;
        }
        context.pop<DateTime>(date);
      },
    );
  }

  /// PlazaRepository が組み立てる 'YYYY/MM/DD' 形式を DateTime に戻す。
  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('/');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(
          '該当するイベントはありません',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
