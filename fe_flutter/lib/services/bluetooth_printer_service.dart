import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class BluetoothPrinterService {
  static Future<List<BluetoothInfo>> scanPairedPrinters() async {
    return await PrintBluetoothThermal.pairedBluetooths;
  }

  static Future<void> connect(String mac) async {
    final result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (!result) {
      throw Exception('Gagal connect ke printer');
    }
  }

  static Future<bool> isConnected() async {
    return await PrintBluetoothThermal.connectionStatus;
  }
}
