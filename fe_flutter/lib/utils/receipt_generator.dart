import 'package:esc_pos_utils_plus/esc_pos_utils.dart';

class ReceiptGenerator {
  static Future<List<int>> build({
    required String invoice,
    required List items,
    required int total,
    required int bayar,
    required int kembali,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);

    List<int> bytes = [];

    bytes += generator.text(
      'TOKO Senja & Rona',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );

    bytes += generator.hr();
    bytes += generator.text('Invoice: $invoice');

    for (var item in items) {
      bytes += generator.row([
        PosColumn(
          text: '${item['name']} x${item['qty']}',
          width: 8,
        ),
        PosColumn(
          text: item['subtotal'].toString(),
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);
    }

    bytes += generator.hr();
    bytes += generator.text('TOTAL : $total', styles: const PosStyles(bold: true));
    bytes += generator.text('BAYAR : $bayar');
    bytes += generator.text('KEMBALI : $kembali');

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
