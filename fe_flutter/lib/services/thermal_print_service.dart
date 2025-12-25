import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ThermalPrintService {
  static Future<void> print(List<int> bytes) async {
    final connected = await PrintBluetoothThermal.connectionStatus;
    if (!connected) {
      throw Exception('Printer belum terhubung');
    }

    await PrintBluetoothThermal.writeBytes(bytes);
  }
}
