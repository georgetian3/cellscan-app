
import 'cellscan_native_platform_interface.dart';

class CellscanNative {
  Future<String?> getCells() => CellscanNativePlatform.instance.getCells();
  Future<String?> getLocation() => CellscanNativePlatform.instance.getLocation();
}
