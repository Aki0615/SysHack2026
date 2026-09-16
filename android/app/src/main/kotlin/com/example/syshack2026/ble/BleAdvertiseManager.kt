package com.example.syshack2026.ble

import android.bluetooth.BluetoothAdapter
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.ParcelUuid
import android.util.Log

/**
 * BluetoothLeAdvertiser のラッパー。
 * Androidには広告単位のローカル名を設定するAPIが無いため、端末のBluetoothアダプタ名自体を
 * 一時的に "SP_{token}" へ書き換え、停止時に元へ戻す方式を採る（旧 flutter_ble_peripheral と
 * プロトコル互換を保つための設計）。
 * 将来的には AdvertiseData の ServiceData フィールドにトークンを載せる方式へ改善すると、
 * アダプタ名を書き換える必要が無くなる。
 */
class BleAdvertiseManager(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter
) {
    companion object {
        private const val TAG = "BleAdvertiseManager"
        private const val MAX_LOCAL_NAME_LENGTH = 20
    }

    private var advertiser: BluetoothLeAdvertiser? = null
    private var advertiseCallback: AdvertiseCallback? = null
    private var originalAdapterName: String? = null
    private var isAdvertising = false

    fun isCurrentlyAdvertising(): Boolean = isAdvertising

    fun start(token: String, serviceUuid: String, onResult: (Boolean, String?) -> Unit) {
        if (isAdvertising) {
            // トークン更新時は一度止めて元の名前に戻してから出し直す。
            // こうしておかないと、書き換え後の名前を「元の名前」として誤って保存してしまう。
            stop()
        }

        if (!bluetoothAdapter.isEnabled) {
            onResult(false, "BLUETOOTH_DISABLED")
            return
        }

        val leAdvertiser = bluetoothAdapter.bluetoothLeAdvertiser
        if (leAdvertiser == null) {
            onResult(false, "ADVERTISE_UNSUPPORTED")
            return
        }
        advertiser = leAdvertiser

        if (originalAdapterName == null) {
            originalAdapterName = bluetoothAdapter.name
        }

        val localName = buildLocalName(token)
        try {
            // setName はローカルキャッシュを同期的に更新するため、直後の
            // AdvertiseData.setIncludeDeviceName(true) はこの新しい名前を読む。
            // ACTION_LOCAL_NAME_CHANGED ブロードキャストの到達を待つ必要はない。
            bluetoothAdapter.setName(localName)
        } catch (e: SecurityException) {
            onResult(false, "PERMISSION_DENIED")
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
            .setConnectable(false)
            .setTimeout(0)
            .build()

        val advertiseData = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .setIncludeTxPowerLevel(false)
            .addServiceUuid(ParcelUuid.fromString(serviceUuid))
            .build()

        val callback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
                isAdvertising = true
                Log.d(TAG, "アドバタイズ開始成功: $localName")
                onResult(true, null)
            }

            override fun onStartFailure(errorCode: Int) {
                Log.w(TAG, "アドバタイズ開始失敗: errorCode=$errorCode")
                onResult(false, "ADVERTISE_FAILED_$errorCode")
            }
        }
        advertiseCallback = callback

        try {
            leAdvertiser.startAdvertising(settings, advertiseData, callback)
        } catch (e: SecurityException) {
            onResult(false, "PERMISSION_DENIED")
        }
    }

    fun stop(onResult: ((Boolean) -> Unit)? = null) {
        try {
            val currentAdvertiser = advertiser
            val currentCallback = advertiseCallback
            if (currentAdvertiser != null && currentCallback != null) {
                try {
                    currentAdvertiser.stopAdvertising(currentCallback)
                } catch (e: SecurityException) {
                    Log.w(TAG, "アドバタイズ停止時に権限エラー（無視して継続）: ${e.message}")
                }
            }
        } finally {
            // 停止処理の成否に関わらず、必ず元のアダプタ名を復元する。
            val nameToRestore = originalAdapterName
            if (nameToRestore != null) {
                try {
                    bluetoothAdapter.setName(nameToRestore)
                } catch (e: SecurityException) {
                    Log.w(TAG, "アダプタ名復元時に権限エラー: ${e.message}")
                }
            }
            originalAdapterName = null
            isAdvertising = false
            advertiseCallback = null
        }
        onResult?.invoke(true)
    }

    private fun buildLocalName(token: String): String {
        val localName = "SP_$token"
        return if (localName.length > MAX_LOCAL_NAME_LENGTH) {
            localName.substring(0, MAX_LOCAL_NAME_LENGTH)
        } else {
            localName
        }
    }
}
