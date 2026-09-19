import re

with open('lib/features/ble/ble_service.dart', 'r') as f:
    content = f.read()

# Replace _extractEphemeralId
old_extract = """  String? _extractEphemeralId(ScanResult result) {
    // 1. Service Data から抽出 (Androidからの発信)
    final serviceDataBytes =
        result.advertisementData.serviceData[Guid(streetPassServiceUuid)];
    if (serviceDataBytes != null && serviceDataBytes.isNotEmpty) {
      final token = String.fromCharCodes(serviceDataBytes).trim();
      if (token.length == 8 || token.length == 16) {
        return token;
      }
    }

    // 2. Local Name から抽出 (iOSからの発信)
    final advertisedName = result.advertisementData.advName;
    final platformName = result.device.platformName;

    if (advertisedName.length == 8 || advertisedName.length == 16) {
      return advertisedName;
    }
    if (platformName.length == 8 || platformName.length == 16) {
      return platformName;
    }
    return null;
  }"""
new_extract = """  bool _isValidToken(String token) {
    if (token.length != 8 && token.length != 16) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(token);
  }

  /// iOS専用: ScanResultからエフェメラルIDを抽出
  String? _extractEphemeralId(ScanResult result) {
    // 1. Service Data から抽出 (Androidからの発信)
    final serviceDataBytes =
        result.advertisementData.serviceData[Guid(streetPassServiceUuid)];
    if (serviceDataBytes != null && serviceDataBytes.isNotEmpty) {
      var token = String.fromCharCodes(serviceDataBytes).trim();
      // Androidが万が一プレフィックスを付けて送ってきた場合は剥がす
      if (token.startsWith('SP_')) {
        token = token.substring(3);
      }
      if (_isValidToken(token)) return token;
    }

    // 2. Local Name から抽出 (iOSからの発信)
    // iOSは31バイト制限回避のため、プレフィックス等を一切つけずトークンをそのまま格納している
    var advertisedName = result.advertisementData.advName.trim();
    if (advertisedName.startsWith('SP_')) {
      advertisedName = advertisedName.substring(3);
    }
    if (_isValidToken(advertisedName)) return advertisedName;

    var platformName = result.device.platformName.trim();
    if (platformName.startsWith('SP_')) {
      platformName = platformName.substring(3);
    }
    if (_isValidToken(platformName)) return platformName;

    return null;
  }"""
content = content.replace(old_extract, new_extract)

with open('lib/features/ble/ble_service.dart', 'w') as f:
    f.write(content)
