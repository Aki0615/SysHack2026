/// バックエンド未実装 API 向けのモック実装切替フラグ。
///
/// サーバー側の実装が完了して疎通確認が取れたら、対応するフラグを false にする。
abstract final class FeatureFlags {
  /// close_friends 3 本の API（追加 / 解除 / 一覧）にモック実装を使う。
  static const bool useMockCloseFriends = true;

  /// GET /events/:id（イベント詳細と参加者一覧）にモック実装を使う。
  static const bool useMockEventDetail = true;
}
