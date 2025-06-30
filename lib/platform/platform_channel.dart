import 'package:flutter/services.dart';

class PlatformChannel {
  static const _channel = MethodChannel('device_info_channel');

  static Future<String> getBatteryLevel() async {
    final result = await _channel.invokeMethod('getBatteryLevel');
    return result.toString();
  }

  static Future<String> getDeviceName() async {
    final result = await _channel.invokeMethod('getDeviceName');
    return result.toString();
  }

  static Future<String> getOSVersion() async {
    final result = await _channel.invokeMethod('getOSVersion');
    return result.toString();
  }

  static Future<void> toggleFlashlight() async {
    await _channel.invokeMethod('toggleFlashlight');
  }

  static Future<String> startGyroscope() async {
    final result = await _channel.invokeMethod('startGyroscope');
    return result.toString();
  }

  static Future<void> stopGyroscope() async {
    await _channel.invokeMethod('stopGyroscope');
  }
}
