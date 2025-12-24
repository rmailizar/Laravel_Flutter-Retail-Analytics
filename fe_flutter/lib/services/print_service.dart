import 'dart:typed_data';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/receipt.dart';

class PrintService {
  static Future<Uint8List> generateReceipt(Receipt r) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    bytes += generator.text(
      "TOKO SENJA RONA",
      styles: const PosStyles(
        bold: true,
        align: PosAlign.center,
        height: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();
    bytes += generator.text("Kasir : ${r.cashier}");
    bytes += generator.text("Tanggal : ${r.date}");
    bytes += generator.hr();

    for (var i in r.items) {
      bytes += generator.row([
        PosColumn(text: "${i.name} x${i.qty}", width: 8),
        PosColumn(
          text: (i.qty * i.price).toStringAsFixed(0),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: "TOTAL", width: 6),
      PosColumn(
        text: r.total.toStringAsFixed(0),
        width: 6,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.text("BAYAR : ${r.paid}");
    bytes += generator.text("KEMBALI : ${r.change}");

    bytes += generator.hr();
    bytes += generator.text(
      "Terima Kasih 🙏",
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }
}
