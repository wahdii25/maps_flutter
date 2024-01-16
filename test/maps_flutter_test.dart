import 'package:apple_map_native/maps_flutter.dart';
import 'package:apple_map_native/maps_flutter_method_channel.dart';
import 'package:apple_map_native/maps_flutter_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMapsFlutterPlatform
    with MockPlatformInterfaceMixin
    implements MapsFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MapsFlutterPlatform initialPlatform = MapsFlutterPlatform.instance;

  test('$MethodChannelMapsFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMapsFlutter>());
  });

  test('getPlatformVersion', () async {
    MapsFlutter mapsFlutterPlugin = MapsFlutter();
    MockMapsFlutterPlatform fakePlatform = MockMapsFlutterPlatform();
    MapsFlutterPlatform.instance = fakePlatform;

    expect(await mapsFlutterPlugin.getPlatformVersion(), '42');
  });
}
