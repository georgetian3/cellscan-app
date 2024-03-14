import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'cellscan_native_method_channel.dart';

abstract class CellscanNativePlatform extends PlatformInterface {
  /// Constructs a CellscanNativePlatform.
  CellscanNativePlatform() : super(token: _token);

  static final Object _token = Object();

  static CellscanNativePlatform _instance = MethodChannelCellscanNative();

  /// The default instance of [CellscanNativePlatform] to use.
  ///
  /// Defaults to [MethodChannelCellscanNative].
  static CellscanNativePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CellscanNativePlatform] when
  /// they register themselves.
  static set instance(CellscanNativePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getCells() {
    throw UnimplementedError('getCells() has not been implemented.');
  }

  Future<String?> getLocation() {
    throw UnimplementedError('getLocation() has not been implemented.');
  }
    

}
