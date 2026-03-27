import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'common/router/app_router.dart';

void main() {
  // Riverpodの状態管理スコープでアプリ全体をラップ
  runApp(const ProviderScope(child: StreetPassApp()));
}

/// アプリのルートWidget
class StreetPassApp extends ConsumerWidget {
  const StreetPassApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GoRouterのインスタンスをProviderから取得
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'StreetPass',
      debugShowCheckedModeBanner: false,
      // 日本語ロケール設定
      locale: const Locale('ja', 'JP'),
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // ダークテーマの設定
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        // 日本語フォント設定
        fontFamily: 'Hiragino Sans',
        fontFamilyFallback: const ['Hiragino Kaku Gothic ProN', 'Noto Sans JP', 'sans-serif'],
      ),
      // GoRouterをMaterialAppに接続する
      routerConfig: router,
    );
  }
}
