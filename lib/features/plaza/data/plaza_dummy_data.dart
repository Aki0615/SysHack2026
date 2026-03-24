// 広場画面とプロフィール画面のダミーデータ

// 友達一覧（10人分）
final List<Map<String, String>> dummyFriends = List.generate(
  10,
  (i) => {'name': 'User \${i + 1}'},
);

// イベント一覧（7件分）
final List<Map<String, String>> dummyEvents = List.generate(
  7,
  (i) => {'name': 'Matsuriba MAX（イベント名）', 'date': '2026/03/19', 'count': '123'},
);

// プロフィール（ダミー1人分）
final Map<String, String> dummyProfile = {
  'name': 'User name',
  'comment': 'よろしくお願いします！',
  'techStack': 'Flutter, React, Firebase',
  'twitter': '@flutter_dev_mock',
  'github': 'github.com/mockuser',
  'portfolio': 'my-portfolio.dev',
  'organization': 'Flutter Japan User Group',
};
