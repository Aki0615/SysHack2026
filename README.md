# StreetPass 📡

Bluetooth（BLE）を使ったスマホ版すれ違い通信アプリ

## 概要

StreetPassは、近くにいるユーザー同士がBluetooth Low Energy（BLE）を通じて自動的にすれ違い通信を行い、プロフィールや一言メッセージを交換できるアプリです。

## 技術スタック

| カテゴリ | 技術 |
|---|---|
| フレームワーク | Flutter / Dart |
| 状態管理 | Riverpod |
| ルーティング | GoRouter |
| HTTP通信 | Dio |
| BLE通信 | flutter_blue_plus |
| データクラス | freezed / json_serializable |
| トークン管理 | flutter_secure_storage |

## アーキテクチャ

Clean Architecture（feature-first ディレクトリ構成）を採用しています。

```
lib/
├── core/                  # 共通基盤（ネットワーク等）
├── common/                # 共通Widget・ルーター
├── features/
│   ├── auth/              # 認証機能
│   │   ├── data/          # リポジトリ（API通信）
│   │   ├── domain/        # 状態管理（Notifier）
│   │   └── presentation/  # 画面（UI）
│   ├── user/              # ユーザー機能
│   ├── encounter/         # すれ違い通信機能
│   ├── home/              # ホーム画面
│   ├── plaza/             # 広場機能
│   ├── calendar/          # カレンダー機能
│   └── my_page/           # マイページ機能
└── main.dart
```

## セットアップ

```bash
# 依存パッケージのインストール
flutter pub get

# freezed等のコード生成
dart run build_runner build --delete-conflicting-outputs

# 実行
flutter run
```

## 対象OS

- Android
- iOS（考慮した設計）
