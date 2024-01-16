import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'maps_flutter_platform_interface.dart';

/// An implementation of [MapsFlutterPlatform] that uses method channels.
class MethodChannelMapsFlutter extends MapsFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('maps_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
