import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyNativeBridge {
  static final MyNativeBridge _myNativeBridge = MyNativeBridge._internal();
  MethodChannel channel;

  factory MyNativeBridge() {
    return _myNativeBridge;
  }

  void setSpeaker() {
    channel.invokeMethod("set_speaker");
    print("set_speaker");
  }

  MyNativeBridge._internal() {
    channel = MethodChannel('my_native_bridge');
    print("MyNativeBridge Init!!!");
  }
}
