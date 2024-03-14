import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cellscan_native_platform_interface.dart';

/// An implementation of [CellscanNativePlatform] that uses method channels.
class MethodChannelCellscanNative extends CellscanNativePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('cellscan_native');

  @override getCells() async => await methodChannel.invokeMethod<String>('getCells');
  @override getLocation() async => await methodChannel.invokeMethod<String>('getLocation');

}
