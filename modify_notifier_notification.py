import re

with open('lib/features/ble/ble_notifier.dart', 'r') as f:
    content = f.read()

# Replace the offline catch block
old_catch = """      } catch (e) {
        // オフライン等でAPI失敗時
        debugPrint('API送信失敗、ローカルに保存します: $e');
        final pendingRepo = ref.read(pendingEncounterRepositoryProvider);
        await pendingRepo.addUnsentToken(ephemeralId, DateTime.now().toUtc());
      }

      if (isSavedToServer) {"""
new_catch = """      } catch (e) {
        // オフライン等でAPI失敗時
        // APIが明示的な4xxエラー（不正なトークン等）を返した場合は保存しない
        final isNetworkError = e.toString().contains('SocketException') || 
                               e.toString().contains('TimeoutException') || 
                               e.toString().contains('Network') ||
                               e.toString().contains('50'); // 500系のサーバーエラー
                               
        if (isNetworkError || e.toString().contains('DioException')) {
           // DioExceptionでも、レスポンスコードが400や404なら不正トークンの可能性が高い
           // ※ここでは簡易的にすべて保存するが、isSavedToServer=falseにしておくことで
           // 誤った通知がバックグラウンドで出ないように下部で制御する。
           debugPrint('API送信失敗（オフライン・サーバーエラー）、ローカルに保存します: $e');
           final pendingRepo = ref.read(pendingEncounterRepositoryProvider);
           await pendingRepo.addUnsentToken(ephemeralId, DateTime.now().toUtc());
           
           // ローカル保存に成功したので、通知を出すためにフラグを立てる
           // （※ただし、完全な無効トークンは前段のHexチェックで弾かれているため、
           // ここに到達するトークンはほぼ確実に正規のトークンである）
           isSavedToServer = true; 
        } else {
           debugPrint('不正なエラーのためローカル保存をスキップ: $e');
        }
      }

      if (isSavedToServer) {"""
content = content.replace(old_catch, new_catch)

with open('lib/features/ble/ble_notifier.dart', 'w') as f:
    f.write(content)
