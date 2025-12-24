import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/receipt.dart';

class PdfService {
  static Future<File> generateReceiptPdf(Receipt r) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                "TOKO SENJA RONA",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text("Kasir : ${r.cashier}"),
            pw.Text("Tanggal : ${r.date}"),
            pw.Divider(),

            ...r.items.map(
              (i) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("${i.name} x${i.qty}"),
                  pw.Text(
                    (i.qty * i.price).toStringAsFixed(0),
                  ),
                ],
              ),
            ),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("TOTAL"),
                pw.Text(r.total.toStringAsFixed(0)),
              ],
            ),
            pw.Text("BAYAR : ${r.paid}"),
            pw.Text("KEMBALI : ${r.change}"),

            pw.SizedBox(height: 20),
            pw.Center(child: pw.Text("Terima Kasih 🙏")),
          ],
        ),
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/struk_${r.id}.pdf");

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
