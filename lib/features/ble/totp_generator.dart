import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

/// TOTP（Time-based One-Time Password）生成器
/// 5分間隔で更新されるオフラインすれ違い通信用のIDを生成する
class TotpGenerator {
  /// シード文字列と現在時刻から、8文字のBase64文字列を生成する
  /// HMAC-SHA256ハッシュを使用し、6バイトに切り詰めることで正確に8文字のBase64を返す
  /// 
  /// [seed] サーバーから発行されるユーザー固有のシード文字列
  /// [time] 現在時刻（省略時は現在時刻のUTCを使用）
  static String generate(String seed, {DateTime? time}) {
    final now = time ?? DateTime.now().toUtc();
    
    // 5分（300,000ミリ秒）を1ステップとするタイムステップの計算
    // 例: 1970年からの経過時間を5分で割る
    final timeStep = now.millisecondsSinceEpoch ~/ (1000 * 60 * 5);
    
    // タイムステップを8バイトのバイト配列(ビッグエンディアン)に変換
    final timeBytes = _intToBytes(timeStep);
    
    // シード文字列からHMAC-SHA256ハッシュを計算
    final hmac = Hmac(sha256, utf8.encode(seed));
    final digest = hmac.convert(timeBytes);
    
    // 6バイトに切り詰める
    final truncatedBytes = digest.bytes.sublist(0, 6);
    
    // 6バイトをBase64エンコード
    // 6 bytes * 8 bits = 48 bits. 48 bits / 6 bits per Base64 char = 8 chars.
    // 余りが出ないため、パディング（=）無しの正確に8文字となる
    return base64Encode(truncatedBytes);
  }

  /// 整数を8バイトのビッグエンディアン配列に変換するユーティリティ関数
  static List<int> _intToBytes(int value) {
    final byteData = ByteData(8);
    byteData.setInt64(0, value, Endian.big);
    return byteData.buffer.asUint8List();
  }
}
