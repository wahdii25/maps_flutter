part of maps_flutter;

class AppleMap extends StatelessWidget {
  const AppleMap({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String,dynamic> creationParams = <String,dynamic>{};
    return UiKitView(
      viewType: 'appleNativeMapView',
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
