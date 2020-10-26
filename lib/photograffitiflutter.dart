import 'dart:async';

import 'package:flutter/services.dart';

class Photograffitiflutter {
  static const MethodChannel _channel =
      const MethodChannel('photograffitiflutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
