import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return CalendarRepository(ref.read(dioProvider));
});

/// カレンダー画面のデータを取得するリポジトリ
class CalendarRepository {
  final Dio _dio;

  CalendarRepository(this._dio);

  /// 特定の日付のすれ違い数とイベント名を取得する（GET /users/:id/calendar/daily?date=YYYY-MM-DD）
  Future<Map<String, dynamic>> fetchDailyEncounters({
    required String userId,
    required String dateString, // YYYY-MM-DD
  }) async {
    final response = await _dio.get(
      '/users/$userId/calendar/daily',
      queryParameters: {'date': dateString},
    );
    return response.data as Map<String, dynamic>;
  }
}
