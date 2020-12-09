import 'dart:async';

import 'package:flutter/services.dart';

class Filepicker {
  static const MethodChannel _channel =
      const MethodChannel('filepicker');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get filePickerPath async{
    String result = await _channel.invokeMethod("openFilePicker");
    return result;
  }
}
