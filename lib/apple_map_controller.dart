part of maps_flutter;

class AppleMapController {
  static const MethodChannel channel = MethodChannel('map_view_flutter');

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getCurrentUserCoordinate':
        break;
      case 'getAddress':
        break;
      default:
        throw MissingPluginException();
    }
  }

  static Future<Map> getUserCoordinate() async {
    final data = await channel.invokeMethod('getCurrentUserCoordinate',{});
    if(data != null){
      return data;
    }
    return {};
  }

  static Future<Map> getAddress() async {
    final data = await channel.invokeMethod('getAddress',{});
    if(data != null){
      return data;
    }
    return {};
  }
}